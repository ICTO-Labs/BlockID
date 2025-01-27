import { AuthClient } from '@dfinity/auth-client';
import { StoicIdentity } from "ic-stoic-identity";
import { principalToAccountId } from '@/plugins/common';

import { END_POINT, INTERNET_INDENTITY, DERIVATION_ORIGIN, BACKEND_CANISTER_ID, FRONTEND_CANISTER_ID, VC_VALIDATOR_CANISTER_ID } from '@/config';
const defaultOptions = {
    createOptions: {
        idleOptions: {
            disableIdle: true
        },
        derivationOrigin: DERIVATION_ORIGIN,
    },
    loginOptions: {
        derivationOrigin: DERIVATION_ORIGIN,
    }
};

class AuthService {
    constructor() { }

    async connect(walletId) {
        console.log(walletId, 'walletId');
        switch (walletId) {
            case 'INTERNET_IDENTITY':
                return await this.InternetIdentity();
            case 'PLUG':
                return await this.plugWallet();
            case 'STOIC':
                return await this.stoicWallet();
            default:
                throw new Error('Invalid credentials');
        }
    }

    async logout(){
        var walletInfo = JSON.parse(localStorage.getItem("walletInfo"));
        if(walletInfo.wallet === 'NFID'){
            const nfid = await this.getNfid();
            await nfid.logout();
        }
        if(walletInfo.wallet === 'STOIC'){
            StoicIdentity.disconnect();
        }
    }

    checkLoginStatus() {
        var walletInfo = JSON.parse(localStorage.getItem("walletInfo"));
        if (walletInfo && walletInfo.isConnected) {
            switch (walletInfo.wallet) {
                case "PLUG":
                    return (async () => {
                        const connected = await window?.ic?.plug.isConnected();
                        if (connected) {
                            if (!window.ic["plug"].agent) {
                                await window.ic["plug"].createAgent({
                                    whitelist: [],
                                    host: END_POINT
                                });
                            }

                            var pid = await window.ic.plug.agent.getPrincipal();//await window.ic["plug"].getPrincipal();

                            return ({
                                success: true,
                                message: 'Connected to Plug Wallet',
                                identity: window.ic.plug.agent,
                                principalId: pid.toString(),
                                accountId: principalToAccountId(
                                    pid.toString(),
                                    0
                                ),
                                wallet: 'PLUG'
                            })
                        } else {
                            console.log("Plug not connected");
                            return ({
                                success: false,
                                message: 'Plug not connected',
                                wallet: 'PLUG'
                            })
                        }
                    })();
                    break;
                case "INTERNET_IDENTITY":
                    return (async () => {
                        console.log('check ii');
                        const authClient = await AuthClient.create(defaultOptions.createOptions);
                        const identity = authClient.getIdentity();
                        //check if identity is valid: 2vxsx-fae
                        if (identity && identity.getPrincipal().toString() != '2vxsx-fae') {
                            return ({
                                success: true,
                                message: 'Connected to Internet Identity',
                                identity: identity,
                                principalId: identity.getPrincipal().toString(),
                                accountId: principalToAccountId(
                                    identity.getPrincipal().toString(),
                                    0
                                ),
                                wallet: 'INTERNET_IDENTITY'
                            })
                        } else {
                            return ({
                                success: false,
                                message: 'Internet Identity not connected',
                                wallet: 'INTERNET_IDENTITY'
                            })
                        }
                    })();
                    break;
                case "STOIC":
                    return (async () => {
                        return StoicIdentity.load().then(async identity => {
                            if (identity !== false) {
                                return {
                                    success: true,
                                    message: 'Connected to Stoic',
                                    identity: null,
                                    principalId: identity.getPrincipal().toText(),
                                    accountId: principalToAccountId(
                                        identity.getPrincipal().toText(),
                                        0
                                    ),
                                    wallet: 'STOIC'
                                };
                            } else {
                                return {
                                    success: false,
                                    message: 'Stoic not connected',
                                };
                            }
                        })
                    })();
                default:
                    break;
            }
        } else {
            return ({
                success: false,
                message: 'No wallet connected',
                wallet: 'none'
            })
        }
    }


    async InternetIdentity() {
        const auth = await AuthClient.create();
        const width = 500;
        const height = screen.height/2;
        const left = (screen.width / 2 - width / 2) | 0;
        const top = (screen.height / 2 - height / 2) | 0;

        return new Promise((resolve, reject) => {
            auth.login({
                ...defaultOptions.loginOptions,
                identityProvider: INTERNET_INDENTITY,
                disableDefaultIdleCallback: true,
                windowOpenerFeatures: `toolbar=0,location=0,menubar=0,width=${width},height=${height},top=${top},left=${left}`,
                onSuccess: async () => {
                    let pid = await auth.getIdentity();
                    console.log(pid.getPrincipal().toString(), 'pid');
                    resolve({
                        success: true,
                        message: 'Connected to Internet Identity',
                        identity: pid,
                        principalId: pid.getPrincipal().toString(),
                        accountId: principalToAccountId(
                            pid.getPrincipal().toString(),
                            0
                        ),
                        wallet: 'INTERNET_IDENTITY'
                    });
                },
                onError: (error) => {
                    reject(error);
                }
            });
        });
    }
    async plugWallet() {
        //Test if the user has Plug extension installed (other way?)
        if (typeof window?.ic?.plug == "undefined") {
            console.log("No plug extension");
            window.open('https://plugwallet.ooo/', '_blank');
            return;
        }
        const whitelist = [];
        // Host
        const host = END_POINT; //https://icp0.io/";
        // Make the request
        try {
            const result = await window.ic.plug.requestConnect({
                whitelist,
                host
            });
            const connectionState = result ? "allowed" : "denied";
            console.log(`The Connection was ${connectionState}!`);
            if (result) {
                // Get the user principal id
                const pid = await window.ic.plug.agent.getPrincipal();//await window.ic.plug.getPrincipal();
                return ({
                    success: true,
                    message: 'Connected to Plug Wallet',
                    identity: window.ic.plug.agent,
                    principalId: pid.toString(),
                    accountId: principalToAccountId(
                        pid.toString(),
                        0
                    ),
                    wallet: 'PLUG'
                });
            }
        } catch (e) {
            console.log('PLUG ERROR:', e);
        }
    };

    async stoicWallet(){
        return StoicIdentity.load().then(async identity => {
            if (identity !== false) {
                //ID is a already connected wallet!
                return {
                    success: true,
                    message: 'Connected to Stoic',
                    identity: null,
                    principalId: identity.getPrincipal().toText(),
                    accountId: principalToAccountId(
                        identity.getPrincipal().toText(),
                        0
                    ),
                    wallet: 'STOIC'
                };
            } else {
                //No existing connection, lets make one!
                identity = await StoicIdentity.connect();
                return {
                    success: true,
                    message: 'Connected to Stoic',
                    identity: null,
                    principalId: identity.getPrincipal().toText(),
                    accountId: principalToAccountId(
                        identity.getPrincipal().toText(),
                        0
                    ),
                    wallet: 'STOIC'
                };
            }
        })
    }
}

const authService = new AuthService();
export default authService;
