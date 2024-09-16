<script setup>
    import { ref } from 'vue'
    import { useProjectStore } from '@/store';
    import { useRouter } from 'vue-router';
    import { useTheme } from 'vuetify'
    import { useDialogStore } from '@/store/dialogStore'
    const dialogStore = useDialogStore()

    const theme = useTheme()

    const router = useRouter();

    const projectStore = useProjectStore();
    const items = [
        { title: 'Profile' },
        { title: 'Alert' },
        { title: 'Setting' },
        { title: 'Logout' },
    ];
    // const theme = projectStore.theme;
    const onClick = () => {
        projectStore.theme = projectStore.theme === 'light' ? 'dark' : 'light';
    };
    const goMain = () => {
        router.push('/');
    };
    function toggleTheme () {
        theme.global.name.value = theme.global.current.value.dark ? 'light' : 'dark'
    }
    const openLoginDialog = () => {
        dialogStore.openDialog('login', {
            maxWidth: 400
        })
    }

    const openConfirmDialog = () => {
        dialogStore.openDialog('walletConnect', {
            onConfirm: () => {
                console.log('Action confirmed')
                dialogStore.closeDialog('walletConnect')
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
                >Switch to {{ theme.global.name.value === 'light' ? 'Dark' : 'Light' }} theme</v-tooltip>
            </v-btn>

            <v-divider
                class="my-2 mx-3"
                vertical
            ></v-divider>

            <v-menu>
                <template v-slot:activator="{ props }">
                    <v-btn variant='flat' @click="openConfirmDialog">
                        <v-icon>mdi-wallet</v-icon>
                        Connect
                        <v-tooltip activator="parent" location="bottom" >Connect your wallet</v-tooltip>
                    </v-btn>

                </template>

                <v-list>
                    <v-list-item
                    v-for="(item, index) in items"
                    :key="index"
                    >
                    <v-list-item-title>{{ item.title }}</v-list-item-title>
                    </v-list-item>
                </v-list>
            </v-menu>

            <!-- Setting -->
            <v-menu>
                <template v-slot:activator="{ props }">
                    <v-btn dark icon
                    v-bind="props"
                    >
                    <v-icon>mdi-cog</v-icon>
                    </v-btn>
                </template>

                <v-list>
                    <v-list-item
                    v-for="(item, index) in items"
                    :key="index"
                    >
                    <v-list-item-title>{{ item.title }}</v-list-item-title>
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
