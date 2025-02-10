<script setup>
import { ref, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { Principal } from '@dfinity/principal';
import { getWalletDetail, getWalletScore, getValidators } from '@/services/backendService';
import WalletSearch from '@/components/WalletSearch.vue';
const route = useRoute();
const router = useRouter();
const searchQuery = ref(route.params.walletId || '');
const walletId = ref(route.params.walletId);
const wallet = ref(null);
const isLoading = ref(false);
const walletScore = ref({
    totalScore: 0,
    percentileAbove: 0,
    linkedWallet: null,
    linkedScore: 0,
    primaryScore: 0
});
const loading = ref(false);
const searched = ref(false);
// Cache validators data
const validatorsMap = ref(new Map());
const criteriasMap = ref(new Map());

onMounted(async () => {
    await loadValidatorsData();
    if (walletId.value) {
        await loadWalletData();
        await getScore();
    }
});
// Watch route params for changes
watch(() => route.params.walletId, async (newWalletId) => {
    if (newWalletId) {
        resetData();
        walletId.value = newWalletId;
        searchQuery.value = newWalletId;
        await loadWalletData();
        await getScore();
    }
});
// Watch walletId for direct changes
watch(walletId, async () => {
    if (walletId.value) {
        resetData();
        await loadWalletData();
        await getScore();
    }
});

async function getScore() {
    walletId.value = searchQuery.value;
    walletScore.value = await getWalletScore(Principal.fromText(walletId.value));
}
function resetData() {
    wallet.value = null;
    walletScore.value = {
        totalScore: 0,
        percentileAbove: 0,
        linkedWallet: null,
        linkedScore: 0,
        primaryScore: 0
    };
    searched.value = false;
}
async function loadValidatorsData() {
    try {
        const validators = await getValidators();
        
        // Map validators
        validators.forEach(([id, validator]) => {
            validatorsMap.value.set(id, {
                id: validator.id,
                name: validator.name,
                logo: validator.logo,
                description: validator.description,
                applicationId: validator.applicationId
            });

            // Map criterias from each validator
            validator.criterias.forEach(criteria => {
                criteriasMap.value.set(criteria.id, {
                    ...criteria,
                    validatorId: validator.id,
                    validatorName: validator.name
                });
            });
        });
    } catch (error) {
        console.error('Error loading validators:', error);
    }
}

async function loadWalletData() {
    isLoading.value = true;
    try {
        const result = await getWalletDetail(Principal.fromText(walletId.value));
        if (result.ok) {
            wallet.value = result.ok;
            searched.value = true;
        }
    } catch (error) {
        console.error('Error loading wallet data:', error);
    } finally {
        isLoading.value = false;
    }
}

// Helper functions
function getValidatorInfo(validatorId) {
    const validator = validatorsMap.value.get(validatorId);
    return {
        name: validator?.name || validatorId,
        logo: validator?.logo,
        description: validator?.description
    };
}

function getCriteriaInfo(criteriaId) {
    const criteria = criteriasMap.value.get(criteriaId);
    return {
        name: criteria?.name || criteriaId,
        description: criteria?.description,
        score: criteria?.score,
        validatorName: criteria?.validatorName
    };
}

function isExpired(timestamp) {
    if (!timestamp) return false;
    return timestamp < Date.now() * 1000000;
}

function formatDate(timestamp) {
    if (!timestamp) return 'N/A';
    return new Date(Number(timestamp) / 1000000).toLocaleString();
}

function truncatePrincipal(principal) {
    if (!principal) return '';
    return `${principal.slice(0, 5)}...${principal.slice(-5)}`;
}
</script>
<template>
    <v-container>
        <!-- Search Bar -->
        <v-row justify="center" class="mb-8">
            <v-col cols="12" md="10" class="text-center">
                <h1 class="text-h3 mb-6">BlockID Explorer</h1>
                <p class="text-subtitle-1 mb-6">
                    Explore and verify wallet credentials on Internet Computer
                </p>
                <v-card class="mx-auto">
                    <v-card-text>
                        <WalletSearch :initialValue="walletId"/>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>
        <!-- Loading State -->
        <v-row v-if="isLoading" justify="center">
            <v-col cols="12" md="10" class="text-center">
                <v-progress-circular
                    indeterminate
                    color="primary"
                    size="64"
                ></v-progress-circular>
            </v-col>
        </v-row>
        <!-- Wallet Content -->
        <v-row justify="center" v-if="wallet">
            <v-col cols="12" md="10">
                <!-- Wallet Header -->
                <v-card class="mb-6">
                    <v-card-title class="d-flex align-center">
                        <h2>Wallet Explorer</h2>
                        <v-spacer></v-spacer>
                        <v-chip color="primary">
                            Principal ID: {{ truncatePrincipal(walletId) }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ walletId }}
                            </v-tooltip>
                        </v-chip>
                    </v-card-title>

                    <!-- Overall Stats -->
                    <v-card-text>
                        <v-row>
                            <v-col cols="12" sm="4">
                                <v-card variant="outlined">
                                    <v-card-text class="text-center">
                                        <div class="text-h4 mb-2">{{ walletScore.totalScore }}</div>
                                        <div class="text-subtitle-1">Total Score</div>
                                    </v-card-text>
                                </v-card>
                            </v-col>
                            <v-col cols="12" sm="4">
                                <v-card variant="outlined">
                                    <v-card-text class="text-center">
                                        <div class="text-h4 mb-2">{{ walletScore.percentileAbove }}%</div>
                                        <div class="text-subtitle-1">Percentile Above</div>
                                    </v-card-text>
                                </v-card>
                            </v-col>
                            <v-col cols="12" sm="4" v-if="walletScore.linkedWallet">
                                <v-card variant="outlined">
                                    <v-card-text class="text-center">
                                        <div class="text-h4 mb-2">{{ walletScore.linkedScore }}</div>
                                        <div class="text-subtitle-1">Linked Wallet Score</div>
                                    </v-card-text>
                                </v-card>
                            </v-col>
                        </v-row>
                    </v-card-text>
                </v-card>

                <!-- Applications -->
                <div v-for="appScore in wallet.applicationScores" :key="appScore.applicationId" class="mb-6">
                    <!-- Validators Row -->
                    <!-- <v-row class="mb-4">
                        <v-col cols="12">
                            <div class="d-flex flex-wrap gap-4">
                                <v-chip
                                    v-for="validatorScore in appScore.validatorScores"
                                    :key="validatorScore.validatorId"
                                    :prepend-avatar="getValidatorInfo(validatorScore.validatorId).logo"
                                    size="large"
                                    class="pa-4"
                                >
                                    <span class="font-weight-medium">{{ getValidatorInfo(validatorScore.validatorId).name }}</span>
                                    <span class="ml-2 text-primary">({{ validatorScore.totalScore }} points)</span>
                                </v-chip>
                            </div>
                        </v-col>
                    </v-row> -->

                    <!-- Criteria Cards Grid -->
                    <v-row>
                        <template v-for="validatorScore in appScore.validatorScores" :key="validatorScore.validatorId">
                            <v-col v-for="criteria in validatorScore.criteriaScores" 
                                  :key="criteria.criteriaId"
                                  cols="12" sm="6" md="4">
                                <v-card class="h-100" :class="{'expired-card': isExpired(criteria.expirationTime)}">
                                    <v-card-item>
                                        <template v-slot:prepend>
                                            <v-avatar
                                                :image="getValidatorInfo(validatorScore.validatorId).logo"
                                                size="32"
                                            ></v-avatar>
                                        </template>
                                        <v-card-title>
                                            {{ getCriteriaInfo(criteria.criteriaId).name }}
                                        </v-card-title>
                                        <v-card-subtitle>
                                            {{ getValidatorInfo(validatorScore.validatorId).name }}  
                                            <v-chip
                                                :color="isExpired(criteria.expirationTime) ? 'error' : 'success'"
                                                size="small"
                                                variant="tonal"
                                            >
                                                {{ criteria.score }} Points
                                            </v-chip>
                                        </v-card-subtitle>
                                    </v-card-item>

                                    <v-card-text>
                                        <v-divider class="my-2"></v-divider>
                                        
                                        <div class="d-flex align-center justify-space-between mt-2">
                                            <div class="text-caption">
                                                <v-icon size="small" color="success" class="mr-1">
                                                    mdi-check-circle
                                                </v-icon>
                                                Verified {{ formatDate(criteria.verificationTime) }}
                                            </div>
                                            
                                        </div>
                                        
                                        <div v-if="criteria.expirationTime" class="text-caption mt-2">
                                            <v-icon size="small" :color="isExpired(criteria.expirationTime) ? 'error' : 'warning'" class="mr-1">
                                                mdi-clock-outline
                                            </v-icon>
                                            {{ isExpired(criteria.expirationTime) ? 'Expired' : 'Expires' }}: 
                                            {{ formatDate(criteria.expirationTime) }}
                                        </div>
                                    </v-card-text>
                                </v-card>
                            </v-col>
                        </template>
                    </v-row>
                </div>
            </v-col>
        </v-row>

        <!-- No Data Message -->
        <v-row v-else-if="searched && !isLoading" justify="center">
            <v-col cols="12" md="10" class="text-center">
                <v-alert type="warning">
                    No verification data found for this wallet
                </v-alert>
            </v-col>
        </v-row>
    </v-container>
</template>


<style scoped>
.expired-card {
    opacity: 0.7;
    border: 1px solid rgb(var(--v-theme-error));
}

.gap-4 {
    gap: 1rem;
}

/* Responsive adjustments */
@media (max-width: 600px) {
    .gap-4 {
        gap: 0.5rem;
    }
}
</style>