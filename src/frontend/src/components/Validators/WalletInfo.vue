<script setup>
    import { useWalletStore } from '@/store/walletStore'
    import { storeToRefs } from 'pinia'

    const walletStore = useWalletStore()
    const { principalId, accountId, balance, isConnected, shortPrincipal } = storeToRefs(walletStore)
</script>
<template>
    <!-- Wallet Information Section -->
    <v-row class="mb-6">
        <v-col cols="12" md="4">
            <v-card color="primary" dark height="100%">
                <template v-slot:title>
                    <span class="font-weight-black">Granted Score</span>
                </template>
                <v-card-item>
                    <template v-slot:prepend>
                        <v-card-item>
                            <div class="text-h2 mb-2 text-orange font-weight-bold">16</div>
                            <div class="text-subtitle-2">Higher than 90% of verified wallets</div>
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
        <v-col cols="12" md="8">
            <v-card height="100%">
                <v-card-title>Wallet Information</v-card-title>
                <v-card-text>
                <v-list>
                    <v-list-item>
                        <v-row>
                            <v-col>
                                <v-list-item>
                                    <v-list-item-title>Principal</v-list-item-title>
                                    <v-list-item-subtitle>{{ principalId || '---' }}</v-list-item-subtitle>
                                </v-list-item>
                            </v-col>
                            
                            <v-col>
                                <v-list-item>
                                    <v-list-item-title>Account Id</v-list-item-title>
                                    <v-list-item-subtitle>{{ accountId || '---' }}</v-list-item-subtitle>
                                </v-list-item>
                            </v-col>

                        </v-row>
                    </v-list-item>
                    <v-list-item>
                        <v-list-item>
                            <v-list-item-title>Balance</v-list-item-title>
                            <v-list-item-subtitle>{{ balance || '---' }} ICP</v-list-item-subtitle>
                        </v-list-item>
                    </v-list-item>
                </v-list>
                </v-card-text>
            </v-card>
        </v-col>
</v-row>

<!-- Existing Verification Items Section -->
</template>