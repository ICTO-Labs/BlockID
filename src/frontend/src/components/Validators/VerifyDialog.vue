<script setup>
    import { ref, onMounted, watchEffect } from 'vue';
    import VerifyService from '@/services/verifyService';
    import { useWalletStore } from '@/store/walletStore';
    import { getValidatorById } from '@/services/backendService';
    import { storeToRefs } from 'pinia';
    import Notify from '@/plugins/notify';
    import Dialog from '@/plugins/dialog';
    const props = defineProps({
        validatorId: {
            type: String,
            required: true
        }
    });
    const isLoading = ref(true);
    const walletStore = useWalletStore();
    const { principalId, accountId, balance, isConnected, shortPrincipal } = storeToRefs(walletStore);
    const loading = ref(false);
    const verifyData = ref({
        score: 0,
        verified: false
    })
    const validator = ref(null);

    const startVerification = async () => {
        if(!isConnected.value){
            Dialog.connectWallet()
            return
        }
        const confirm = await Dialog.confirm({
                title: 'Confirmation',
                message: 'Are you sure you want to start verification with DecideAI?',
                color: 'warning',
                icon: 'mdi-alert'
        })
        if(confirm){
            loading.value = true;
            try{
                Dialog.showLoading('Verifying your identity...')
                let result = await VerifyService.getCredential(principalId.value);
                console.log('getCredential result:', result);
                loading.value = false;
                Dialog.closeLoading()
                if(result && result.success){
                    Notify.success('Verification successful: You got 12 points from DecideAI validator')
                    verifyData.value.score = 12
                    verifyData.value.verified = true
                }else{
                    Notify.error('Verification failed: You have not verified your unique personhood via DecideAI')
                }
            }catch(error){
                Notify.warning('Verification failed: '+error)
                verifyData.value.verified = true
            }finally{
                loading.value = false
                Dialog.closeLoading()
            }
        }else{
            loading.value = false
        }
    };
    const closeDialog = ()=>{
        Dialog.close('verifyDialog')
    }
    watchEffect(()=>{
        if(props.validatorId){
            getValidatorById(props.validatorId).then((response) => {
                console.log('validator:', response)
                validator.value = response?.[0]
                isLoading.value = false
            })
        }
    })
</script>

<template>
    <v-card v-if="isLoading">
        <v-skeleton-loader class="mx-auto" elevation="12" max-width="400"
            type="table-heading, list-item-two-line, image, table-tfoot"></v-skeleton-loader>
    </v-card>
    <v-card v-else>
        <template v-slot:prepend>
            <v-avatar size="48">
                <v-img :alt="validator.name" :src="validator.logo"></v-img>
            </v-avatar>
        </template>
        <template v-slot:title>
            {{ validator.name }}
            <v-chip label size="small" color="warning" prepend-icon="mdi-account-cancel" variant="outlined"
                v-if="!verifyData.verified">
                <span class="text-primary1">Not verified</span>
            </v-chip>
            <v-chip label size="small" color="success" prepend-icon="mdi-account-check" variant="outlined" v-else>
                <span class="text-primary1">Verified</span>
            </v-chip>
        </template>
        <template v-slot:subtitle>
            <v-card-text class="py-1 px-0">
                <v-chip class="ma-0" color="warning" size="small" prepend-icon="mdi-star">
                    {{ validator.totalScore || 0 }} Points
                </v-chip>
                <v-chip class="ms-2 ma-0" color="success" size="small" variant="outlined"
                    prepend-icon="mdi-check-decagram" v-if="validator?.verifyMethod?.VcFlow == null">
                    VCFlow
                </v-chip>
                <v-chip class="ms-2 ma-0" size="small" prepend-icon="mdi-account-multiple-check">
                    {{ validator.wallets || 0 }} Verified wallets
                </v-chip>
            </v-card-text>
        </template>
        <v-card-text class="py-0">
            <p>{{ validator.description }}</p>
        </v-card-text>
        <v-card-text>
            <v-timeline side="end" density="compact">
                <v-timeline-item class="mb-4" dot-color="grey" size="small" color="primary">
                    <div class="d-flex justify-space-between flex-grow-1">
                        <div>
                            Ensure you have verified your unique personhood via <a href="https://id.decideai.xyz"
                                target="_blank">the DecideAI website</a> <v-icon>mdi-open-in-new</v-icon> <span
                                color="primary" variant="text">before</span> you proceed.
                        </div>
                    </div>
                </v-timeline-item>

                <v-timeline-item class="mb-4" dot-color="grey" size="small" color="primary">
                    Claim your score on BlockID when connected to the DecideAI
                </v-timeline-item>
            </v-timeline>
        </v-card-text>
        <v-expansion-panels>
            <v-expansion-panel>
                <v-expansion-panel-title>Proof of Unique Person</v-expansion-panel-title>
                <v-expansion-panel-text class="fs-11">
                    Provide the "Unique Person" verifiable credential
                </v-expansion-panel-text>
            </v-expansion-panel>
        </v-expansion-panels>
        
        <v-divider></v-divider>
        <v-card-actions>
            <v-btn text="Cancel" variant="plain" @click="closeDialog"></v-btn>
            <v-btn color="primary" @click="startVerification" :loading="loading" variant="tonal">
                Start verification
            </v-btn>
        </v-card-actions>
    </v-card>
</template>