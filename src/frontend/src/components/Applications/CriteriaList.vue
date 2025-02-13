<script setup>
import { ref, onMounted, watch } from 'vue';
import { removeCriteria } from '@/services/backendService';
import VcFlow from '@/components/icons/VcFlow.vue';
import Dialog from '@/plugins/dialog';
import Notify from '@/plugins/notify';
const props = defineProps(['validatorId', 'criterias']);
const emit = defineEmits(['open-dialog', 'show-params']);

const criterias = ref(props.criterias);

const deleteCriteria = async (id) => {
    const confirm = await Dialog.confirm({
        title: 'Warning',
        message: 'Are you sure you want to delete this criteria: ' + id + '?',
        color: 'warning',
        icon: 'mdi-alert'
    });
    if (confirm) {
        Dialog.showLoading('Deleting criteria...');
        let _rs = await removeCriteria(props.validatorId, id);
        if(_rs && "ok" in _rs){
            criterias.value = criterias.value.filter(
                (criteria) => criteria.id !== id
            );
            Notify.success('Criteria deleted successfully');
        } else {
            Notify.error(_rs.err);
        }
        Dialog.closeLoading()
    }
};

const showParams = (criteria) => {
    Dialog.custom('paramsInfo', { ...criteria, title: 'Params' });
};

const showEditDialog = (criteria) => {
    Dialog.custom('criteriaForm', {
        criteria: Object.assign({}, criteria),
        method: 'edit',
        maxWidth: 1000,
        title: 'Edit criteria:' + criteria.name,
        validatorId: props.validatorId
    });
};
const showAddDialog = () => {
    Dialog.custom('criteriaForm', {
        method: 'add',
        maxWidth: 1000,
        title: 'Create criteria',
        validatorId: props.validatorId
    });
};
</script>

<template>
    <v-table hover>
        <thead>
            <tr>
                <th>Criteria</th>
                <th>Description</th>
                <th>Provider</th>
                <th>Score</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="criteria in criterias" :key="criteria.id">
                <td>
                    {{ criteria.name }} <VcFlow v-if="criteria.isVC"></VcFlow>
                </td>
                <td><p v-html="criteria.description"></p></td>
                <td>
                    <v-chip
                        v-if="criteria.providerId.length > 0"
                        size="small"
                        color="secondary"
                        label=""
                        text-color="white"
                        @click.stop="showParams(criteria)"
                    >
                        {{ criteria.providerId[0] || 'Custom' }}
                        <v-tooltip activator="parent" location="top"
                            >Show params</v-tooltip
                        >
                    </v-chip>
                </td>
                <td>{{ criteria.score }}</td>
                <td>
                    <v-btn
                        size="small"
                        class="mr-2"
                        @click.stop="showEditDialog(criteria)"
                    >
                        <v-icon>mdi-pencil</v-icon>
                    </v-btn>
                    <v-btn
                        size="small"
                        color="error"
                        @click.stop="deleteCriteria(criteria.id)"
                    >
                        <v-icon>mdi-delete</v-icon>
                    </v-btn>
                </td>
            </tr>
        </tbody>
    </v-table>
    <v-divider></v-divider>
    <div class="mt-4">
        <v-btn @click="showAddDialog">
            <v-icon>mdi-plus</v-icon> Create criteria
        </v-btn>
    </div>
</template>
