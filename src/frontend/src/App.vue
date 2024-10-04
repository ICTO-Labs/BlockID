<script setup>
import { onBeforeMount } from 'vue';
import { useWalletStore } from '@/store/walletStore';

onBeforeMount(() => {
    const walletStore = useWalletStore();
    walletStore.checkLoginStatus();
});
</script>

<template>
    <router-view></router-view>
</template>
