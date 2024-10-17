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
    import { templateParse } from '@/plugins/common';
    import { BACKEND_CANISTER_ID } from '@/config';
    import Copy from '@/components/icons/Copy.vue';

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
    const pointsGained = ref(0);
    const walletStore = useWalletStore();
    const { principalId, accountId,isConnected, currentWallet } = storeToRefs(walletStore);
    const loading = ref(false);
    const validator = ref(null);
    const currentCriteria = ref(null);

    const placeholders = computed(() => ({
        '{BACKEND_CANISTER_ID}': BACKEND_CANISTER_ID,
        '{MY_PRINCIPAL_ID}': principalId.value,
        '{MY_ACCOUNT_ID}': accountId.value,
        '{CURRENT_TIME()}': () => new Date().toLocaleString()
    }));
    const parseValidatorDescription = computed(() => {
        return templateParse(validator.value.description, placeholders.value);
    });
    const parsedCriteriaDescriptions = computed(() => {
        return validator.value?.criterias.map(criteria => ({
            ...criteria,
            parsedDescription: templateParse(criteria.description, placeholders.value)
        })) || [];
    });
    const startVerification = async (criteria) => {
        console.log('startVerification:', criteria);
        if (!isConnected.value) {
            Dialog.connectWallet();
            return;
        }
        currentCriteria.value = criteria;
        if (!criteria.isVC && criteria.providerParams && criteria.providerParams[0].length > 0) {
            console.log('criteria.providerParams', criteria.providerParams);
            Dialog.custom('paramsInput', {
                maxWidth: 500,
                title: 'Enter additional information',
                params: criteria.providerParams,
                onSubmit: handleParamsSubmit
            });
        } else {
            proceedWithVerification(criteria);
        }
    };
    const handleParamsSubmit = (params) => {
        proceedWithVerification(currentCriteria.value, params);
    };
    const proceedWithVerification = (criteria, params = {}) => {
        console.log('proceedWithVerification', criteria, params);
        switch(criteria.isVC){
            case true:
            verifyVC(criteria, params);
            break;
            case false:
            case undefined:
            verifyCriteria(criteria.id, params);
            break;
        }
    };
    const verifyCriteria = async (criteriaId, params)=>{
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
                    //create array object with params like provider template.
                    //Params is object with key and value
                    let _params = Object.entries(params).map(([key, value]) => {
                        return {
                            key: key,
                            value: [value],
                            dataType: { "Text": null }
                        };
                    });
                    console.log('_params', _params);
                    _result = await verifyByCriteria(props.applicationId, props.validatorId, [criteriaId], [_params]);
                    break;
            }
            if(_result && _result.ok > 0) {
                walletStore.getUserScore(props.applicationId);//Update score
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
    }

    const verifyVC = async (criteria) => {
        if(currentWallet.value != 'INTERNET_IDENTITY') {
            Notify.error('Please use Internet Identity wallet to verify VC, current wallet: ' + currentWallet.value);
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
                    walletStore.getUserScore(props.applicationId);//Update score
                    Notify.success(
                        'Verification successful: You got '+criteria.score+' points from '+validator.value.name+' validator'
                    );
                } else {
                    Notify.error(
                        'Verification failed: The validator returned an error, please try again later!'
                    );
                }
            } catch (error) {
                Notify.warning('Verification failed: ' + error);
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
        if(!principalId.value) return;
        loading.value = true;
        let _data = await getVerifiedCriteria(props.applicationId, props.validatorId, Principal.fromText(principalId.value));
        if(_data && _data.length > 0) {
            //Convert to object
            pointsGained.value = _data.reduce((acc, curr) => acc + Number(curr[1]), 0);
            verifiedCriterias.value = _data.reduce((acc, curr) => {
                acc[curr[0]] = true;
                    return acc;
                }, {});
        }
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
            <v-avatar size="50">
                <v-img :alt="validator.name" :src="validator.logo"></v-img>
            </v-avatar>
        </template>
        <template v-slot:title>
            {{ validator.name }}

            <v-chip
                label
                class="ma-0 font-weight-bold fs-14 float-right"
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
                    v-if="pointsGained == 0"
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
                <!-- <v-chip
                    class="ms-2 ma-0"
                    size="small"
                    prepend-icon="mdi-account-multiple-check"
                >
                    {{ validator.wallets || 0 }} Verified wallets
                </v-chip> -->
            </v-card-text>
        </template>
        <v-card-text class="py-0 text-body-2">
            <!-- <p v-html="validator.description"></p></p> -->
            <component :is="parseValidatorDescription" />
            <v-sheet class="d-flex align-center mx-auto pt-2 pb-0 bg-transparent">
                <v-chip label size="small" class="me-2 text-caption" color="success">{{ pointsGained }}/{{ validator.totalScore }}</v-chip>
                <v-progress-linear
                :location="null"
                buffer-opacity="1"
                color="success"
                :buffer-value="pointsGained"
                :max="Number(validator.totalScore) || 0"
                min="0"
                rounded
                ></v-progress-linear>
            </v-sheet>
        </v-card-text>
        <v-card-text>
            <v-timeline side="end" density="compact" width="100%">
                <v-timeline-item
                    class="mb-4"
                    width="100%"
                    dot-color="primary"
                    size="small"
                    color="primary"
                    v-for="criteria in parsedCriteriaDescriptions"
                    :key="criteria.id"
                >
                    <v-card width="100%">
                        <template v-slot:title>
                            <div class="text-subtitle-2 font-weight-bold">
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
                        <v-card-text class="text--primary">
                            <div class="text-body-2">
                                <!-- <p v-html="criteria.parsedDescription"></p> -->
                                <component :is="criteria.parsedDescription" />
                            </div>
                            <div class="mt-2" v-if="criteria.score > 0">
                                <div>
                                    <!-- <v-btn
                                        color="success"
                                        size=""
                                        @click="verifyVC(criteria)" v-if="criteria.isVC"
                                        :loading="loading"
                                    >
                                        <v-chip variant="text" v-if="verifiedCriterias[criteria.id]">
                                            <v-icon>mdi-refresh</v-icon> Verify
                                        </v-chip>
                                        <v-chip variant="text" v-else><v-icon>mdi-arrow-right</v-icon> Verify</v-chip>
                                    </v-btn> -->

                                    <v-btn
                                        :color="verifiedCriterias[criteria.id] ? 'primary' : 'success'"
                                        size=""
                                        @click="startVerification(criteria)"
                                        :loading="loading"
                                    >
                                        <v-chip variant="text" v-if="verifiedCriterias[criteria.id]">
                                            <v-icon>mdi-refresh</v-icon> Verify 
                                        </v-chip>
                                        <v-chip variant="text" v-else><v-icon>mdi-arrow-right</v-icon> Verify</v-chip>
                                        <v-tooltip activator="parent" location="top" v-if="verifiedCriterias[criteria.id]">Re-verify this criteria</v-tooltip>
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
            <!-- <v-btn color="success" @click="startVerification()" :loading="loading" variant="flat">
                <v-icon>mdi-check-circle</v-icon> Verify this validator
            </v-btn> -->
            <v-btn text="Cancel" variant="plain" @click="closeDialog"></v-btn>
        </v-card-actions>
    </v-card>
</template>
