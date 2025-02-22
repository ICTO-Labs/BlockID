<script setup>
import { ref, onMounted, computed } from 'vue';
import { createProvider, updateProvider } from '@/services/backendService';
import Notify from '@/plugins/notify';
import Dialog from '@/plugins/dialog';

const props = defineProps(['provider', 'method']);
const emit = defineEmits(['save']);
const loading = ref(false);

const form = ref({
    id: '',
    name: '',
    description: '',
    moduleType: { Local: '' },
    params: [],
    owner: []
});

const moduleTypes = ['Local', 'Remote', 'VC', 'Custom', 'Marketplace'];
const selectedModuleType = computed({
    get: () => Object.keys(form.value.moduleType)[0],
    set: (val) => {
        const currentValue = form.value.moduleType[Object.keys(form.value.moduleType)[0]] || '';
        form.value.moduleType = { [val]: currentValue };
    }
});

const moduleTypeValue = computed({
    get: () => form.value.moduleType[selectedModuleType.value] || '',
    set: (val) => {
        form.value.moduleType[selectedModuleType.value] = val;
    }
});
const addParam = () => {
    form.value.params.push({
        key: '',
        value: [''],
        dataType: { Text: null }
    });
};

const removeParam = (index) => {
    form.value.params.splice(index, 1);
};

const saveProvider = async () => {
    try {
        loading.value = true;
        if (props.method === 'add') {
            console.log('form', form);
            let _rs = await createProvider(form.value);
            console.log('createProvider', _rs);
            Notify.success('Provider created successfully');
        } else {
            await updateProvider(form.value.id, form.value);
            Notify.success('Provider updated successfully');
        }
        emit('save');
        Dialog.close('providerDialog');
    } catch (error) {
        Notify.error('Error saving provider: ' + error.message);
    } finally {
        loading.value = false;
    }
};

onMounted(() => {
    if (props.provider) {
        form.value = { ...props.provider };
    }
});
</script>

<template>
    <v-card>
        <v-card-text>
            <v-form @submit.prevent="saveProvider">
                <v-text-field
                    v-model="form.id"
                    label="Provider ID"
                    required
                    :disabled="props.method === 'edit'"
                ></v-text-field>
                <v-text-field
                    v-model="form.name"
                    label="Provider Name"
                    required
                ></v-text-field>
                <v-textarea
                    v-model="form.description"
                    label="Description"
                ></v-textarea>
                <v-select
                    v-model="selectedModuleType"
                    :items="moduleTypes"
                    label="Module Type"
                ></v-select>
                <v-text-field
                    v-if="selectedModuleType === 'Local' || selectedModuleType === 'Remote'"
                    v-model="moduleTypeValue"
                    :label="selectedModuleType === 'Local' ? 'Local Module Name' : 'Remote Canister ID'"
                ></v-text-field>
                <v-text-field
                    v-if="selectedModuleType === 'Marketplace'"
                    v-model="moduleTypeValue"
                    label="Marketplace Provider ID"
                ></v-text-field>
                <v-card class="mt-4">
                    <v-card-title>
                        <span class="text-h6 mb-4">Params</span>
                    </v-card-title>
                    <v-card-text>
                        <v-list-item
                            v-for="(param, index) in form.params"
                            :key="index"
                        >
                            <v-row>
                                <v-col class="pa-1">
                                    <v-text-field
                                        v-model="param.key"
                                        label="Key"
                                        @blur="param.key = param.key.trim()"
                                    ></v-text-field>
                                </v-col>
                                <v-col class="pa-1">
                                    <v-text-field
                                        v-model="param.value[0]"
                                        label="Value"
                                        @blur="param.value[0] = param.value[0].trim()"
                                    ></v-text-field>
                                </v-col>
                                <v-col cols="auto">
                                    <v-btn
                                        variant="text"
                                        @click="removeParam(index)"
                                        color="red"
                                    ><v-icon>mdi-minus</v-icon></v-btn>
                                </v-col>
                            </v-row>
                        </v-list-item>
                    </v-card-text>
                    <v-card-actions>
                        <v-btn @click="addParam" variant="tonal">
                            <v-icon>mdi-plus</v-icon> New Param
                        </v-btn>
                    </v-card-actions>
                </v-card>

                <div class="d-flex justify-end pt-4">
                    <v-btn
                        type="button"
                        @click="saveProvider"
                        color="primary"
                        class="mr-2"
                        :loading="loading"
                    >Save</v-btn>
                    <v-btn @click="Dialog.close('providerForm')">Cancel</v-btn>
                </div>
            </v-form>
        </v-card-text>
    </v-card>
</template>