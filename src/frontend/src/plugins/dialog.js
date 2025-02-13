import { useDialogStore } from '@/store/dialogStore';

const Dialog = {
    connectWallet() {
        const dialogStore = useDialogStore();
        return new Promise((resolve) => {
            dialogStore.openDialog('connectWallet', {
                maxWidth: 400,
                onClose: () => {
                    dialogStore.closeDialog('connectWallet');
                    resolve();
                }
            });
        });
    },
    confirm(options) {
        const dialogStore = useDialogStore();
        return new Promise((resolve) => {
            dialogStore.openDialog('confirm', {
                title: options.title || 'Confirm',
                message: options.message || 'Are you sure?',
                confirmText: options.confirmText || 'Confirm',
                cancelText: options.cancelText || 'Cancel',
                color: options.color || 'primary',
                icon: options.icon || 'mdi-alert',
                maxWidth: options.maxWidth || 400,
                onConfirm: () => {
                    dialogStore.closeDialog('confirm');
                    resolve(true);
                },
                onCancel: () => {
                    dialogStore.closeDialog('confirm');
                    resolve(false);
                }
            });
        });
    },
    showLoading(message) {
        const dialogStore = useDialogStore();
        return new Promise((resolve) => {
            dialogStore.openDialog('loadingDialog', {
                message: message || 'Loading...',
                persistent: true,
                maxWidth: 400,
                onClose: () => {
                    dialogStore.closeDialog('loadingDialog');
                    resolve();
                }
            });
        });
    },
    closeLoading() {
        const dialogStore = useDialogStore();
        dialogStore.closeDialog('loadingDialog');
    },
    showVerify(applicationId, validatorId) {
        const dialogStore = useDialogStore();
        return new Promise((resolve) => {
            dialogStore.openDialog('verifyDialog', {
                validatorId,
                applicationId,
                maxWidth: 700,
                onClose: () => {
                    dialogStore.closeDialog('verifyDialog');
                    resolve();
                }
            });
        });
    },
    alert(options) {
        const dialogStore = useDialogStore();
        return new Promise((resolve) => {
            dialogStore.openDialog('AlertDialog', {
                title: options.title || 'Notify',
                message: options.message,
                confirmText: options.confirmText || 'Close',
                color: options.color || 'gray',
                icon: options.icon || 'mdi-information-outline',
                maxWidth: options.maxWidth || 600,
                onConfirm: () => {
                    dialogStore.closeDialog('AlertDialog');
                    resolve();
                }
            });
        });
    },

    custom(name, options) {
        const dialogStore = useDialogStore();
        dialogStore.openDialog(name, options);
    },

    close(name) {
        const dialogStore = useDialogStore();
        dialogStore.closeDialog(name);
    }
};

export default Dialog;
