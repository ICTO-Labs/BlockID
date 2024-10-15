<script setup>
import { ref, onMounted } from 'vue';
import { QuillEditor } from '@vueup/vue-quill'
import '@vueup/vue-quill/dist/vue-quill.snow.css';

import { updateValidator, createValidator } from '@/services/backendService';
import Dialog from '@/plugins/dialog';
import Notify from '@/plugins/notify';
const props = defineProps(['validator', 'method', 'onSave', 'applicationId']);
const loading = ref(false);
const form = ref({
    id: '-',
    name: '',
    description: '',
    logo: '',
    applicationId: props.applicationId,
});

const saveValidator = async () => {
  loading.value = true;
  console.log('Validator', form.value);
  if (props.method == 'add') {
    let _rs = await createValidator(props.applicationId, form.value);
    if(_rs && "ok" in _rs){
      props.onSave();
      Notify.success('Validator created successfully');
      Dialog.close('validatorForm');
    } else {
      Notify.error(_rs.err);
    }
  } else {
    let _rs = await updateValidator(props.validator.id, form.value);
    console.log('Update validator', _rs);
    if(_rs && "ok" in _rs){
      props.onSave();
      Notify.success('Validator updated successfully');
      Dialog.close('validatorForm');
    } else {
      Notify.error(_rs.err);
    }
  }
  loading.value = false;
};
const closeDialog = () => {
    Dialog.close('validatorForm');
};
onMounted(() => {
    console.log(props.validator);
    if (props.validator) {
        form.value = { ...props.validator };
    }
});
</script>

<template>
    <v-card>
      <v-card-text>
        <v-form @submit.prevent="saveValidator">
            <v-text-field
            v-model="form.name"
            label="Validator Name"
            required
        ></v-text-field>
          <!-- <v-textarea v-model="form.description" label="Description"></v-textarea> -->
          <QuillEditor v-model:content="form.description" contentType="html" theme="snow" style="height: 150px"/>
          <v-text-field v-model="form.logo" label="URL Logo"></v-text-field>
          <div class="d-flex justify-end pt-4">
              <v-btn type="submit" color="primary" class="mr-2" :loading="loading">Save</v-btn>
              <v-btn @click="closeDialog">Cancel</v-btn>
              </div>
          </v-form>
      </v-card-text>
    </v-card>
</template>