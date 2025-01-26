<script setup>
    import { ref } from 'vue';
    import authService from '@/services/authService';
    import { useWalletStore } from '@/store/walletStore';
    import { useDialogStore } from '@/store/dialogStore';
    import Notify from '@/plugins/notify';
    const walletStore = useWalletStore();
    const loading = ref({});
    const dialogStore = useDialogStore();
    import { WALLETS } from '@/config';
    import { walletsList } from '@windoge98/plug-n-play';
    // Map available wallets to our WalletInfo structure
    const walletList = walletsList.map(wallet => ({
        id: wallet.id,
        name: wallet.name === "Oisy Wallet" ? "OISY Wallet" : wallet.name,
        icon: wallet.icon,
        description: wallet.id === 'nfid' ? 'Sign in with Google' : undefined
    }));
    const handleConnect = async (walletId) => {
        loading.value[walletId] = true;
        try {
            const _walletInfo = await authService.connect(walletId);
            console.log('_walletInfo', _walletInfo);
            if(_walletInfo && _walletInfo.isConnected){
                dialogStore.closeDialog('connectWallet');
                // walletStore.setWalletInfo(_walletInfo);
            }else{
                Notify.error("Unable to connect to wallet!");
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
                        v-for="wallet in walletList"
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
                            <v-img :src="wallet.icon" />
                        </v-avatar>
                        {{ wallet.name }}
                        <div class="text-caption text-primary ms-2">{{ wallet.description }}</div>
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
