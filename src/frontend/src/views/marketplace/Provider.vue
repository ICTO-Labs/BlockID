
<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useWalletStore } from '@/store/walletStore'
import { getProvider } from '@/services/marketplaceService'

const route = useRoute()
const { marketplaceActor } = "";
const walletStore = useWalletStore()

const provider = ref(null)
const error = ref(null)
const processing = ref(false)

onMounted(async () => {
    console.log('route.params.providerId', route.params.providerId);
    error.value = null;
    const result = await getProvider(route.params.providerId)
    console.log('result', result);
    if(result){ 
        provider.value = result[0];
    }else{
        error.value= "Provider not found!";
    }
})

async function reviewProvider(status) {
    processing.value = true
    try {
        const result = await marketplaceActor.reviewProvider(
            provider.value.id,
            { [status.toLowerCase()]: null },
            null,
            null
        )
        if ('ok' in result) {
            provider.value.status = `#${status}`
        }
    } catch (err) {
        console.error('Failed to review provider:', err)
    }
    processing.value = false
}
const getStatusColor = (status) => {
    switch (status) {
        case 'Approved': return 'success'
        case 'Pending': return 'warning'
        case 'Rejected': return 'error'
        default: return 'grey'
    }
}
const getVariantType = (variant) => {
    try{
        return Object.keys(variant)[0];
    }catch(e){
        return '---';
    }
}
</script>
<template>
        <v-row>
            <v-alert v-if="error" type="error">
                {{ error }}
            </v-alert>
            <v-col cols="12" v-else>
                <v-card>
                    <v-card-title class="d-flex justify-space-between align-center">
                        <div>
                            <h2 class="text-h5">Module name: {{ provider?.name }}</h2>
                            <v-chip :color="getStatusColor(getVariantType(provider?.status))" class="mt-2">
                                {{ getVariantType(provider?.status) }}
                            </v-chip>
                        </div>

                        <!-- Admin Actions -->
                        <div v-if="isAdmin && provider?.status === '#Pending'">
                            <v-btn color="success" class="mr-2" :loading="processing"
                                @click="reviewProvider('Approved')">
                                Approve
                            </v-btn>
                            <v-btn color="error" :loading="processing" @click="reviewProvider('Rejected')">
                                Reject
                            </v-btn>
                        </div>

                        <v-btn color="default" :to="{ path: '/marketplace' }">
                            <v-icon left>mdi-arrow-left</v-icon>
                            Marketplace
                        </v-btn>
                    </v-card-title>

                    <v-card-text>
                        <v-row>
                            <v-col cols="12" md="8">
                                <div class="mb-4">
                                    <h3 class="text-h6">Description</h3>
                                    <p>{{ provider?.description }}</p>
                                </div>

                                <div class="mb-4">
                                    <h3 class="text-h6">Module Information</h3>
                                    <v-list dense>
                                        <v-list-item>
                                            <v-list-item-content>
                                                <v-list-item-title>Module Name</v-list-item-title>
                                                <v-list-item-subtitle>{{ provider?.moduleName }}</v-list-item-subtitle>
                                            </v-list-item-content>
                                        </v-list-item>

                                        <v-list-item>
                                            <v-list-item-content>
                                                <v-list-item-title>Source URL</v-list-item-title>
                                                <v-list-item-subtitle>
                                                    <a :href="provider?.sourceUrl" target="_blank">
                                                        {{ provider?.sourceUrl }}
                                                    </a> <v-icon>mdi-open-in-new</v-icon>
                                                </v-list-item-subtitle>
                                            </v-list-item-content>
                                        </v-list-item>

                                        <v-list-item>
                                            <v-list-item-content>
                                                <v-list-item-title>Owner</v-list-item-title>
                                                <v-list-item-subtitle>{{ provider?.owner }}</v-list-item-subtitle>
                                            </v-list-item-content>
                                        </v-list-item>

                                        <v-list-item>
                                            <v-list-item-content>
                                                <v-list-item-title>Submitted At</v-list-item-title>
                                                <v-list-item-subtitle>
                                                    {{ new Date(Number(provider?.submittedAt) /
                                                    1000000).toLocaleString() }}
                                                </v-list-item-subtitle>
                                            </v-list-item-content>
                                        </v-list-item>
                                    </v-list>
                                </div>

                                <div v-if="provider?.reviewNote" class="mb-4">
                                    <h3 class="text-h6">Review Note</h3>
                                    <p>{{ provider.reviewNote? provider.reviewNote.length > 0 ? provider.reviewNote : 'No review note' : 'No review note' }}</p>
                                </div>
                            </v-col>
                        </v-row>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>
</template>
