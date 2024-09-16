import { defineStore } from 'pinia';

export const useProjectStore = defineStore('project', {
    state: () => ({
        project : 'BlockID',
        desc : 'One BlockChain ID',
        username : "admin",
        email: 'info@blockid.cc',
        theme: 'light'
    }),
    actions: {
        // Action
    },
});