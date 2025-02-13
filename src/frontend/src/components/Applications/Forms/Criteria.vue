<script setup>
import { ref, onMounted } from 'vue';
import { QuillEditor } from '@vueup/vue-quill'
import '@vueup/vue-quill/dist/vue-quill.snow.css';
import { toSimpleArray } from '@/plugins/common';
import { ComparisonType } from '@/constants/backend';
import { convertComparisonType } from '@/plugins/common';
import {
    getProviders,
    updateCriteria,
    createCriteria
} from '@/services/backendService';
import Notify from '@/plugins/notify';
import Dialog from '@/plugins/dialog';
const props = defineProps(['editedItem', 'criteria', 'validatorId', 'method']);
const emit = defineEmits(['save', 'cancel']);
const providers = ref([]);
const localParams = ref([]);
const loading = ref(false);
const comparisonTypes = Object.values(ComparisonType);
const additionalParams = ref({
    selected: null,
    comparisonType: null,
    value: null,
    maxValue: null
});
const form = ref({
    id: '_',
    name: '',
    description: '',
    providerId: null,
    autoVerify: true,
    score: 0,
    isVC: false,
    expirationTime: 0,
    providerParams: [],
    providerArgs: [],
    additionalParams: []
});

const initializeAdditionalParams = () => {
    console.log('props.criteria', props.criteria);
    try{
        if (props.criteria?.additionalParams && props?.criteria?.additionalParams.length > 0) {
            //moving key to selected
            additionalParams.value = {
                selected: convertComparisonType(props.criteria.additionalParams[0].comparisonType, true),
                comparisonType: props.criteria.additionalParams[0].comparisonType,
                value: Number(props.criteria.additionalParams[0].value),
                maxValue: Number(props.criteria.additionalParams[0].maxValue)
            };
        }
    } catch (error) {
        console.log('Error initializing additional params', error);
    }
}
const initializeArgs = () => {
    if (props.criteria) {
        form.value.providerArgs =
            Array.isArray(props.criteria?.providerArgs) &&
            props.criteria?.providerArgs.length > 0
                ? props.criteria?.providerArgs
                : [[]];
    } else {
        form.value.providerArgs = [[]];
    }
};

const addArgument = () => {
    //Check if args is an array and has elements
    if (
        Array.isArray(form.value?.providerArgs) &&
        form.value?.providerArgs?.length == 0
    ) {
        form.value.providerArgs = [[]];
    }
    form.value.providerArgs[0].push({
        key: '',
        value: [''],
        dataType: { Text: null }
    });
};
const removeArgument = (argIndex) => {
    form.value.providerArgs[0].splice(argIndex, 1);
};
const initializeParams = () => {
    //Check if providerId is an array and has elements
    if (form.value?.providerId) {
        const provider = providers.value.find(
            (p) => p.id === form.value?.providerId
        );
        if (provider) {
            const _params = provider.params.map((param) => {
                //Check if providerParams is an array and has elements
                if (
                    Array.isArray(form.value?.providerParams) &&
                    form.value?.providerParams?.length > 0
                ) {
                    const existingParam = form.value?.providerParams[0].find(
                        (p) => p.key === param.key
                    );
                    return {
                        ...param,
                        value: existingParam ? existingParam.value : param.value
                    };
                } else {
                    return param;
                }
            });
            form.value.providerParams[0] = JSON.parse(JSON.stringify(_params));
        }
    } else {
        form.value.providerParams = [[]];
    }
};
const addParam = () => {
    if (!props.providerId) {
        form.value.providerParams[0].push({
            key: '',
            value: '',
            dataType: { Text: null },
            arguments: []
        });
    } else {
        Notify.error('You are using a provider, you cannot add new params');
    }
};

