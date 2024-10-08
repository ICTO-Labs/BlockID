<script setup>
import { ref, watchEffect } from 'vue';
import { useWalletStore } from '@/store/walletStore';
import { storeToRefs } from 'pinia';
import { getCurrentWalletScore } from '@/services/backendService';
import { config } from '@/config';
const props = defineProps({
    applicationId: {
        type: String,
        required: true
    }
});
const walletStore = useWalletStore();
const { principalId, accountId, balance, isConnected, shortPrincipal } =
    storeToRefs(walletStore);
const walletScore = ref(0);
const loading = ref(false);
const getScore = async ()=>{
    loading.value = true;
    walletScore.value = await getCurrentWalletScore(
        principalId.value,
        props.applicationId
    );
    loading.value = false;
}
watchEffect(async () => {
    if (isConnected.value) {
        await getScore();
    }
});

const refreshScore = async () => {
    loading.value = true;
    walletScore.value = await getCurrentWalletScore(
        principalId.value,
        props.applicationId
    );
    loading.value = false;
};
</script>
<template>
    <!-- Wallet Information Section -->
    <v-row class="mb-6">
        <v-col cols="12" md="5">
            <v-card color="primary" dark height="100%" :style="{ background: 'linear-gradient(to right, #1e88e5, #ff758c)' }">
                <template v-slot:title>
                    <span class="font-weight-black">Your Score</span>
                    <v-btn
                        icon="mdi-refresh"
                        size="small"
                        variant="text"
                        @click="getScore"
                    >
                        <v-icon>mdi-refresh</v-icon>
                        <v-tooltip activator="parent" location="top"
                            >Refresh</v-tooltip
                        >
                    </v-btn>
                </template>
                <template v-slot:subtitle>
                    Normal, some applications may require at least 15 points to
                    allow access
                </template>
                <v-card-item>
                    <template v-slot:prepend>
                        <v-card-item>
                            <div class="text-h2 mb-2 text-orange font-weight-bold" >
                                {{ walletScore || 0 }}
                            </div>
                            <v-skeleton-loader
                                v-if="loading"
                                class="ma-0 pa-0"
                                max-width="64"
                                max-height="64"
                            ></v-skeleton-loader>
                            <div class="text-subtitle-2">
                                Higher than 90% of verified wallets at {{ applicationId }}
                            </div>
                        </v-card-item>
                    </template>
                    <template v-slot:append>
                        <v-avatar size="64">
                            <v-img
                                src="https://nns.ic0.app/_app/immutable/assets/icp-rounded.0be14f6b.svg"
                            ></v-img>
                        </v-avatar>
                    </template>
                </v-card-item>
            </v-card>
        </v-col>
        <v-col cols="12" md="7">
            <v-card height="100%">
                <v-card-title>Wallet Information</v-card-title>
                <v-card-text>
                    <v-list>
                        <v-list-item>
                            <v-row>
                                <v-col>
                                    <v-list-item>
                                        <v-list-item-title
                                            >Principal</v-list-item-title
                                        >
                                        <v-list-item-subtitle>{{
                                            principalId || '---'
                                        }}</v-list-item-subtitle>
                                    </v-list-item>
                                </v-col>

                                <v-col>
                                    <v-list-item>
                                        <v-list-item-title
                                            >Account Id</v-list-item-title
                                        >
                                        <v-list-item-subtitle>{{
                                            accountId || '---'
                                        }}</v-list-item-subtitle>
                                    </v-list-item>
                                </v-col>
                            </v-row>
                        </v-list-item>
                        <v-list-item>
                            <v-list-item>
                                <v-list-item-title>Balance</v-list-item-title>
                                <v-list-item-subtitle
                                    >{{
                                        balance || '---'
                                    }}
                                    ICP</v-list-item-subtitle
                                >
                            </v-list-item>
                        </v-list-item>
                    </v-list>
                </v-card-text>
            </v-card>
        </v-col>
    </v-row>

    <!-- Existing Verification Items Section -->
</template>
