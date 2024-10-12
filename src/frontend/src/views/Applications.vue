<script setup>
import { ref } from 'vue';
import ApplicationList from '@/components/Applications/ApplicationList.vue';
import { getProviders } from '@/services/backendService';

const providers = ref([]);
const dialogCriteriaParams = ref(false);
const dialogApplication = ref(false);
const dialogValidator = ref(false);
const dialogCriteria = ref(false);
const editedItem = ref({});
const currentApplicationId = ref(null);
const currentValidatorId = ref(null);

const fetchProviders = async () => {
    providers.value = await getProviders();
};

const openDialog = (params) => {
    console.log(params);
    editedItem.value = params.params || {};
    currentApplicationId.value = params.applicationId;
    currentValidatorId.value = params.validatorId;

    switch (params.dialog) {
        case 'application':
            dialogApplication.value = true;
            break;
        case 'validator':
            dialogValidator.value = true;
            break;
        case 'criteria':
            dialogCriteria.value = true;
            break;
    }
};

const closeDialog = () => {
    dialogApplication.value = false;
    dialogValidator.value = false;
    dialogCriteria.value = false;
    editedItem.value = {};
};

const showParams = (params) => {
    console.log('Received params:', params);
    editedItem.value = params;
    dialogCriteriaParams.value = true;
};

fetchProviders();
</script>

<template>
    <h1 class="text-h5 font-weight-bold mb-4">Manage Application</h1>

    <ApplicationList
        :providers="providers"
        @open-dialog="openDialog"
        @show-params="showParams"
    />
</template>
