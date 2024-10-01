<script setup>
import { ref, onMounted } from 'vue';
import { updateApplication } from '@/services/backendService';

const props = defineProps(['editedItem']);
const emit = defineEmits(['save', 'cancel']);

const form = ref({
    id: null,
    name: '',
    description: ''
});

const saveApplication = async () => {
    await updateApplication(form.value);
    emit('save');
};

onMounted(() => {
    if (props.editedItem) {
        form.value = { ...props.editedItem };
    }
});
</script>

<template>
    <v-form @submit.prevent="saveApplication">
        <v-text-field
            v-model="form.name"
            label="Application Name"
            required
        ></v-text-field>
        <v-textarea v-model="form.description" label="Description"></v-textarea>
        <div class="d-flex justify-end pt-4">
            <v-btn type="submit" color="primary" class="mr-2">Save</v-btn>
            <v-btn @click="$emit('cancel')">Cancel</v-btn>
        </div>
    </v-form>
</template>
