import { defineStore } from 'pinia';
import authService from '@/services/authService';
import { getCurrentWalletScore } from '@/services/backendService';

export const useWalletStore = defineStore('wallet', {
    state: () => ({
        principalId: null,
        accountId: null,
        isConnected: false,
        balance: null,
        score: 0,
        wallet: null,
        connectedWallets: {},
        currentWallet: null,
        actors: {},
        walletInfo: {},
    }),
    actions: {
        setWalletInfo(info) {
            this.walletInfo[info.wallet] = { identity: info.identity, principalId: info.principalId, accountId: info.accountId };
            this.currentWallet = info.wallet;
            this.connectedWallets[info.wallet] = true;
            this.principalId = info.principalId;
            this.accountId = info.accountId;
            this.isConnected = true;
            this.balance = info.balance;
            this.wallet = info.wallet;
            this.score = info.score || 0;
            this.saveToLocalStorage();
        },
        clearWalletInfo() {
            this.principalId = null;
            this.accountId = null;
            this.isConnected = false;
            this.balance = null;
            this.wallet = null;
            this.score = 0;
            this.connectedWallets = {};
            this.currentWallet = null;
            this.actors = {};
            this.saveToLocalStorage();
        },
        updateBalance(newBalance) {
            this.balance = newBalance;
            this.saveToLocalStorage();
        },
        updateScore(newScore) {
            this.score = newScore;
            this.saveToLocalStorage();
        },
        async getUserScore(applicationId) {
            let _score = await getCurrentWalletScore(this.principalId, applicationId);
            console.log('Score refreshed:', _score);
            this.updateScore(Number(_score) || 0);
        },
        saveToLocalStorage() {
            localStorage.setItem('walletInfo', JSON.stringify({
                principalId: this.principalId,
                accountId: this.accountId,
                isConnected: this.isConnected,
                balance: this.balance,
                score: this.score,
                wallet: this.wallet,
                connectedWallets: this.connectedWallets,
                currentWallet: this.currentWallet,
                walletInfo: this.walletInfo,
            }));
        },
        loadFromLocalStorage() {
            const storedInfo = localStorage.getItem('walletInfo');
            if (storedInfo) {
                const parsedInfo = JSON.parse(storedInfo);
                Object.assign(this, parsedInfo);
            }
        },
        updateCurrentWalletInfo() {
            const currentWalletInfo = this.walletInfo[this.currentWallet];
            if (currentWalletInfo) {
                this.principalId = currentWalletInfo.principalId;
                this.accountId = currentWalletInfo.accountId;
            }
        },
        switchWallet(walletType) {
            if (this.connectedWallets[walletType]) {
                this.currentWallet = walletType;
                this.wallet = walletType;
                this.updateCurrentWalletInfo();
                this.saveToLocalStorage();
            } else {
                throw new Error("Wallet not connected");
            }    
        },
        disconnectWallet(walletType) {
            if (this.connectedWallets[walletType]) {
                delete this.connectedWallets[walletType];
                if (this.currentWallet === walletType) {
                    this.currentWallet = Object.keys(this.connectedWallets)[0] || null;
                    this.wallet = this.currentWallet;
                }
                this.saveToLocalStorage();
            }
        },
        async checkLoginStatus() {
            const _auth = await authService.checkLoginStatus();
            if(_auth.success){
                this.setWalletInfo(_auth);
                this.wallet = _auth.wallet;
                this.isConnected = true;
            }
        }
    },
    getters: {
        isAuthenticated: (state) => state.isConnected && state.principalId !== null,
        shortPrincipal: (state) => {
            if (state.principalId) {
                return `${state.principalId.slice(0, 5)}...${state.principalId.slice(-5)}`;
            }
            return null;
        },
        getConnectedWallets: (state) => Object.keys(state.connectedWallets),
        isWalletConnected: (state) => (walletType) => !!state.connectedWallets[walletType],
    }
});