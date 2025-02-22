
<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { submitProvider } from '@/services/marketplaceService'

const router = useRouter()

const valid = ref(false)
const submitting = ref(false)

const formData = ref({
    name: '',
    description: '',
    sourceUrl: '',
    moduleName: ''
})

// Form validation rules
const nameRules = [
    v => !!v || 'Name is required',
    v => v.length >= 3 || 'Name must be at least 3 characters'
]

const moduleNameRules = [
    v => !!v || 'Module name is required',
    v => /^[a-zA-Z0-9_]+$/.test(v) || 'Only alphanumeric characters and underscore allowed',
    v => v.length >= 3 || 'Module name must be at least 3 characters'
]

async function submit() {
    if (!valid.value) return

    submitting.value = true
    try {
        const result = await submitProvider(
            formData.value.name,
            formData.value.description,
            formData.value.sourceUrl,
            formData.value.moduleName
        )
        console.log('result', result);
        if ('ok' in result) {
            router.push('/marketplace')
        } else {
            throw new Error(result.err)
        }
    } catch (err) {
        console.error('Failed to submit provider:', err)
    }
    submitting.value = false
}
</script>
<template>
    <v-row justify="center">
        <v-col cols="12">
            <v-card>
                <v-card-title class="d-flex justify-space-between align-center">
                    Submit New Provider

                    <v-btn color="default" :to="{ path: '/marketplace' }">
                        <v-icon left>mdi-arrow-left</v-icon>
                        Marketplace
                    </v-btn>
                </v-card-title>
                <v-card-text>
                    <v-form ref="form" v-model="valid">
                        <v-text-field v-model="formData.name" :rules="nameRules" label="Provider Name" required />

                        <v-textarea v-model="formData.description" :rules="descriptionRules" label="Description"
                            required />

                        <v-text-field v-model="formData.sourceUrl" :rules="urlRules" label="Source URL" required />

                        <v-text-field v-model="formData.moduleName" :rules="moduleNameRules" label="Module Name"
                            hint="Unique identifier for your provider module" required />

                        <v-card-actions>
                            <v-spacer />
                            <v-btn color="primary" :loading="submitting" :disabled="!valid" @click="submit">
                                Submit Provider
                            </v-btn>
                        </v-card-actions>
                    </v-form>
                </v-card-text>
            </v-card>
        </v-col>
    </v-row>
</template>