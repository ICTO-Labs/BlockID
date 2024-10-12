<script setup>
import { ref, onMounted } from 'vue';
import { Principal } from '@dfinity/principal';
import { updateApplication, createApplication } from '@/services/backendService';
import Notify from '@/plugins/notify';
import Dialog from '@/plugins/dialog';

const props = defineProps(['app', 'method', 'onSave']);
const emit = defineEmits(['save', 'cancel']);
const loading = ref(false);
const form = ref({
    id: 'new-app',
    name: '',
    description: '',
    owner: Principal.fromText('2vxsx-fae'), //Placeholder for now
    validators: []
});

const saveApplication = async () => {
    loading.value = true;
    if (props.method == 'add') {
        //Process the id of allication, remove all special characters and space
        form.value.id = form.value.id.replace(/[^a-zA-Z0-9_-]/g, '').toLowerCase();
        let _rs = await createApplication(form.value);
        if(_rs && "ok" in _rs){
            //Notify to update application list
            props.onSave();
            Notify.success('Application created successfully');
            Dialog.close('applicationForm');
        } else {
            Notify.error(_rs.err);
        }
    } else {
        let _rs = await updateApplication(form.value);
        if(_rs && "ok" in _rs){
            //Notify to update application list
            props.onSave();
            Notify.success('Application updated successfully');
            Dialog.close('applicationForm');
        } else {
            Notify.error(_rs.err);
        }
    }
    loading.value = false;
};
const closeDialog = () => {
    Dialog.close('applicationForm');
};
onMounted(() => {
    if (props.app) {
        form.value = { ...props.app };
    }
});
</script>

<template>
    <v-card>
        <v-card-text>
            <v-form @submit.prevent="saveApplication">
                <v-text-field
                    v-model="form.id"
                    label="Custom unique application ID"
                    required
                    :disabled="props.method != 'add'"
                ></v-text-field>
                <v-text-field
                    v-model="form.name"
                    label="Application Name"
                    required
                ></v-text-field>
                <v-textarea v-model="form.description" label="Description"></v-textarea>
                <div class="d-flex justify-end pt-4">
                    <v-btn type="submit" color="primary" class="mr-2" :loading="loading">Save</v-btn>
                    <v-btn @click="closeDialog">Cancel</v-btn>
                </div>
            </v-form>
        </v-card-text>
    </v-card>
</template>
