<script setup>
    import { ref } from 'vue'
    import { RouterView } from 'vue-router';
    import SystemBar from './SystemBar'
    import AppBar from './AppBar'
    import Sidebar from './SideBar'
    import ToolBar from './ToolBar'
    import Contents from './Content'
    import Footer from './Footer'
    import DialogManager from '@/components/DialogManager.vue'

    import { useProjectStore } from '@/store';
    const projectStore = useProjectStore();

    import { useTheme } from 'vuetify'

    const theme = useTheme()
</script>
<template>
    <v-app :theme="theme.global.name.value? theme.global.name.value : 'light'"> 
        <SystemBar />
        <AppBar />
        <Sidebar />
        <v-main>        
            <ToolBar />
            <v-container fluid>     
                <RouterView />
            </v-container>
            <Footer />
        </v-main>
        <DialogManager />
    </v-app>
</template>