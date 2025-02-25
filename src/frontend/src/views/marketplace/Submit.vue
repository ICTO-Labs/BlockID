
<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Principal } from '@dfinity/principal'
import { submitProvider } from '@/services/marketplaceService'
import Notify from '@/plugins/notify';
import { useWalletStore } from '@/store/walletStore';
import { storeToRefs } from 'pinia';
const router = useRouter()
const walletStore = useWalletStore();
const { principalId, accountId,isConnected, currentWallet } = storeToRefs(walletStore);

const valid = ref(false)
const submitting = ref(false)

const formData = ref({
    name: '',
    description: '',
    sourceUrl: '',
    moduleName: '',
    canisterId: ''
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

const isPrincipal = (p)=>{
    try {
        return (p === Principal.fromText(p).toText());
    } catch (e) {
        return false;
    }
}
const canisterIdRules = [
    v => !!v || 'Canister id is required',
    v => isPrincipal(v) || 'Canister id is not valid'
]

async function submit() {
    if (!valid.value) return
    if(!isConnected.value){
        Notify.error('Please connect your wallet to submit your provider')
        return
    }
    submitting.value = true
    try {
        const result = await submitProvider(
            formData.value.name,
            formData.value.description,
            formData.value.sourceUrl,
            formData.value.moduleName,
            formData.value.canisterId
        )
        console.log('result', result);
        if (result && 'ok' in result) {
            router.push('/marketplace')
        } else {
            Notify.error('Failed to submit provider:' + JSON.stringify(result))
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
                    <v-alert type="warning">
                        Please provide the following information to submit your module. The BlockID team will review your Provider module and respond soon.
                        If you wish to proceed with your own data, consider creating a remote module using your canister, following the documentation outlined <a href="https://blockid.app/docs#create-new-module" target="_blank">here</a>

                        <p>
                            Make sure to test your module using our <v-btn :to="{ path: '/marketplace/testing' }">Test Environment</v-btn> before submitting.
                        </p>
                    </v-alert>
                    <v-divider class="my-4"></v-divider>
                    <v-form ref="form" v-model="valid">
                        <v-text-field v-model="formData.name" :rules="nameRules" label="Provider Name" required />

                        <v-textarea v-model="formData.description" label="Description"
                            required />

                        <v-text-field v-model="formData.sourceUrl" label="Github Repository URL" required />

                        <v-text-field v-model="formData.moduleName" :rules="moduleNameRules" label="Module Name"
                            hint="Unique identifier for your provider module, e.g. 'providerName'" required />

                        <v-text-field v-model="formData.canisterId" :rules="canisterIdRules" label="Canister ID on Mainnet"
                            hint="Enter your canister id, e.g. 'aaaaa-aa'" required />

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