const removeParam = (index) => {
    if (!props.providerId) {
        form.value.providerParams[0].splice(index, 1);
    } else {
        Notify.error('You are using a provider, you cannot remove params');
    }
};
const saveValidator = async () => {
    await updateCriteria(form.value);
    emit('save');
};
const fetchProviders = async () => {
    providers.value = toSimpleArray(await getProviders());
    initializeParams();
};
const clearAdditionalParams = () => {
    additionalParams.value = {
        selected: null,
        comparisonType: null,
        value: null,
        maxValue: null
    }
}
const saveCriteria = async () => {
    //Update providerId as element 0 of array
    if (additionalParams.value.selected !== null) {
        additionalParams.value.comparisonType = convertComparisonType(additionalParams.value.selected);
        form.value.additionalParams = [
            {
                comparisonType: additionalParams.value.comparisonType,
                value: additionalParams.value.value,
                maxValue: additionalParams.value.maxValue ? [additionalParams.value.maxValue] : []
            }
        ]
    }
    //Remove additional params if no comparison type is selected
    if(additionalParams.value.selected === null) {
        form.value.additionalParams = [];
    }
    console.log('form value', form.value);
    form.value.providerId = [
        form.value.providerId ? form.value.providerId : ''
    ];
    //Process providerArgs
    const _providerArgs = form.value.providerArgs[0].map((arg) => {
        arg.value = Array.isArray(arg.value) ? arg.value : [arg.value];
        return arg;
    });

    //Process providerParams
    const _providerParams = form.value.providerParams[0].map((param) => {
        param.value = Array.isArray(param.value) ? param.value : [param.value];
        return param;
    });

    loading.value = true;
    if (props.method == 'add') {
        await createCriteria(props.validatorId, form.value);
        Notify.success('Criteria created successfully');
        Dialog.close('criteriaForm');
    } else {
        await updateCriteria(props.validatorId, form.value.id, form.value);
        Notify.success('Criteria updated successfully');
        Dialog.close('criteriaForm');
    }
    loading.value = false;
};

onMounted(() => {
    fetchProviders();
    initializeArgs();
    initializeAdditionalParams();

    if (props?.criteria) {
        form.value = { ...props.criteria, validatorId: props.validatorId };
        form.value.providerId = Array.isArray(props?.criteria?.providerId)
            ? props.criteria.providerId[0]
            : null;
    }
});
</script>

