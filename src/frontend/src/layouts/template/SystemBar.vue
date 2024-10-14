<script setup>
import { ref } from 'vue';
import { useDisplay } from 'vuetify';

const notify = ref(true);
const { smAndUp } = useDisplay();
</script>
<template>
    <v-system-bar color="primary" v-if="notify && $vuetify.display.smAndUp" class="d-none d-sm-flex">
        <span class="overflow-auto">
            Build your identity and reputation on Internet Computer with a
            multifaceted and flexible verification system
        </span>
        <v-spacer></v-spacer>
        <v-icon @click="notify = false">mdi-close</v-icon>
    </v-system-bar>
</template>
