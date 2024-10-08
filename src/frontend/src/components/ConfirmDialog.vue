<script setup>
import { ref, defineProps } from 'vue';

const dialog = ref(false);
//create dialog confirm and return choose option via emit
const emit = defineEmits(['confirm', 'cancel']);

const props = defineProps({
    title: {
        type: String,
        default: 'Confirm'
    },
    message: {
        type: String,
        default: 'Are you sure you want to proceed?'
    }
});
const confirm = () => {
    emit('confirm');
};

const cancel = () => {
    emit('cancel');
    dialog.value = false;
};
</script>
<template>
    <v-sheet class="position-relative">
        <v-card class="mx-auto px-5 py-3">
            <v-card-title class="text-red">
                <i class="mdi mdi-alert-circle"></i> {{ title }}
            </v-card-title>
            <v-card-text>
                {{ message }}
            </v-card-text>
            <template v-slot:actions>
                <v-spacer></v-spacer>

                <v-btn @click="cancel" class="bg-red"> Cancel </v-btn>

                <v-btn @click="confirm"> Confirm </v-btn>
            </template>
        </v-card>
    </v-sheet>
</template>
