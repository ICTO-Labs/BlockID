<script setup>
import { ref } from 'vue';
import { useProjectStore } from '@/store';
import { useRouter } from 'vue-router';
import { useTheme } from 'vuetify';
import Dialog from '@/plugins/dialog';
import Notify from '@/plugins/notify';
import { useWalletStore } from '@/store/walletStore';
import { storeToRefs } from 'pinia';
import authService from '@/services/authService';
import Connect from "@/actor/Connect";
import { WALLETS } from '@/config';
const walletStore = useWalletStore();
const { principalId, accountId, balance, isConnected, shortPrincipal, wallet } =
    storeToRefs(walletStore);
import  {idlFactory as nnsIDL}  from '@/actor/did/nns.did';
const theme = useTheme();

const router = useRouter();

const projectStore = useProjectStore();
// const theme = projectStore.theme;
const goMain = () => {
    router.push('/');
};
function toggleTheme() {
    theme.global.name.value = theme.global.current.value.dark
        ? 'light'
        : 'dark';
}
const handleConnect = () => {
    Dialog.connectWallet();
};
const checkConnect = async () => {

    console.log('check Connect');
    let wallet = await Connect.canister('rrkah-fqaaa-aaaaa-aaaaq-cai', nnsIDL, false).get_full_neuron(BigInt('18158107153719370439'));
    // let wallet = await Connect.canister('rrkah-fqaaa-aaaaa-aaaaq-cai', nnsIDL, false).get_neuron_ids();
    console.log('get_neuron_ids', wallet);
};
const handleLogout = async () => {
    const confirm = await Dialog.confirm({
        title: 'Warning',
        message: 'Are you sure you want to logout?',
        color: 'warning',
        icon: 'mdi-alert'
    });
    if (confirm) {
        walletStore.clearWalletInfo(); //Logout and clear wallet info
        Dialog.close('confirm');
        Notify.success('Logout successfully!');
    } else {
        Dialog.close('confirm');
    }
};

const toggleDrawer = () => {
    projectStore.toggleDrawer();
};
</script>
<template>
    <v-app-bar color="primary" image="/images/appbar-bg.jpg" :elevation="2">
        <template v-slot:prepend>
            <v-app-bar-nav-icon @click="toggleDrawer"></v-app-bar-nav-icon>
        </template>

        <v-app-bar-title @click="goMain()"
            >{{ projectStore.projectTitle }}
            <span class="text-subtitle-2 ml-1 d-none d-sm-inline">{{
                projectStore.desc
            }}</span></v-app-bar-title
        >

        <template v-slot:append>
            <!-- Dark Mode -->
            <v-btn dark icon @click="toggleTheme">
                <v-icon
                    :icon="
                        theme.global.name.value === 'light'
                            ? 'mdi-weather-night'
                            : 'mdi-weather-sunny'
                    "
                />
                <v-tooltip activator="parent" location="bottom"
                    >Switch to
                    {{ theme.global.name.value === 'light' ? 'Dark' : 'Light' }}
                    mode</v-tooltip
                >
            </v-btn>

            <v-divider class="my-2 mx-3" vertical></v-divider>

            <v-menu v-if="!isConnected">
                <template v-slot:activator="{ props }">
                    <v-btn variant="flat" @click="handleConnect">
                        <v-icon>mdi-wallet</v-icon>
                        Connect
                        <v-tooltip activator="parent" location="bottom"
                            >Connect your wallet</v-tooltip
                        >
                    </v-btn>
                </template>
            </v-menu>

            <!-- Setting -->
            <v-menu v-else>
                <template v-slot:activator="{ props }">
                    <v-btn dark variant="flat" v-bind="props" class="text-none">
                        <v-avatar size="24" class="mr-4">
                            <v-img :src="WALLETS[wallet].logo" />
                        </v-avatar>
                        {{ shortPrincipal }}
                    </v-btn>
                </template>

                <v-list density="compact">
                    <v-list-item to="/account">
                        <template v-slot:prepend>
                            <v-icon icon="mdi-account"></v-icon>
                        </template>
                        <v-list-item-title>My Account</v-list-item-title>
                    </v-list-item>
                    <v-list-item @click.stop="checkConnect">
                        <template v-slot:prepend>
                            <v-icon icon="mdi-cog"></v-icon>
                        </template>
                        <v-list-item-title>Setting</v-list-item-title>
                    </v-list-item>
                    <v-divider></v-divider>
                    <v-list-item
                        @click="handleLogout"
                        href="javascript:void(0)"
                    >
                        <template v-slot:prepend>
                            <v-icon icon="mdi-logout"></v-icon>
                        </template>
                        <v-list-item-title>Logout</v-list-item-title>
                    </v-list-item>
                </v-list>
            </v-menu>

            <!-- Notification-->
            <v-btn dark icon>
                <v-badge content="2" color="error">
                    <v-icon>mdi-bell</v-icon>
                    <v-tooltip activator="parent" location="bottom"
                        >Notification</v-tooltip
                    >
                </v-badge>
            </v-btn>
        </template>
    </v-app-bar>
</template>
