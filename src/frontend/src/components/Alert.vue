<script setup>
    import { defineProps } from 'vue'
    defineProps(['title', 'message', 'color'])
</script>
<template>
    <v-card>
        <v-card-title :class="color">{{ title }}</v-card-title>
        <v-card-text>{{ message }}</v-card-text>
        <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn color="primary" text @click="$emit('close')">OK</v-btn>
        </v-card-actions>
    </v-card>
</template>