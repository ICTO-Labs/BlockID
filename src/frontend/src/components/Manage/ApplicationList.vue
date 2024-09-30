<script setup>
    import { ref, onMounted } from 'vue'
    import { getApplications, removeApplication } from '@/services/backendService'
    import ValidatorList from './ValidatorList.vue'
    import { toSimpleArray } from '@/plugins/common'

    const props = defineProps(['providers'])
    const emit = defineEmits(['open-dialog', 'show-params'])

    const applications = ref([])

    const fetchApplications = async () => {
        applications.value = toSimpleArray(await getApplications())
    }

    const deleteApplication = async (id) => {
        if (confirm('Bạn có chắc chắn muốn xóa ứng dụng này không?')) {
            await removeApplication(id)
            fetchApplications()
        }
    }
    const handleOpenDialog = (...args) => {
        emit('open-dialog', ...args)
    }

    onMounted(fetchApplications)
</script>

<template>
    <v-expansion-panels>
        <v-expansion-panel v-for="app in applications" :key="app.id">
            <v-expansion-panel-title class="bg-containerBg">
                <v-icon>mdi-application</v-icon>
                <span class="font-weight-bold">{{ app.name }}</span>
                <template v-slot:actions>
                    <v-btn size="small" class="mr-2" @click.stop="$emit('open-dialog', {dialog: 'application', method: 'edit', params: app})">
                        <v-icon>mdi-pencil</v-icon>
                    </v-btn>
                    <v-btn size="small" color="error" @click.stop="deleteApplication(app.id)">
                        <v-icon>mdi-delete</v-icon>
                    </v-btn>
                </template>
            </v-expansion-panel-title>
            <v-expansion-panel-text>
                <div class="mb-4">{{ app.description }}</div>
                <ValidatorList :application-id="app.id" :validators="app.validators" @show-params="$emit('show-params', $event)" @open-dialog="handleOpenDialog" />
            </v-expansion-panel-text>
        </v-expansion-panel>
    </v-expansion-panels>
    <v-divider></v-divider>
    <div class="mt-4">
        <v-btn @click="$emit('open-dialog', {dialog: 'application', method: 'add', params: {}})"><v-icon>mdi-plus</v-icon> Create application</v-btn>
    </div>
</template>