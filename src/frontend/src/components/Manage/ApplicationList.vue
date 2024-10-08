<script setup>
import { ref, onMounted } from 'vue';
import { getApplications, removeApplication } from '@/services/backendService';
import ValidatorList from './ValidatorList.vue';
import { toSimpleArray } from '@/plugins/common';
import Dialog from '@/plugins/dialog';
import Notify from '@/plugins/notify';
const props = defineProps(['providers']);
const emit = defineEmits(['open-dialog', 'show-params']);

const applications = ref([]);
const loading = ref(false);
const fetchApplications = async () => {
    applications.value = toSimpleArray(await getApplications());
};

const deleteApplication = async (id) => {
    const confirm = await Dialog.confirm({
        title: 'Warning',
        message: 'Are you sure you want to delete this application: ' + id + '?',
        color: 'warning',
        icon: 'mdi-alert'
    });
    if (confirm) {
        loading.value = true;
        Dialog.showLoading('Deleting application...');
        let _rs = await removeApplication(id);
        if(_rs && "ok" in _rs){
            fetchApplications();
            Notify.success('Application deleted successfully');
        } else {
            Notify.error(_rs.err);
        }
        loading.value = false;
        Dialog.closeLoading();
    } else {
        Dialog.close('confirm');
    }
};
const showEditDialog = (app) => {
    Dialog.custom('applicationForm', {
        app: Object.assign({}, app),
        method: 'edit',
        maxWidth: 1000,
        title: 'Edit application: ' + app.name,
        onSave: () => {
            fetchApplications();
        }
    });
};
const showAddDialog = () => {
    Dialog.custom('applicationForm', {
        method: 'add',
        maxWidth: 1000,
        title: 'Create application',
        onSave: () => {
            fetchApplications();
        }
    });
};
const handleOpenDialog = (...args) => {
    emit('open-dialog', ...args);
};

onMounted(fetchApplications);
</script>

<template>
    <v-expansion-panels>
        <v-expansion-panel v-for="app in applications" :key="app.id">
            <v-expansion-panel-title class="bg-containerBg">
                <v-icon>mdi-application</v-icon>
                <span class="font-weight-bold">{{ app.name }}</span>
                <template v-slot:actions>
                    <v-btn
                        size="small"
                        class="mr-2"
                        @click.stop="
                            showEditDialog(app)
                        "
                    >
                        <v-icon>mdi-pencil</v-icon>
                    </v-btn>
                    <v-btn
                        size="small"
                        color="error"
                        @click.stop="deleteApplication(app.id)"
                    >
                        <v-icon>mdi-delete</v-icon>
                    </v-btn>
                </template>
            </v-expansion-panel-title>
            <v-expansion-panel-text>
                <div class="mb-4">{{ app.description }}</div>
                <ValidatorList
                    :applicationId="app.id"
                    :validators="app.validators"
                    @show-params="$emit('show-params', $event)"
                    @open-dialog="handleOpenDialog"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
    </v-expansion-panels>
    <v-divider></v-divider>
    <div class="mt-4">
        <v-btn
            @click="showAddDialog"
            ><v-icon>mdi-plus</v-icon> Create application</v-btn
        >
    </div>
</template>
