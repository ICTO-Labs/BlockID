import { defineStore } from 'pinia'

export const useDialogStore = defineStore('dialog', {
    state: () => ({
        dialogs: {}
    }),
    actions: {
        openDialog(name, props = {}) {
        this.dialogs[name] = { isOpen: true, props }
        },
        closeDialog(name) {
        if (this.dialogs[name]) {
            this.dialogs[name].isOpen = false
        }
        }
    }
})