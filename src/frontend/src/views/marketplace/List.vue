

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useWalletStore } from '@/store/walletStore'
import { listProviders, reviewProvider, getMyProviders } from '@/services/marketplaceService'
import Dialog from '@/plugins/dialog'
import Notify from '@/plugins/notify'
const walletStore = useWalletStore()
const loading = ref(false)
const providers = ref([])
const myProviders = ref([])
const approvedHeaders = [
    { title: 'Name', value: 'name' },
    { title: 'Description', value: 'description' },
    { title: 'Module', value: 'moduleName' },
    { title: 'Status', value: 'status' },
    { title: 'Actions', value: 'actions' }
]
const pendingHeaders = [
    { title: 'Name', value: 'name' },
    { title: 'Description', value: 'description' },
    { title: 'Module', value: 'moduleName' },
    { title: 'Status', value: 'status' },
    { title: 'Owner', value: 'owner' },
    { title: 'Source', value: 'sourceUrl' },
    { title: 'Actions', value: 'actions' }
]
const myHeaders = [
    { title: 'Name', value: 'name' },
    { title: 'Description', value: 'description' },
    { title: 'Module', value: 'moduleName' },
    { title: 'Status', value: 'status' },
    { title: 'Source', value: 'sourceUrl' },
    { title: 'reviewNote', value: 'reviewNote' },
    { title: 'Actions', value: 'actions' }
]
// Computed properties for filtering
const approvedProviders = computed(() =>
    providers.value.filter(p => getVariantType(p.status) === 'Approved')
)

const pendingProviders = computed(() =>
    providers.value.filter(p => getVariantType(p.status) === 'Pending')
)

const reloadProviders = async () => {
    providers.value = []
    myProviders.value = []
    loading.value = true
    providers.value = await listProviders()
    myProviders.value = await getMyProviders()
    loading.value = false
}

// Load providers
onMounted(async () => {
    loading.value = true
    try {
        reloadProviders()
    } catch (err) {
        console.error('Failed to load providers:', err)
    }
    loading.value = false
})

// Helper functions
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

const approve = async (id) => {
    const confirm = await Dialog.confirm({
        title: 'Approve Provider',
        message: 'Are you sure you want to approve this provider?',
        color: 'success',
        icon: 'mdi-check'
    })
    if(confirm){
        Dialog.showLoading('Approving provider...');
        let _rs = await reviewProvider(id, {Approved: null});
        if(_rs && "ok" in _rs){
            Notify.success('Provider approved successfully');
        } else {
            Notify.error(_rs.err);
        }
        Dialog.closeLoading()
        reloadProviders()
    }
}

const reject = async (id) => {
    const confirm = await Dialog.confirm({
        title: 'Reject Provider',
        message: 'Are you sure you want to reject this provider?',
        color: 'error',
        icon: 'mdi-close'
    })
    if(confirm){
        Dialog.showLoading('Rejecting provider...');
        let _rs = await reviewProvider(id, {Rejected: null});
        if(_rs && "ok" in _rs){
            Notify.success('Provider rejected successfully');
        } else {
            Notify.error(_rs.err);
        }
        Dialog.closeLoading()
        reloadProviders()
    }
}
</script>
<template>
    <v-row>
        <v-col cols="12">
            <div class="d-flex justify-space-between align-center mb-6">
                <h1 class="text-h6">Provider Marketplace</h1>
                <div>
                    <v-btn color="primary" :to="{ path: '/marketplace/submit' }">
                        Submit Provider <v-icon>mdi-plus</v-icon>
                    </v-btn>
                    <v-btn color="default" @click="reloadProviders" class="ms-2">
                        Refresh <v-icon>mdi-refresh</v-icon>
                    </v-btn>
                </div>
                </div>

                <!-- Approved Providers Section -->
                <v-card class="mb-6">
                    <v-card-title class="d-flex align-center">
                        <v-icon left>mdi-check-circle</v-icon>
                        Approved Providers
                    </v-card-title>
                    <v-card-text>
                        <v-data-table :headers="approvedHeaders" :items="approvedProviders" :loading="loading">
                            <template v-slot:item.status="{ item }">
                                <v-chip :color="getStatusColor(getVariantType(item.status))" small>
                                    {{ getVariantType(item.status) }}
                                </v-chip>
                            </template>

                            <template v-slot:item.actions="{ item }">
                                <v-btn small text color="primary"
                                    :to="{ name: 'Provider', params: { providerId: item.id } }">
                                    View
                                </v-btn>
                            </template>
                        </v-data-table>
                    </v-card-text>
                </v-card>

                <v-card>
                    <v-card-title class="d-flex align-center">
                        <v-icon left>mdi-account-details</v-icon>
                        My Providers
                    </v-card-title>
                    <v-card-text>
                        <v-data-table :headers="myHeaders" :items="myProviders" :loading="loading">
                            <template v-slot:item.status="{ item }">
                                <v-chip :color="getStatusColor(getVariantType(item.status))" small>
                                    {{ getVariantType(item.status) }}
                                </v-chip>
                            </template>

                            <template v-slot:item.reviewNote="{ item }">
                                {{ item.reviewNote ? item.reviewNote.length > 0 ? item.reviewNote : '--' : 'No review note' }}
                            </template>
                            <template v-slot:item.actions="{ item }">
                                <v-btn small text color="primary"
                                    :to="{ name: 'Provider', params: { providerId: item.id } }">
                                    View
                                </v-btn>
                            </template>
                        </v-data-table>
                    </v-card-text>
                </v-card>
                <!-- Pending Providers Section (Admin Only) -->
                <v-card>
                    <v-card-title class="d-flex align-center">
                        <v-icon left>mdi-clock-outline</v-icon>
                        Pending Review (Team Only)
                    </v-card-title>
                    <v-card-text>
                        <v-data-table :headers="pendingHeaders" :items="pendingProviders" :loading="loading">
                            <template v-slot:item.status="{ item }">
                                <v-chip :color="getStatusColor(item.status)" small>
                                    {{ getVariantType(item.status) }}
                                </v-chip>
                            </template>

                            <template v-slot:item.actions="{ item }">
                                <v-btn small text color="success" class="me-2"
                                    @click="approve(item.id)">
                                    <v-icon>mdi-check</v-icon>
                                    Approved
                                </v-btn>
                                <v-btn small text color="error"
                                    @click="reject(item.id)">
                                    <v-icon>mdi-close</v-icon>
                                    
                                </v-btn>
                            </template>
                        </v-data-table>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>
</template>