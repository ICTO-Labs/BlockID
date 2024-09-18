import { defineStore } from 'pinia';

export const useSnackbarStore = defineStore('snackbar', {
    state: () => ({
        isVisible: false,
        message: '',
        color: 'success',
        title: '',
    }),
    actions: {
        showSnackbar(message, title, color = 'success') {
            this.isVisible = true;
            this.title = title;
            this.message = message;
            this.color = color;
        },
        hideSnackbar() {
            this.isVisible = false;
        },
    },
});