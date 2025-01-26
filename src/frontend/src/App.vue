<script setup>
import { onBeforeMount } from 'vue';
import { useWalletStore } from '@/store/walletStore';
import authService from '@/services/authService';
onBeforeMount(async () => {
    const walletStore = useWalletStore();
    await authService.checkLoginStatus();
});
</script>

<template>
    <router-view></router-view>
</template>
