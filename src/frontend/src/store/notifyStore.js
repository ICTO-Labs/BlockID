import { defineStore } from 'pinia';

export const useSnackbarStore = defineStore('snackbar', {
    state: () => ({
        isVisible: false,
        message: '',
        color: 'success',
        title: '',
        timeout: 10000
    }),
    actions: {
        showSnackbar(message, title, color = 'success', timeout = 10000) {
            this.isVisible = true;
            this.title = title;
            this.message = message;
            this.color = color;
            this.timeout = timeout;
        },
        hideSnackbar() {
            this.isVisible = false;
        }
    }
});
