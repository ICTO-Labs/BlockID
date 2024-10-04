<script setup>
import { ref } from 'vue';
import authService from '@/services/authService';
import { useWalletStore } from '@/store/walletStore';
import { useDialogStore } from '@/store/dialogStore';
const walletStore = useWalletStore();
const loading = ref({});
const dialogStore = useDialogStore();
import { WALLETS } from '@/config';
const handleConnect = async (walletId) => {
    loading.value[walletId] = true;
    try {
        const _walletInfo = await authService.connect(walletId);
        if(_walletInfo.success){
            dialogStore.closeDialog('connectWallet');
            walletStore.setWalletInfo(_walletInfo);
        }
    } catch (error) {
        console.error('Error:', error);
    } finally {
        loading.value[walletId] = false;
    }
};
</script>
<template>
    <v-card max-width="600" prepend-icon="mdi-wallet" title="Connect a wallet">
        <v-divider></v-divider>
        <v-card-text>
            <v-row>
                <v-col cols="12" sm="6" md="12">
                    <v-btn
                        v-for="wallet in WALLETS"
                        :key="wallet.id"
                        block
                        class="mb-4"
                        variant="elevated"
                        :color="wallet.default === true ? 'primary' : ''"
                        @click="handleConnect(wallet.id)"
                        :loading="loading[wallet.id]"
                        rounded="lg"
                        size="large"
                    >
                        <v-avatar size="32" class="mr-4">
                            <v-img :src="wallet.logo" />
                        </v-avatar>
                        {{ wallet.name }}
                    </v-btn>
                </v-col>
            </v-row>
        </v-card-text>
    </v-card>
</template>
<style scoped>
.v-btn {
    justify-content: flex-start;
}
</style>
