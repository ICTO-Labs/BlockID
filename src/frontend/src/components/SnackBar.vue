<script setup>
import { computed } from 'vue';
import { useSnackbarStore } from '@/store/notifyStore';

const snackbarStore = useSnackbarStore();

const show = computed(() => snackbarStore.isVisible);
const title = computed(() => snackbarStore.isVisible);
const message = computed(() => snackbarStore.message);
const color = computed(() => snackbarStore.color);
const isVertical = computed(() => snackbarStore.isVertical);
const timeout = computed(() => snackbarStore.timeout);
const closeSnackbar = () => {
    snackbarStore.hideSnackbar();
};
</script>

<template>
    <v-snackbar
        v-model="snackbarStore.isVisible"
        :color="snackbarStore.color"
        :timeout="snackbarStore.timeout"
        timer="true"
        location="bottom"
        :vertical="snackbarStore.title ? true : false"
    >
        <div class="text-subtitle-1" v-if="snackbarStore.title">
            {{ snackbarStore.title }}
        </div>
        {{ snackbarStore.message }}
        <template v-slot:actions>
            <v-btn
                type="button"
                color="white"
                variant="text"
                @click.stop="closeSnackbar"
            >
                Close
            </v-btn>
        </template>
    </v-snackbar>
</template>
