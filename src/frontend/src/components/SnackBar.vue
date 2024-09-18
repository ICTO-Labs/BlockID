<script setup>
    import { computed } from 'vue';
    import { useSnackbarStore } from '@/store/notifyStore';

    const snackbarStore = useSnackbarStore();

    const show = computed(() => snackbarStore.isVisible);
    const title = computed(() => snackbarStore.title);
    const message = computed(() => snackbarStore.message);
    const color = computed(() => snackbarStore.color);
    const isVertical = computed(() => snackbarStore.isVertical);
    const closeSnackbar = () => {
        snackbarStore.hideSnackbar();
    };
</script>

<template>
    <v-snackbar
        v-model="show"
        :color="color"
        timeout="3000"
        location="bottom"
        :vertical="title?true:false"
    >
        <div class="text-subtitle-1" v-if="title">{{ title }}</div>
        {{ message }}
        <template v-slot:actions>
        <v-btn
            color="white"
            variant="text"
            @click="closeSnackbar"
        >
            Close
        </v-btn>
        </template>
    </v-snackbar>
</template>