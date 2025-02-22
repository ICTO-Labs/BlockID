<!-- pages/marketplace/admin/index.vue -->
<template>
    <v-container>
        <v-row>
            <v-col cols="12">
                <div class="d-flex justify-space-between align-center mb-6">
                    <h1 class="text-h4">Marketplace Administration</h1>
                </div>

                <!-- Stats Overview -->
                <v-row class="mb-6">
                    <v-col cols="12" md="3">
                        <v-card>
                            <v-card-text class="text-center">
                                <div class="text-h4 mb-2">{{ stats.totalProviders }}</div>
                                <div class="text-subtitle-1">Total Providers</div>
                            </v-card-text>
                        </v-card>
                    </v-col>
                    <v-col cols="12" md="3">
                        <v-card>
                            <v-card-text class="text-center">
                                <div class="text-h4 mb-2">{{ stats.pendingReview }}</div>
                                <div class="text-subtitle-1">Pending Review</div>
                            </v-card-text>
                        </v-card>
                    </v-col>
                    <v-col cols="12" md="3">
                        <v-card>
                            <v-card-text class="text-center">
                                <div class="text-h4 mb-2">{{ stats.approved }}</div>
                                <div class="text-subtitle-1">Approved</div>
                            </v-card-text>
                        </v-card>
                    </v-col>
                    <v-col cols="12" md="3">
                        <v-card>
                            <v-card-text class="text-center">
                                <div class="text-h4 mb-2">{{ stats.rejected }}</div>
                                <div class="text-subtitle-1">Rejected</div>
                            </v-card-text>
                        </v-card>
                    </v-col>
                </v-row>

                <!-- Submissions Management -->
                <v-card class="mb-6">
                    <v-card-title class="d-flex align-center">
                        <v-icon left>mdi-format-list-bulleted</v-icon>
                        Provider Submissions
                    </v-card-title>

                    <v-card-text>
                        <v-data-table :headers="submissionHeaders" :items="submissions" :loading="loading"
                            :search="search">
                            <template v-slot:top>
                                <v-text-field v-model="search" label="Search" prepend-inner-icon="mdi-magnify"
                                    single-line hide-details class="mx-4" />
                            </template>

                            <template v-slot:item.status="{ item }">
                                <v-chip :color="getStatusColor(item.status)" small>
                                    {{ item.status }}
                                </v-chip>
                            </template>

                            <template v-slot:item.actions="{ item }">
                                <v-btn small text color="primary" class="mr-2" @click="viewDetails(item)">
                                    View
                                </v-btn>
                                <v-btn v-if="item.status === '#Pending'" small text color="success" class="mr-2"
                                    @click="approveProvider(item)">
                                    Approve
                                </v-btn>
                                <v-btn v-if="item.status === '#Pending'" small text color="error"
                                    @click="rejectProvider(item)">
                                    Reject
                                </v-btn>
                            </template>
                        </v-data-table>
                    </v-card-text>
                </v-card>

                <!-- Admin Management -->
                <v-card>
                    <v-card-title class="d-flex align-center">
                        <v-icon left>mdi-account-cog</v-icon>
                        Admin Management
                        <v-spacer></v-spacer>
                        <v-btn color="primary" @click="showAddAdminDialog = true">
                            Add Admin
                        </v-btn>
                    </v-card-title>

                    <v-card-text>
                        <v-data-table :headers="adminHeaders" :items="admins" :loading="loadingAdmins">
                            <template v-slot:item.actions="{ item }">
                                <v-btn small text color="error" @click="removeAdmin(item)"
                                    :disabled="item.principal === currentPrincipal">
                                    Remove
                                </v-btn>
                            </template>
                        </v-data-table>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>

        <!-- Add Admin Dialog -->
        <v-dialog v-model="showAddAdminDialog" max-width="500px">
            <v-card>
                <v-card-title>Add New Admin</v-card-title>
                <v-card-text>
                    <v-text-field v-model="newAdminPrincipal" label="Principal ID" :rules="principalRules" />
                </v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="primary" text @click="addAdmin" :loading="processingAdmin">
                        Add
                    </v-btn>
                    <v-btn text @click="showAddAdminDialog = false">
                        Cancel
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </v-container>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useWalletStore } from '@/store/walletStore'
import { useRouter } from 'vue-router'

const router = useRouter()
const { marketplaceActor } = ""
const walletStore = useWalletStore()

// Data
const loading = ref(false)
const loadingAdmins = ref(false)
const search = ref('')
const submissions = ref([])
const admins = ref([])
const showAddAdminDialog = ref(false)
const newAdminPrincipal = ref('')
const processingAdmin = ref(false)

// Stats
const stats = computed(() => ({
    totalProviders: submissions.value.length,
    pendingReview: submissions.value.filter(s => s.status === '#Pending').length,
    approved: submissions.value.filter(s => s.status === '#Approved').length,
    rejected: submissions.value.filter(s => s.status === '#Rejected').length
}))

// Table headers
const submissionHeaders = [
    { text: 'Name', value: 'name' },
    { text: 'Module', value: 'moduleName' },
    { text: 'Owner', value: 'owner' },
    { text: 'Submitted', value: 'submittedAt' },
    { text: 'Status', value: 'status' },
    { text: 'Actions', value: 'actions', sortable: false }
]

const adminHeaders = [
    { text: 'Principal', value: 'principal' },
    { text: 'Added Date', value: 'addedAt' },
    { text: 'Actions', value: 'actions', sortable: false }
]

// Load data
onMounted(async () => {
    await Promise.all([
        loadSubmissions(),
        loadAdmins()
    ])
})

async function loadSubmissions() {
    loading.value = true
    try {
        const result = await marketplaceActor.listProviders()
        submissions.value = result
    } catch (err) {
        console.error('Failed to load submissions:', err)
    }
    loading.value = false
}

async function loadAdmins() {
    loadingAdmins.value = true
    try {
        const result = await marketplaceActor.listAdmins()
        admins.value = result
    } catch (err) {
        console.error('Failed to load admins:', err)
    }
    loadingAdmins.value = false
}

// Actions
async function approveProvider(provider) {
    try {
        await marketplaceActor.reviewProvider(
            provider.id,
            { approved: null },
            null,
            null
        )
        await loadSubmissions()
    } catch (err) {
        console.error('Failed to approve provider:', err)
    }
}

async function rejectProvider(provider) {
    try {
        await marketplaceActor.reviewProvider(
            provider.id,
            { rejected: null },
            null,
            null
        )
        await loadSubmissions()
    } catch (err) {
        console.error('Failed to reject provider:', err)
    }
}

async function addAdmin() {
    processingAdmin.value = true
    try {
        await marketplaceActor.addAdmin(newAdminPrincipal.value)
        await loadAdmins()
        showAddAdminDialog.value = false
        newAdminPrincipal.value = ''
    } catch (err) {
        console.error('Failed to add admin:', err)
    }
    processingAdmin.value = false
}

async function removeAdmin(admin) {
    try {
        await marketplaceActor.removeAdmin(admin.principal)
        await loadAdmins()
    } catch (err) {
        console.error('Failed to remove admin:', err)
    }
}

function viewDetails(provider) {
    router.push(`/marketplace/provider/${provider.id}`)
}

// Helpers
const getStatusColor = (status) => {
    switch (status) {
        case '#Approved': return 'success'
        case '#Pending': return 'warning'
        case '#Rejected': return 'error'
        default: return 'grey'
    }
}

const principalRules = [
    v => !!v || 'Principal is required',
    v => /^[a-zA-Z0-9-]+$/.test(v) || 'Invalid principal format'
]
</script>