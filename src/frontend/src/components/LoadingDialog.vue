<script setup>
import { defineProps } from 'vue';
defineProps(['message']);
</script>
<template>
    <v-sheet class="position-relative">
        <v-list class="py-2" color="primary" elevation="12" rounded="lg">
            <v-list-item>
                <template v-slot:title>
                    <div>{{ message }}</div>
                </template>
                <template v-slot:prepend>
                    <div class="pe-4">
                        <v-icon color="primary" size="x-large"></v-icon>
                    </div>
                </template>

                <template v-slot:append>
                    <v-progress-circular
                        color="primary"
                        indeterminate="disable-shrink"
                        size="16"
                        width="2"
                    ></v-progress-circular>
                </template>
            </v-list-item>
        </v-list>
    </v-sheet>
</template>
