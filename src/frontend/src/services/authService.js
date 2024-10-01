import { useDialogStore } from '@/store/dialogStore';
import { AuthClient } from '@dfinity/auth-client';
import { principalToAccountId } from '@/plugins/common';
import { config } from '@/config';
const defaultOptions = {
    createOptions: {
        idleOptions: {
            disableIdle: true
        }
    }
};
const dialogStore = useDialogStore();

class AuthService {
    constructor() {}

    async connect(walletId) {
        console.log(walletId, 'walletId');
        switch (walletId) {
            case 'internet-identity':
                return await this.InternetIdentity();
            case 'nfid':
                return await this.Nfid();
            default:
                throw new Error('Invalid credentials');
        }
    }

    logout() {
        // Logout logic here
        dialogStore.openDialog('alert', {
            title: 'Logged Out',
            message: 'You have been successfully logged out.',
            color: 'info',
            icon: 'mdi-alert-circle'
        });
    }

    async InternetIdentity() {
        const auth = await AuthClient.create();
        const width = 500;
        const height = screen.height;
        const left = (screen.width / 2 - width / 2) | 0;
        const top = (screen.height / 2 - height / 2) | 0;

        return new Promise((resolve, reject) => {
            auth.login({
                ...defaultOptions.loginOptions,
                maxTimeToLive: 7 * 24 * 60 * 60 * 1000 * 1000 * 1000,
                identityProvider: 'https://identity.ic0.app/',
                disableDefaultIdleCallback: true,
                windowOpenerFeatures: `toolbar=0,location=0,menubar=0,width=${width},height=${height},top=${top},left=${left}`,
                onSuccess: async () => {
                    let pid = await auth.getIdentity();
                    console.log(pid.getPrincipal().toString(), 'pid');
                    dialogStore.closeDialog('connectWallet');
                    resolve({
                        success: true,
                        message: 'Connected to Internet Identity',
                        principalId: pid.getPrincipal().toString(),
                        accountId: principalToAccountId(
                            pid.getPrincipal().toString(),
                            0
                        )
                    });
                },
                onError: (error) => {
                    dialogStore.openDialog('alert', {
                        title: 'Error',
                        message: error,
                        color: 'error',
                        icon: 'mdi-alert'
                    });
                }
            });
        });
    }

    async Nfid() {
        dialogStore.openDialog('alert', {
            title: 'Warning',
            message: 'Nfid is not supported yet',
            color: 'warning',
            icon: 'mdi-alert'
        });
    }
}

const authService = new AuthService();
export default authService;
