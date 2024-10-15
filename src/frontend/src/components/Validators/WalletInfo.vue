<script setup>
    import { ref, watchEffect, onMounted, computed } from 'vue';
    import { useWalletStore } from '@/store/walletStore';
    import { Principal } from '@dfinity/principal';
    import { storeToRefs } from 'pinia';
    import Copy from '@/components/icons/Copy.vue';
    import { requestLinkWallet, acceptLinkWallet, rejectLinkWallet, getMyLinkedWallets, getPendingLinkRequests, unlinkWallet } from '@/services/backendService';
    import Notify from '@/plugins/notify';
    import Dialog from '@/plugins/dialog';
    const props = defineProps({
        applicationId: {
            type: String,
            required: true
        }
    });
    //trim and check if the principal id is valid
    const linkWalletPrincipalId = ref('');
    // const myLinkedWallets = ref([]);
    const myPendingLinkRequests = ref([]);
    const walletStore = useWalletStore();
    const { principalId, accountId, isConnected, walletScore, currentWallet } = storeToRefs(walletStore);
    const loading = ref(false);
    const getScore = async ()=>{
        if(!isConnected.value) return;
        await walletStore.getUserScore(props.applicationId);
        Notify.success('Score refreshed');
    }
    const myLinkedWallets = ref({
        linkedWallet: '',
        creationTime: 0,
        isPrimary: true,
    })
    const linkWallet = async ()=>{
        const confirm = await Dialog.confirm({
            color: 'warning',
            icon: 'mdi-alert',
            title: 'Link Wallet',
            message: 'Are you sure you want to link this wallet?'
        });
        if(confirm) {
            loading.value = true;
            const res = await requestLinkWallet(Principal.fromText(linkWalletPrincipalId.value.trim()));
            if(res && "ok" in res) {
                await _getMyLinkedWallets();
                Notify.success('Link request sent successfully');
            } else if(res && "err" in res) {
                Notify.error(res.err);
            }
            loading.value = false;
        }
    }
    const _unlinkWallet = async (linkedWallet)=>{
        const confirm = await Dialog.confirm({
            color: 'warning',
            icon: 'mdi-alert',
            title: 'Unlink Wallet',
            message: 'Are you sure you want to unlink this wallet?'
        });
        if(confirm) {
            loading.value = true;
            const secondaryPrincipal = linkedWallet;
            const res = await unlinkWallet(secondaryPrincipal);
            if(res && "ok" in res) {
                _getMyLinkedWallets();
                getScore();
                Notify.success('Wallet unlinked successfully');
            } else if(res && "err" in res) {
                Notify.error(res.err);
            }
            loading.value = false;
        }
    }
    const acceptLink = async (walletId)=>{
        const confirm = await Dialog.confirm({
            color: 'warning',
            icon: 'mdi-alert',
            title: 'Accept Link Request',
            message: 'Are you sure you want to accept this link request?'
        });
        if(confirm) {
            loading.value = true;
            const res = await acceptLinkWallet(walletId);
            if(res && "ok" in res) {
                _getMyLinkedWallets();
                Notify.success('Link accepted successfully');
            } else if(res && "err" in res) {
                Notify.error(res.err);
            }
            loading.value = false;
        }
    }
    const rejectLink = async (walletId)=>{
        const confirm = await Dialog.confirm({
            color: 'warning',
            icon: 'mdi-alert',
            title: 'Reject Link Request',
            message: 'Are you sure you want to reject this link request?'
        });
        if(confirm) {
            loading.value = true;
            const res = await rejectLinkWallet(walletId);
            if(res && "ok" in res) {
                _getMyLinkedWallets();
                Notify.success('Link rejected successfully');
            } else if(res && "err" in res) {
                Notify.error(res.err);
            }
            loading.value = false;
        }
    }

    const _getMyLinkedWallets = async ()=>{
        loading.value = true;
        myLinkedWallets.value = {
            isPrimary: true,
            linkedWallet: '',
            creationTime: 0,
        };
        const _myLinkedWallets = await getMyLinkedWallets();
        if(_myLinkedWallets && _myLinkedWallets.length > 0) {
            myLinkedWallets.value = _myLinkedWallets[0];
        }
        loading.value = false;
        _getMyPendingLinkRequests();
    }
    const _getMyPendingLinkRequests = async ()=>{
        myPendingLinkRequests.value = await getPendingLinkRequests();
    }
    watchEffect(async () => {
        if (isConnected.value) {
            walletStore.getUserScore(props.applicationId);
            _getMyLinkedWallets();
            _getMyPendingLinkRequests();
        }
    });
    onMounted(async ()=>{
        _getMyLinkedWallets();
        _getMyPendingLinkRequests();
    })
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
                    Normal, some applications may require at least 15 points to allow access
                </template>
                <v-card-item>
                        <v-sheet class="d-flex justify-space-between bg-transparent" width="100%">
                            <div class="flex-grow-1 me-2">
                                <div class="text-overline"> Total Score</div>
                                <div class="text-h2 text-orange font-weight-bold">{{ walletScore.totalScore || 0 }}</div>
                            </div>
                            <div class="flex-grow-1">
                                <div class="text-overline"> Your WalletScore</div>
                                <div class="text-green text-h3 font-weight-bold">{{ walletScore.primaryScore || 0 }}</div>
                            </div>
                            <div class="flex-grow-1">
                                <div class="text-overline"> Linked Score</div>
                                <div class="text-green text-h3 font-weight-bold">{{ walletScore.totalScore - walletScore.primaryScore || 0 }}</div>
                            </div>
                        </v-sheet>
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
            </v-card>
        </v-col>
        <v-col cols="12" md="7" v-if="isConnected">
            <v-card height="100%">
                <v-card-title>Connected Wallet 
                    <v-chip label variant="flat" color="primary" size="small">{{ currentWallet }}</v-chip></v-card-title>
                <v-card-text>
                    <v-list-item>
                        <v-list-item class="">Principal ID: {{principalId || '---'}} <Copy :text="principalId" :item="'Principal ID'"/></v-list-item>
                        <v-list-item class="">Account ID: {{accountId || '---'}} <Copy :text="accountId" :item="'Account ID'"/></v-list-item>
                    </v-list-item>
                    
                    <v-list-item>
                        <v-list-item-title>
                            <span v-if="myLinkedWallets && myLinkedWallets.linkedWallet != ''">
                                Linked <span v-if="myLinkedWallets.isPrimary">secondary</span><span v-else> primary </span> wallet
                            </span>
                            <span v-else>
                                Link secondary wallet
                            </span>
                            <v-btn icon="mdi-refresh" size="small" variant="text" @click="_getMyLinkedWallets()"></v-btn>
                        </v-list-item-title>
                            <div v-if="myLinkedWallets.linkedWallet != ''">
                                <v-list-item>
                                    <v-text-field
                                    :loading="loading"
                                    density="compact"
                                    label="Enter principal ID"
                                    hide-details
                                    single-line
                                    v-model="myLinkedWallets.linkedWallet"
                                    readonly
                                    >
                                        <template v-slot:append-inner>
                                            <v-btn variant="flat" color="error" size="small" @click="_unlinkWallet(myLinkedWallets.linkedWallet)" :loading="loading">
                                                Unlink <v-icon>mdi-link-off</v-icon>
                                                <v-tooltip activator="parent" location="top">Unlink</v-tooltip>
                                            </v-btn>
                                        </template>
                                    </v-text-field>
                                </v-list-item>

                                <!-- <table width="100%" class="table table-striped">
                                    <tr v-if="myLinkedWallets && myLinkedWallets.length > 0" v-for="(wallet, index) in myLinkedWallets" :key="index">
                                        <td>{{ wallet[0] }}</td>
                                        <td>
                                            <v-btn variant="flat" class="" color="error" size="small" @click.stop="_unlinkWallet(wallet)" :loading="loading">Unlink <v-icon>mdi-link-off</v-icon></v-btn>
                                        </td>
                                    </tr>
                                </table> -->
                            </div>
                            <div v-else>
                                <v-list-item>
                                    <v-text-field
                                    :loading="loading"
                                    density="compact"
                                    label="Enter principal of secondary wallet"
                                    hide-details
                                    single-line
                                    v-model="linkWalletPrincipalId"
                                    >
                                        <template v-slot:append-inner>
                                            <v-btn variant="flat" color="primary" size="small" @click="linkWallet" :loading="loading">
                                                Link <v-icon>mdi-link</v-icon>
                                                <v-tooltip activator="parent" location="top">Link another wallet</v-tooltip>
                                            </v-btn>
                                        </template>
                                    </v-text-field>
                                </v-list-item>
                                <v-list-item class="text-caption mt-0">
                                    You can link the secondary wallet to your current wallet to increase your score
                                </v-list-item>
                            </div>
                    </v-list-item>
                    <v-list-item v-if="myPendingLinkRequests && myPendingLinkRequests.length > 0">
                        <v-list-item-title>Pending Link Requests <v-btn icon="mdi-refresh" size="small" variant="text" @click="_getMyPendingLinkRequests()"></v-btn></v-list-item-title>
                        <v-list-item >
                            <table width="100%" class="table table-striped">
                                <tr v-if="myPendingLinkRequests && myPendingLinkRequests.length > 0" v-for="wallet in myPendingLinkRequests" :key="wallet.id">
                                    <td>{{ wallet }}</td>
                                    <td>
                                        <v-btn variant="flat" color="primary" size="small" @click.stop="acceptLink(wallet)" class="mr-2" :loading="loading">Accept</v-btn>
                                        <v-btn variant="flat" color="error" size="small" @click.stop="rejectLink(wallet)" :loading="loading">Reject</v-btn>
                                    </td>
                                </tr>
                            </table>
                        </v-list-item>
                        <v-list-item class="text-caption mt-0 text-warning">
                            <v-icon>mdi-information</v-icon> You will share your score with the linked wallet once the link is accepted
                        </v-list-item>
                    </v-list-item>

                    
                </v-card-text>
            </v-card>
        </v-col>
    </v-row>

    <!-- Existing Verification Items Section -->
</template>
