<script setup>
import { ref, watch, computed, onMounted } from 'vue';
import { getProviderParams } from '@/plugins/vcflow';
import { toSimpleArray } from '@/plugins/common';
import Notify from '@/plugins/notify';
// const props = defineProps(['currentParams', 'providers', 'providerId'])
const props = defineProps({
    providerParams: {
        type: Array,
        required: true,
        default: []
    },
    providers: {
        type: Array,
        required: true
    },
    providerId: {
        type: any,
        default: null
    }
});
console.log('props', props);
const emit = defineEmits(['updateProviderParams']);
const isProvider = computed(() => props.providerId !== null);

const localParams = ref([]);

const initializeParams = () => {
    console.log('initializeParams', props.providerParams);
    //Check if providerId is an array and has elements
    if (props.providerId !== null) {
        const provider = props.providers.find((p) => p.id === props.providerId);
        if (provider) {
            const _params = provider.params.map((param) => {
                //Check if providerParams is an array and has elements
                if (
                    Array.isArray(props.providerParams) &&
                    props.providerParams.length > 0
                ) {
                    console.log('props.providerParams', props.providerParams);
                    const existingParam = props.providerParams.find(
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
            localParams.value = JSON.parse(JSON.stringify(_params));
        }
    } else {
        localParams.value =
            Array.isArray(props.providerParams) &&
            props.providerParams.length > 0
                ? props.providerParams[0]
                : [];
    }
};

// onMounted(initializeParams);

watch(() => props.providerParams, initializeParams, {
    immediate: true,
    deep: true
});
watch(() => props.providerId, initializeParams);

const addParam = () => {
    console.log('addParam', props.providerId);
    if (!props.providerId) {
        localParams.value.push({
            key: '',
            value: [''],
            dataType: { Text: null },
            arguments: []
        });
    } else {
        Notify.error('You are using a provider, you cannot add new params');
    }
};

const removeParam = (index) => {
    if (!props.providerId) {
        localParams.value.splice(index, 1);
    } else {
        Notify.error('You are using a provider, you cannot remove params');
    }
};

watch(
    localParams,
    (newParams) => {
        emit('updateProviderParams', newParams);
    },
    { deep: true }
);
</script>

<template>
    <v-card>
        <v-card-title>
            <span class="text-h6 mb-4">Params manager</span>
        </v-card-title>
        <v-card-text>
            <v-list-item v-for="(param, index) in localParams" :key="index">
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
                            :disabled="isProvider"
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
                                param.value && param.value.length > 0
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
                            ><v-icon>mdi-minus</v-icon></v-btn
                        >
                    </v-col>
                </v-row>
            </v-list-item>
        </v-card-text>
        <v-card-actions v-if="!isProvider">
            <v-btn @click="addParam" variant="tonal">
                <v-icon>mdi-plus</v-icon> New param</v-btn
            >
        </v-card-actions>
    </v-card>
</template>
