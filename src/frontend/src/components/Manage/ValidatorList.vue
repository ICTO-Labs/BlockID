<script setup>
import { ref, onMounted, watch } from 'vue';
import { getValidators, removeValidator } from '@/services/backendService';
import CriteriaList from './CriteriaList.vue';
import { toSimpleArray } from '@/plugins/common';

const props = defineProps(['application-id', 'validators']);
const emit = defineEmits(['open-dialog', 'show-params']);

const validators = ref([]);

const fetchValidators = async () => {
    validators.value = toSimpleArray(await getValidators(props.applicationId));
};

const deleteValidator = async (id) => {
    if (confirm('Bạn có chắc chắn muốn xóa validator này không?')) {
        await removeValidator(id);
        fetchValidators();
    }
};

const handleOpenDialog = (...args) => {
    emit('open-dialog', ...args);
};

onMounted(fetchValidators);
watch(() => props.applicationId, fetchValidators);
</script>

<template>
    <v-expansion-panels>
        <v-expansion-panel v-for="validator in validators" :key="validator.id">
            <v-expansion-panel-title class="bg-containerBg">
                <v-avatar size="22" class="me-2">
                    <v-img :alt="validator.name" :src="validator.logo"></v-img>
                </v-avatar>
                {{ validator.name }}

                <template v-slot:actions>
                    <v-btn
                        size="small"
                        class="mr-2"
                        @click.stop="
                            $emit('open-dialog', {
                                dialog: 'validator',
                                method: 'edit',
                                params: validator
                            })
                        "
                    >
                        <v-icon>mdi-pencil</v-icon>
                    </v-btn>
                    <v-btn
                        size="small"
                        color="error"
                        @click.stop="deleteValidator(validator.id)"
                    >
                        <v-icon>mdi-delete</v-icon>
                    </v-btn>
                </template>
            </v-expansion-panel-title>
            <v-expansion-panel-text>
                <p>{{ validator.description }}</p>
                <CriteriaList
                    :validatorId="validator.id"
                    :criterias="validator.criterias"
                    @show-params="$emit('show-params', $event)"
                    @open-dialog="handleOpenDialog"
                />
            </v-expansion-panel-text>
        </v-expansion-panel>
    </v-expansion-panels>
    <v-divider></v-divider>
    <div class="mt-4">
        <v-btn
            @click="
                $emit('open-dialog', {
                    dialog: 'validator',
                    method: 'add',
                    params: { applicationId: props.applicationId }
                })
            "
        >
            <v-icon>mdi-plus</v-icon> Create Validator
        </v-btn>
    </div>
</template>
