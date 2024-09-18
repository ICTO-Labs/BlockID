<script setup>
    import { ref } from 'vue'
    import { useProjectStore } from '@/store';
    import { useRouter } from 'vue-router';
    import { useTheme } from 'vuetify'
    import { useDialogStore } from '@/store/dialogStore'
    const dialogStore = useDialogStore()
    import { useWalletStore } from '@/store/walletStore'
    import { storeToRefs } from 'pinia'
    import authService from '@/services/authService'

    const walletStore = useWalletStore()
    const { principalId, accountId, balance, isConnected, shortPrincipal } = storeToRefs(walletStore)

    const theme = useTheme()

    const router = useRouter();

    const projectStore = useProjectStore();
    const items = [
        { title: 'My Account', icon: 'mdi-account', to: '/account' },
        { title: 'Notifications', icon: 'mdi-alert-circle', to: '/notifications' },
        { title: 'Setting', icon: 'mdi-cog', to: '/setting' },
        { title: 'Logout' , icon: 'mdi-logout', to: '/logout'},
    ];
    // const theme = projectStore.theme;
    const goMain = () => {
        router.push('/');
    };
    function toggleTheme () {
        theme.global.name.value = theme.global.current.value.dark ? 'light' : 'dark'
    }
    const handleConnect = () => {
        dialogStore.openDialog('connectWallet', {
            maxWidth: 400
        })
    }

    const handleLogout = ()=>{
        dialogStore.openDialog('confirm', {
            title: 'Warning',
            message: 'Are you sure you want to logout?',
            color: 'warning',
            icon: 'mdi-alert',
            onConfirm: () => {
                console.log('Action confirmed')
                walletStore.clearWalletInfo();//Logout and clear wallet info
                dialogStore.closeDialog('confirm')
            },
            onCancel: () => {
                console.log('Action canceled')
                dialogStore.closeDialog('confirm')
            }
        })
    }
</script>
<template>
    <v-app-bar
        color="primary"
        image="/images/appbar-bg.jpg"
        :elevation="2"
        >
        <template v-slot:prepend>
            <v-app-bar-nav-icon></v-app-bar-nav-icon>
        </template>

        <v-app-bar-title @click="goMain()">{{projectStore.project}} <span class="text-subtitle-2 ml-1">{{projectStore.desc}}</span></v-app-bar-title>

        <template v-slot:append>
            
            <!-- Dark Mode -->
            <v-btn dark icon @click="toggleTheme">
                <v-icon :icon="theme.global.name.value === 'light' ? 'mdi-weather-night' : 'mdi-weather-sunny'" />
                <v-tooltip
                activator="parent"
                location="bottom"
                >Switch to {{ theme.global.name.value === 'light' ? 'Dark' : 'Light' }} mode</v-tooltip>
            </v-btn>

            <v-divider
                class="my-2 mx-3"
                vertical
            ></v-divider>

            <v-menu v-if="!isConnected">
                <template v-slot:activator="{ props }">
                    <v-btn variant='flat' @click="handleConnect">
                        <v-icon>mdi-wallet</v-icon>
                        Connect
                        <v-tooltip activator="parent" location="bottom" >Connect your wallet</v-tooltip>
                    </v-btn>
                </template>
            </v-menu>

            <!-- Setting -->
            <v-menu v-else>
                <template v-slot:activator="{ props }">
                    <v-btn dark variant='flat' v-bind="props" class="text-none">
                        <v-icon>mdi-wallet</v-icon>
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
                    <v-list-item to="/setting">
                        <template v-slot:prepend>
                            <v-icon icon="mdi-cog"></v-icon>
                        </template>
                        <v-list-item-title>Setting</v-list-item-title>
                    </v-list-item>
                    <v-divider></v-divider>
                    <v-list-item @click="handleLogout" href="javascript:void(0)">
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
                <v-tooltip
                activator="parent"
                location="bottom"
                >Notification</v-tooltip>
            </v-badge>
            </v-btn>

        </template>
        </v-app-bar>
</template>
