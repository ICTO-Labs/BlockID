<script setup>
    import { ref, onMounted, watchEffect, computed } from 'vue';
    import { Principal } from '@dfinity/principal';
    import VerifyService from '@/services/verifyService';
    import { useWalletStore } from '@/store/walletStore';
    import { getValidator, verifyByCriteria, verifyByValidator, getVerifiedCriteria } from '@/services/backendService';
    import { storeToRefs } from 'pinia';
    import Notify from '@/plugins/notify';
    import Dialog from '@/plugins/dialog';
    import VcFlow from '@/components/icons/VcFlow.vue';
    import { getProviderParams } from '@/plugins/vcflow';
    const props = defineProps({
        applicationId: {
            type: String,
            required: true
        },
        validatorId: {
            type: String,
            required: true
        }
    });
    const isLoading = ref(true);
    const verifiedCriterias = ref({});
    const walletStore = useWalletStore();
    const { principalId, accountId, balance, isConnected, shortPrincipal } =
        storeToRefs(walletStore);
    const loading = ref(false);
    const verifyData = ref({
        score: 0,
        verified: false
    });
    const validator = ref(null);

    const startVerification = async (criteriaId) => {
        console.log('startVerification:', criteriaId);
        if (!isConnected.value) {
            Dialog.connectWallet();
            return;
        }
        loading.value = true;
        try {
            Dialog.showLoading('Verifying your wallet...');
            let _result = null;
            switch(criteriaId) {
                case null:
                case undefined:
                _result = await verifyByValidator(props.applicationId, props.validatorId);
                    break;
                default:
                    _result = await verifyByCriteria(props.applicationId, props.validatorId, [criteriaId]);
                    break;
            }
            if(_result && _result.ok > 0) {
                Notify.success('Verification successful: You got ' + _result.ok + ' points from ' + validator.value.name + ' validator');
            }else{
                Notify.error('Verification failed: Please try again');
            }
            getVerifiedData();
            loading.value = false;
            Dialog.closeLoading();
        } catch (error) {
            Notify.warning('Verification failed: ' + error);
        }
    };



    const verifyVC = async (criteria) => {
        console.log('criteria:', criteria);
        if (!isConnected.value) {
            Dialog.connectWallet();
            return;
        }
        if (!criteria.isVC) {
            Notify.error(
                'Sorry, ' + validator.value.name + ' does not support VC Flow'
            );
            return;
        }
        const providerArgs = getProviderParams(criteria.providerArgs);
        const providerParams = getProviderParams(criteria.providerParams);
        console.log('providerParams:', providerParams);
        const confirm = await Dialog.confirm({
            title: 'Confirmation',
            message:
                'Are you sure you want to start verification for criteria: ' +
                criteria.name +
                '?',
            color: 'warning',
            icon: 'mdi-alert'
        });
        if (confirm) {
            loading.value = true;
            try {
                Dialog.showLoading('Verifying your identity...');
                let _issuerData = {
                    issuerOrigin: criteria.issuerOrigin
                };
                let _validateData = {
                    application_id: props.applicationId,
                    validator_id: props.validatorId,
                    criterial_id: criteria.id,
                    wallet_id: principalId.value
                }
                console.log('validateData:', _validateData);
                let result = await VerifyService.getCredential(
                    principalId.value,
                    providerParams,
                    providerArgs,
                    _validateData
                );
                console.log('getCredential result:', result);
                loading.value = false;
                Dialog.closeLoading();
                if (result && result.success) {
                    Notify.success(
                        'Verification successful: You got '+criteria.score+' points from '+validator.value.name+' validator'
                    );
                    verifyData.value.score = criteria.score;
                    verifyData.value.verified = true;
                } else {
                    Notify.error(
                        'Verification failed: The validator returned an error, please try again later!'
                    );
                }
            } catch (error) {
                Notify.warning('Verification failed: ' + error);
                verifyData.value.verified = true;
            } finally {
                loading.value = false;
                Dialog.closeLoading();
            }
        } else {
            loading.value = false;
        }
    };
    const closeDialog = () => {
        Dialog.close('verifyDialog');
    };
    const getVerifiedData = async () => {
        loading.value = true;
        let _data = await getVerifiedCriteria(props.applicationId, props.validatorId, Principal.fromText(principalId.value));
        //Convert to object
        verifiedCriterias.value = _data.reduce((acc, curr) => {
            acc[curr] = true;
            return acc;
        }, {});
        loading.value = false;
    };


    watchEffect(() => {
        if (props.validatorId) {
            getVerifiedData();
            getValidator(props.validatorId).then((response) => {
                console.log('validator:', response);
                validator.value = 'ok' in response ? response.ok : null;
                isLoading.value = false;
            });
        }
    });
