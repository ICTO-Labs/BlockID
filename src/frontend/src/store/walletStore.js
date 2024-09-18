import { defineStore } from 'pinia';

export const useWalletStore = defineStore('wallet', {
    state: () => ({
        principalId: null,
        accountId: null,
        isConnected: false,
        balance: null,
        score: 0,
        wallet: null,
    }),
    actions: {
        setWalletInfo(info) {
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
        saveToLocalStorage() {
            localStorage.setItem('walletInfo', JSON.stringify({
                principalId: this.principalId,
                accountId: this.accountId,
                isConnected: this.isConnected,
                balance: this.balance,
                score: this.score,
                wallet: this.wallet,
            }));
        },
        loadFromLocalStorage() {
            const storedInfo = localStorage.getItem('walletInfo');
            if (storedInfo) {
                const parsedInfo = JSON.parse(storedInfo);
                Object.assign(this, parsedInfo);
            }
        },
    },
    getters: {
        isAuthenticated: (state) => state.isConnected && state.principalId !== null,
        shortPrincipal: (state) => {
            if (state.principalId) {
                return `${state.principalId.slice(0, 5)}...${state.principalId.slice(-5)}`;
            }
            return null;
        },
    },
});