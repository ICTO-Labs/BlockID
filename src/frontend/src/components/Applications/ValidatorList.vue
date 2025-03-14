<script setup>
import { ref, onMounted, watch } from 'vue';
import { getValidators, removeValidator } from '@/services/backendService';
import CriteriaList from './CriteriaList.vue';
import { toSimpleArray } from '@/plugins/common';
import Dialog from '@/plugins/dialog';
import Notify from '@/plugins/notify';
const props = defineProps(['applicationId', 'validators']);
const emit = defineEmits(['open-dialog', 'show-params']);

const validators = ref([]);

const fetchValidators = async () => {
    validators.value = toSimpleArray(await getValidators(props.applicationId));
};

const deleteValidator = async (id) => {
    const confirm = await Dialog.confirm({
        title: 'Warning',
        message: 'Are you sure you want to delete this validator: ' + id + '?',
        color: 'warning',
        icon: 'mdi-alert'
    });
    if (confirm) {
        Dialog.showLoading('Deleting validator...');
        let _rs = await removeValidator(id);
        if(_rs && "ok" in _rs){
            fetchValidators();
            Notify.success('Validator deleted successfully');
        } else {
            Notify.error(_rs.err);
        }
        Dialog.closeLoading()
    }
};

const handleOpenDialog = (...args) => {
    emit('open-dialog', ...args);
};
const showEditDialog = (validator) => {
    Dialog.custom('validatorForm', {
        validator: Object.assign({}, validator),
        applicationId: props.applicationId,
        method: 'edit',
        maxWidth: 1000,
        title: 'Edit validator: ' + validator.name,
        onSave: () => {
            fetchValidators();
        }
    });
};
const showAddDialog = () => {
    Dialog.custom('validatorForm', {
        method: 'add',
        maxWidth: 1000,
        applicationId: props.applicationId,
        title: 'Create validator',
        onSave: () => {
            fetchValidators();
        }
    });
};


onMounted(fetchValidators);
watch(() => props.applicationId, fetchValidators);
</script>

<template>
    <v-expansion-panels>
        <v-expansion-panel v-for="validator in validators" :key="validator.id">
            <v-expansion-panel-title class="bg-containerBg">
                <v-avatar size="22" class="me-2">
                    <v-img :alt="validator.name" :src="validator.logo"></v-img>
                </v-avatar>
                {{ validator.name }}

                <template v-slot:actions>
                    <v-btn
                        size="small"
                        class="mr-2"
                        @click.stop="
                            showEditDialog(validator)
                        "
                    >
                        <v-icon>mdi-pencil</v-icon>
                    </v-btn>
                    <v-btn
                        size="small"
                        color="error"
                        @click.stop="deleteValidator(validator.id)"
                    >
                        <v-icon>mdi-delete</v-icon>
                    </v-btn>
                </template>
            </v-expansion-panel-title>
            <v-expansion-panel-text>
                <p v-html="validator.description"></p>
                <CriteriaList
                    :validatorId="validator.id"
                    :criterias="validator.criterias"
                    @show-params="$emit('show-params', $event)"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
    </v-expansion-panels>
    <v-divider></v-divider>
    <div class="mt-4">
        <v-btn
            @click="
                showAddDialog()
            "
        >
            <v-icon>mdi-plus</v-icon> Create Validator
        </v-btn>
    </div>
</template>