<template>
    <v-card>
        <v-card-title>
            <span class="text-h6 mb-4">Params manager</span>
        </v-card-title>
        <v-card-text>
            <v-form @submit.prevent="saveValidator">
                <v-text-field
                    v-model="form.name"
                    label="Criteria name"
                    required
                ></v-text-field>
                <QuillEditor v-model:content="form.description" contentType="html" theme="snow" style="height: 150px"/>
                <!-- <v-textarea
                    v-model="form.description"
                    label="Description"
                ></v-textarea> -->
                <v-text-field
                    v-model.number="form.score"
                    label="Score"
                    type="number"
                ></v-text-field>
                <v-switch
                    v-model="form.isVC"
                    label="Using Verifiable Credential (VC Flow)"
                    color="primary"
                ></v-switch>
                <v-text-field
                    v-model="form.expirationTime"
                    label="Expiration time in seconds. 0 means no expiration"
                    type="number"
                ></v-text-field>
                <v-divider></v-divider>
                <v-label class="mb-2 mt-4 text-primary"
                    >Choose provider or create your own params</v-label
                >
                <v-select
                    v-model="form.providerId"
                    :items="providers"
                    item-title="name"
                    item-value="id"
                    label="Provider"
                    clearable
                    @update:modelValue="initializeParams"
                ></v-select>
                <v-card>
                    <v-card-title>
                        <span class="text-h6 mb-4">Params manager</span>
                    </v-card-title>
                    <v-card-text>
                        <v-list-item
                            v-for="(param, index) in form.providerParams[0]"
                            :key="index"
                        >
                            <v-row>
                                <v-col class="pa-1">
                                    <v-text-field
                                        density="comfortable"
                                        v-model="param.key"
                                        label="Key"
                                        @blur="
                                            param.key && param.key.length > 0
                                                ? (param.key = param.key.trim())
                                                : (param.key = '')
                                        "
                                        :disabled="form.providerId !== null"
                                        clearable
                                        @click:clear="removeParam(index)"
                                    ></v-text-field>
                                </v-col>
                                <v-col class="pa-1">
                                    <v-text-field
                                        density="comfortable"
                                        v-model="param.value"
                                        label="Value"
                                        clearable
                                        @blur="
                                            param.value &&
                                            param.value.length > 0
                                                ? param.value
                                                : (param.value = '')
                                        "
                                    ></v-text-field>
                                </v-col>
                                <v-col cols="auto">
                                    <v-btn
                                        variant="text"
                                        @click="removeParam(index)"
                                        color="red"
                                        :disabled="form.providerId !== null"
                                        ><v-icon>mdi-minus</v-icon></v-btn
                                    >
                                </v-col>
                            </v-row>
                        </v-list-item>
                    </v-card-text>
                    <v-card-actions v-if="form.providerId == null">
                        <v-btn @click="addParam" variant="tonal">
                            <v-icon>mdi-plus</v-icon> New param</v-btn
                        >
                    </v-card-actions>
                </v-card>

                <v-card class="mt-4">
                    <v-card-title>
                        <span class="text-h6 mb-4"
                            >Arguments
                            <v-icon class="text-h5"
                                >mdi-code-braces</v-icon
                            ></span
                        >
                    </v-card-title>
                    <v-card-text>
                        <v-list-item
                            v-for="(arg, argIndex) in form.providerArgs[0]"
                            :key="argIndex"
                        >
                            <v-row>
                                <v-col class="pa-1">
                                    <v-text-field
                                        density="comfortable"
                                        v-model="arg.key"
                                        label="Key"
                                        clearable
                                        @click:clear="
                                            removeArgument(index, argIndex)
                                        "
                                        @blur="
                                            arg.key && arg.key.length > 0
                                                ? (arg.key = arg.key.trim())
                                                : (arg.key = '')
                                        "
                                    ></v-text-field>
                                </v-col>
                                <v-col class="pa-1">
                                    <v-text-field
                                        density="comfortable"
                                        v-model="arg.value"
                                        label="Value"
                                        @blur="
                                            arg.value && arg.value.length > 0
                                                ? (arg.value = arg.value.trim())
                                                : (arg.value = '')
                                        "
                                    ></v-text-field>
                                </v-col>
                                <v-col cols="auto">
                                    <v-btn
                                        variant="text"
                                        @click="removeArgument(argIndex)"
                                        color="red"
                                        ><v-icon>mdi-minus</v-icon></v-btn
                                    >
                                </v-col>
                            </v-row>
                        </v-list-item>
                    </v-card-text>
                    <v-card-actions>
                        <v-btn @click="addArgument" variant="tonal">
                            <v-icon>mdi-plus</v-icon> New Argument</v-btn
                        >
                    </v-card-actions>
                </v-card>

                <v-card class="mt-4">
                    <v-card-title class="text-danger">Criteria conditions</v-card-title>
                    <v-card-subtitle>
                        This criteria will be applied only if the conditions are met
                    </v-card-subtitle>
                    <v-card-text>
                        <v-select
                            v-model="additionalParams.selected"
                            :items="comparisonTypes"
                            label="Comparison Type"
                            clearable
                            @click:clear="clearAdditionalParams()"
                        ></v-select>
                        <v-text-field
                            v-model.number="additionalParams.value"
                            label="Value"
                            type="number"
                        ></v-text-field>
                        <v-text-field
                            v-if="additionalParams.selected === ComparisonType.Between"
                            v-model.number="additionalParams.maxValue"
                            label="Max Value (Less than or equal this value)"
                            type="number"
                        ></v-text-field>
                    </v-card-text>
                </v-card>

                <!-- <ParamsManager :providers="providers" :providerParams="form.providerParams" :providerId="form.providerId" @updateProviderParams="updateProviderParams" v-model="form.providerParams" /> -->
                <v-divider></v-divider>
                <!-- <Arguments :providerArgs="form.providerArgs" @updateProviderArgs="updateProviderArgs" v-model="form.providerArgs" class="mt-4"/> -->
                <div class="d-flex justify-end pt-4">
                    <v-btn
                        type="button"
                        @click="saveCriteria"
                        color="primary"
                        class="mr-2"
                        :loading="loading"
                        >Save</v-btn
                    >
                    <v-btn @click="Dialog.close('criteriaForm')">Cancel</v-btn>
                </div>
            </v-form>
        </v-card-text>
    </v-card>
</template>
