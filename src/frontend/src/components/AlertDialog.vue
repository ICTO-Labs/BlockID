<script setup>
import { defineProps } from 'vue';
defineProps(['title', 'message', 'color', 'icon']);
</script>
<template>
    <v-sheet class="position-relative">
        <v-card
            append-icon="$close"
            class="mx-auto"
            elevation="4"
            max-width="600"
        >
            <template v-slot:prepend>
                <v-icon :icon="icon" :color="color" />
            </template>
            <template v-slot:append>
                <v-btn
                    icon="$close"
                    variant="text"
                    :color="color"
                    @click="$emit('close')"
                ></v-btn>
            </template>
            <template v-slot:title>
                <div :class="`text-${color} text-h6`">{{ title }}</div>
            </template>
            <v-divider></v-divider>

            <div class="py-2 text-center">
                <div :class="`text-${color}`">{{ message }}</div>
            </div>

            <div class="pa-4 text-end">
                <v-btn
                    class="text-none"
                    min-width="92"
                    variant="tonal"
                    :color="color"
                    rounded
                    @click="$emit('close')"
                >
                    OK
                </v-btn>
            </div>
        </v-card>
    </v-sheet>
</template>
