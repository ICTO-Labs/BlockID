<script setup>
import { ref, onMounted } from 'vue';
import { updateValidator } from '@/services/backendService';

const props = defineProps(['editedItem', 'applicationId']);
const emit = defineEmits(['save', 'cancel']);

const form = ref({
    id: null,
    name: '',
    description: '',
    logo: '',
    applicationId: null
});

const saveValidator = async () => {
    await updateValidator(form.value);
    emit('save');
};

onMounted(() => {
    console.log(props.editedItem);
    if (props.editedItem) {
        form.value = { ...props.editedItem };
    } else {
        form.value.applicationId = props.applicationId;
    }
});
</script>

<template>
    <v-form @submit.prevent="saveValidator">
        <v-text-field
            v-model="form.name"
            label="Validator Name"
            required
        ></v-text-field>
        <v-textarea v-model="form.description" label="Description"></v-textarea>
        <v-text-field v-model="form.logo" label="URL Logo"></v-text-field>
        <div class="d-flex justify-end pt-4">
            <v-btn type="submit" color="primary" class="mr-2">Save</v-btn>
            <v-btn @click="$emit('cancel')">Cancel</v-btn>
        </div>
    </v-form>
</template>