</script>

<template>
    <v-card v-if="isLoading">
        <v-skeleton-loader
            class="mx-auto w-100"
            elevation="12"
            type="table-heading, list-item-two-line, image, table-tfoot"
        ></v-skeleton-loader>
    </v-card>
    <v-card v-else>
        <template v-slot:prepend>
            <v-avatar size="48">
                <v-img :alt="validator.name" :src="validator.logo"></v-img>
            </v-avatar>
        </template>
        <template v-slot:title>
            {{ validator.name }}

            <v-chip
                label
                class="ma-0 fw-bold float-right"
                size="small"
                prepend-icon="mdi-star"
                color="warning"
            >
                {{ validator.totalScore || 0 }} Points
            </v-chip>
        </template>
        <template v-slot:subtitle>
            <v-card-text class="py-1 px-0">
                <v-chip
                    size="small"
                    color="warning"
                    prepend-icon="mdi-account-cancel"
                    variant="outlined"
                    v-if="!verifyData.verified"
                >
                    <span class="text-primary1">Not verified</span>
                </v-chip>
                <v-chip
                    size="small"
                    color="success"
                    prepend-icon="mdi-account-check"
                    variant="outlined"
                    v-else
                >
                    <span class="text-primary1">Verified</span>
                </v-chip>
                <!-- <VcFlow /> -->
                <v-chip
                    class="ms-2 ma-0"
                    size="small"
                    prepend-icon="mdi-account-multiple-check"
                >
                    {{ validator.wallets || 0 }} Verified wallets
                </v-chip>
            </v-card-text>
        </template>
        <v-card-text class="py-0">
            <p>{{ validator.description }}</p>
        </v-card-text>
        <v-card-text>
            <v-timeline side="end" density="compact" width="100%">
                <v-timeline-item
                    class="mb-4"
                    width="100%"
                    dot-color="primary"
                    size="small"
                    color="primary"
                    v-for="criteria in validator.criterias"
                    :key="criteria.id"
                >
                    <v-card width="100%">
                        <template v-slot:title>
                            <div class="text-subtitle-1 font-weight-bold">
                                {{ criteria.name }}
                                <VcFlow :criteria="criteria.isVC" v-if="criteria.isVC" />
                                
                            </div>
                        </template>
                        <template v-slot:append>
                            <v-chip
                                color="success"
                                size="small"
                                prepend-icon="mdi-check-decagram"
                                class="font-weight-bold"
                                v-if="verifiedCriterias[criteria.id]"
                            >
                                Verified (+{{ criteria.score }})
                            </v-chip>
                            <v-chip
                                color="warning"
                                size="small"
                                prepend-icon="mdi-star"
                                class="font-weight-bold"
                                v-else
                            >
                                {{ criteria.score }}
                            </v-chip>
                            
                        </template>
                        <v-card-text class="bg-white text--primary">
                            <div>
                                {{ criteria.description }}
                            </div>
                            <div class="mt-2" v-if="criteria.score > 0">
                                <div>
                                    <v-btn
                                        color="success"
                                        size="small"
                                        @click="verifyVC(criteria)" v-if="criteria.isVC"
                                        :loading="loading"
                                    >
                                        <v-chip variant="text" v-if="verifiedCriterias[criteria.id]">Re-verify</v-chip>
                                        <v-chip variant="text" v-else>Start VC verification</v-chip>
                                        <v-icon>mdi-arrow-right</v-icon>
                                    </v-btn>

                                    <v-btn
                                        color="primary"
                                        size="small"
                                        @click="startVerification(criteria.id)" v-else
                                        :loading="loading"
                                    >
                                        <v-chip variant="text" v-if="verifiedCriterias[criteria.id]">Re-verify</v-chip>
                                        <v-chip variant="text" v-else>Start verification</v-chip>
                                        <v-icon>mdi-arrow-right</v-icon>
                                    </v-btn>
                                </div>
                                
                            </div>
                        </v-card-text>
                    </v-card>
                </v-timeline-item>
            </v-timeline>
        </v-card-text>

        <v-divider></v-divider>
        <v-card-actions>
            <v-btn color="success" @click="startVerification()" :loading="loading" variant="flat">
                <v-icon>mdi-check-circle</v-icon> Verify this validator
            </v-btn>
            <v-btn text="Cancel" variant="plain" @click="closeDialog"></v-btn>
        </v-card-actions>
    </v-card>
</template>
