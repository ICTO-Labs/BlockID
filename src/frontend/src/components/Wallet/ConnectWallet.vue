<script setup>
import { ref } from 'vue';
import authService from '@/services/authService';
import { useWalletStore } from '@/store/walletStore';
const walletStore = useWalletStore();
const loading = ref({});

const wallets = [
    {
        name: 'Internet Identity',
        logo: 'https://app.icpswap.com/images/connect/InternetIdentity.svg',
        id: 'internet-identity',
        default: true
    },
    {
        name: 'Plug Wallet',
        logo: 'https://app.icpswap.com/images/connect/Plug.svg',
        id: 'plug-wallet',
        default: false
    },
    {
        name: 'NFID',
        logo: 'https://app.icpswap.com/images/connect/NFID.svg',
        id: 'nfid',
        default: false
    }
];

const handleConnect = async (walletId) => {
    loading.value[walletId] = true;
    try {
        let result;
        switch (walletId) {
            case 'internet-identity':
                result = await authService.InternetIdentity();
                console.log(result, 'result');
                if (result && result.success) {
                    walletStore.setWalletInfo({
                        principalId: result.principalId,
                        accountId: result.accountId,
                        balance: 10.25,
                        wallet: {
                            id: walletId,
                            name: wallets.find((w) => w.id === walletId).name
                        }
                    });
                }
                break;
            case 'nfid':
                result = await authService.Nfid();
                console.log(result, 'result');
                break;
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
                        v-for="wallet in wallets"
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
