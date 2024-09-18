<script setup>
    import { ref } from 'vue'
    const notify = ref(true)
</script>
<template>
    <v-system-bar color="primary" v-if="notify">
        <span class="overflow-auto">
            Build your identity and reputation on Internet Computer with a multifaceted and flexible verification system
        </span>
        <v-spacer></v-spacer>
        <v-icon @click="notify=false">mdi-close</v-icon>
    </v-system-bar>
</template>