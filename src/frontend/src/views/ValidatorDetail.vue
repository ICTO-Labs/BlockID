<script setup>
    import { ref, onMounted } from 'vue';
    import { useRoute } from 'vue-router';
    import VerifyService from '@/services/verifyService'
    import { useWalletStore } from '@/store/walletStore'
    import { storeToRefs } from 'pinia'
    import Notify from '@/plugins/notify'
    import Dialog from '@/plugins/dialog'
    
    const walletStore = useWalletStore()
    const { principalId, accountId, balance, isConnected, shortPrincipal } = storeToRefs(walletStore)
    const contentLoading = ref(false);
    const loading = ref(false);
    const validator = ref({
        id: 'decide-ai', 
        title: 'Decide AI', 
        description: 'Got verified with Unique identity verification on DecidedAI.', 
        score: 12, 
        logo: 'https://pbs.twimg.com/profile_images/1787516653145632768/vlRMkJVq_400x400.jpg' 
    });

    const startVerification = async() => {
        const confirm = await Dialog.confirm({
            title: 'Confirmation',
            message: 'Are you sure you want to start verification with DecideAI?',
            color: 'warning',
            icon: 'mdi-alert'
        })
        if(confirm){
            loading.value = true;
            try{
                let result = await VerifyService.getCredential(principalId.value);
                console.log('getCredential result:', result);
                loading.value = false;
                if(result && result.success){
                    Notify.success('You got 15 score when have been verified by DecideAI.', 'Verification successful!')
                }else{
                    Notify.error('You have not verified your unique personhood via DecideAI', 'Verification failed:')
                }
            }catch(error){
                Notify.warning('Verification failed: '+error)
            }finally{
                loading.value = false
            }
        }else{
            loading.value = false
        }
    }
</script>

<template>
        <v-row v-if="!contentLoading">
            <v-col cols="12" md="6">
                <v-card>
                    <v-card-title class="d-flex align-center">
                        <v-avatar size="48" class="mr-4">
                            <v-img :src="validator.logo" :alt="validator.title"></v-img>
                        </v-avatar>
                        {{ validator.title }}
                    </v-card-title>
                    <v-card-text>
                        <p>{{ validator.description }}</p>
                        <v-list>
                            <v-list-item>
                                <template v-slot:prepend>
                                    <v-icon>mdi-star</v-icon>
                                </template>
                                <v-list-item-title>Score: {{ validator.score || 0 }}</v-list-item-title>
                            </v-list-item>
                            <v-list-item>
                                <template v-slot:prepend>
                                    <v-icon>mdi-check-circle</v-icon>
                                </template>
                                <v-list-item-title>Total verified wallets: {{ validator.wallets || 0 }}</v-list-item-title>
                            </v-list-item>
                            <v-list-item>
                                <template v-slot:prepend>
                                    <v-icon>mdi-account-check</v-icon>
                                </template>
                                <v-list-item-title>
                                    Your status: <v-chip color="primary" variant="text">Not verified</v-chip>
                                </v-list-item-title>
                            </v-list-item>
                        </v-list>
                    </v-card-text>
                </v-card>
            </v-col>
            <v-col cols="12" md="6">
                <v-card>
                    <v-card-title><v-icon>mdi-account-check</v-icon> Verification Steps</v-card-title>
                    <v-card-text>
                        <v-timeline side="end"  density="compact">
                            <v-timeline-item
                                class="mb-4"
                                dot-color="grey"
                                size="small"
                                color="primary"
                            >
                                <div class="d-flex justify-space-between flex-grow-1">
                                    <div>
                                        Ensure you have verified your unique personhood via <a href="https://id.decideai.xyz" target="_blank">the DecideAI website</a> <v-icon>mdi-open-in-new</v-icon> <span color="primary" variant="text">before</span> you proceed.
                                    </div>
                                </div>
                            </v-timeline-item>
                            
                            <v-timeline-item  
                                class="mb-4"
                                dot-color="grey"
                                size="small"
                                color="primary">
                                Claim your score on BlockID when connected to the DecideAI
                            </v-timeline-item>
                        </v-timeline>
                    </v-card-text>
                    <v-card-actions>
                        <v-btn color="red" @click="startVerification" block variant="flat" :loading="loading">
                            Start verification 
                        </v-btn>
                    </v-card-actions>
            </v-card>
        </v-col>
    </v-row>
    <v-progress-circular
        v-else
        indeterminate
        color="primary"
    ></v-progress-circular>
</template>