import { useSnackbarStore } from '@/store/notifyStore';

const Notify = {
    success(message, title) {
        const snackbarStore = useSnackbarStore();
        snackbarStore.showSnackbar(message, title, 'success');
    },
    error(message, title) {
        const snackbarStore = useSnackbarStore();
        snackbarStore.showSnackbar(message, title, 'error');
    },
    info(message, title) {
        const snackbarStore = useSnackbarStore();
        snackbarStore.showSnackbar(message, title, 'info');
    },
    warning(message, title) {
        const snackbarStore = useSnackbarStore();
        snackbarStore.showSnackbar(message, title, 'warning');
    },
    custom(message, title, color) {
        const snackbarStore = useSnackbarStore();
        snackbarStore.showSnackbar(message, title, color);
    }
};

export default Notify;
