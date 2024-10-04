<script setup>
import { ref, onMounted } from 'vue';
import { getApplications, removeApplication } from '@/services/backendService';
import ValidatorList from './ValidatorList.vue';
import { toSimpleArray } from '@/plugins/common';
import Dialog from '@/plugins/dialog';
const props = defineProps(['providers']);
const emit = defineEmits(['open-dialog', 'show-params']);

const applications = ref([]);

const fetchApplications = async () => {
    applications.value = toSimpleArray(await getApplications());
};

const deleteApplication = async (id) => {
    if (confirm('Are you sure you want to delete this application?')) {
        await removeApplication(id);
        fetchApplications();
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
