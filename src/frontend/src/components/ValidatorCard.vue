<script setup>
    import { ref, watch, watchEffect } from 'vue';
    import Dialog from '@/plugins/dialog';
    import { getVerifiedCriteria } from '@/services/backendService';
    import { storeToRefs } from 'pinia';
    import { useWalletStore } from '@/store/walletStore';
    import { Principal } from '@dfinity/principal';

    const walletStore = useWalletStore();

    const { principalId, score } = storeToRefs(walletStore);

    const props = defineProps({
        validator: {
            type: Object,
            required: true
        },
        applicationId: {
            type: String,
            required: true
        }
    });
    const pointsGained = ref(0);
    const showVerifyDialog = async (validatorId) => {
        await Dialog.showVerify(props.applicationId, validatorId);
    };
    const getVerifiedData = async () => {
        if(!principalId.value){
            pointsGained.value = 0;
            return;
        }
        let _data = await getVerifiedCriteria(props.applicationId, props.validator.id, Principal.fromText(principalId.value));
        if(_data && _data.length > 0) {
            //count total score
            pointsGained.value = _data.reduce((acc, curr) => acc + Number(curr[1]), 0);
        }
    };
    watchEffect(() => {
        if(props.applicationId || principalId.value || score.value) {
            getVerifiedData();
        }
    });
</script>

<template>
    <v-card class="overflow-hidden mx-auto custom-card d-flex flex-column" hover height="100%">
        <template v-slot:prepend>
            <v-avatar size="48">
                <v-img :alt="validator.name" :src="validator.logo"></v-img>
            </v-avatar>
        </template>
        <template v-slot:title>
            {{ validator.name }}
            <v-chip
                label
                class="ma-0 font-weight-bold float-right"
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
                    <span class="text-success" v-if="pointsGained > 0">Verified</span>
                </v-chip>
                <!-- <VcFlow :verifyMethod="validator.verifyMethod" /> -->
            </v-card-text>
        </template>
        <v-card-text>
            <div class="flex-grow-1 d-flex flex-column overflow-hidden" style="max-height: 100px;">
                <p v-html="validator.description"></p>
            </div>
        </v-card-text>
        <v-sheet class="mt-auto bg-transparent">
            <v-sheet class="d-flex align-center mx-auto px-2 pb-0 bg-transparent">
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
        </v-sheet>
        
        <template v-slot:actions>
            <v-btn
                @click="showVerifyDialog(validator.id)"
                append-icon="mdi-open-in-app"
                color="primary"
                text="Verify"
                block
                variant="flat"
            ></v-btn>
        </template>
    </v-card>
</template>
<style scoped>
.v-card {
    display: flex;
    flex-direction: column;
}

.v-card__actions {
    margin-top: auto;
}

.custom-card {
    position: relative;
    overflow: hidden;
}

.custom-card:hover {
    right: 0;
    bottom: 0;
    background-image: url('/images/bg-card.png');
    background-size: cover;
    background-position: bottom right;
    transition: .5s;
    opacity: 0.9;
}
</style>