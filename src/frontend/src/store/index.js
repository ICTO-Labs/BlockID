import { defineStore } from 'pinia';

export const useProjectStore = defineStore('project', {
    state: () => ({
        projectTitle: 'BlockID',
        desc: 'One ID, Infinite Trust',
        email: 'info@blockid.cc',
        theme: 'light',
        isDrawerOpen: true
    }),
    actions: {
        toggleDrawer() {
            this.isDrawerOpen = !this.isDrawerOpen;
        }
    }
});
