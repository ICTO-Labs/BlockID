<script setup>
    import { ref } from 'vue'
    import authService from '@/services/authService'
    const loading = ref(false)

    const handleConnect = (wallet) => {
        loading.value = true
        authService.connect(wallet)
        loading.value = false
    }
</script>
<template>
    <v-card max-width="400"
        prepend-icon="mdi-wallet"
        title="Connect a wallet"
        >
        <v-card-text>
            <v-form @submit.prevent="handleConnect">
                <v-list>
                    <v-list-item  :loading="loading" @click="handleConnect('internet-identity')" rounded="sm" color="secondary" class="mb-2" active>
                        <template v-slot:prepend>
                            <v-avatar size="48" color="primary-2">
                                <v-img src="https://app.icpswap.com/images/connect/InternetIdentity.svg" />
                            </v-avatar>
                        </template>
                        Internet Identity
                    </v-list-item>
                    <v-list-item @click="handleConnect('plug-wallet')" rounded="sm" color="primary" class="mb-2">
                        <template v-slot:prepend>
                            <v-avatar size="48" color="primary-2">
                                <v-img src="https://app.icpswap.com/images/connect/Plug.svg" />
                            </v-avatar>
                        </template>
                        Plug Wallet
                    </v-list-item>
                    <v-list-item @click="handleConnect('nfid')" rounded="sm" color="primary" class="mb-2">
                        <template v-slot:prepend>
                            <v-avatar size="48" color="primary-2">
                                <v-img src="https://app.icpswap.com/images/connect/NFID.svg" />
                            </v-avatar>
                        </template>
                        NFID
                    </v-list-item>
                </v-list>
            </v-form>
        </v-card-text>
    </v-card>
</template>  
