import { principalToAccountId } from '@/plugins/common';
import { pnp } from "@/actor/pnp";
import { useWalletStore } from '@/store/walletStore';
import { Actor, HttpAgent } from "@dfinity/agent";
import { preloadIdls } from '@/actor/didList';
class AuthService {
    constructor() { }
    async connect(walletId, autoConnect = false) {
        const walletStore = useWalletStore();

        const result = await pnp.connect(walletId, true);
        console.log(result, 'result');
        if (!result?.owner) {
            throw new Error("Invalid connection result format");
        }

        const owner = result.owner.toString();
        
        // Update state
        const newState = { 
            isConnected: true, 
            account: result, 
            isInitialized: true, 
            identity: null, 
            principalId: owner, 
            accountId: principalToAccountId(owner, result.subaccount), 
            wallet: walletId 
        };
        localStorage.setItem("LAST_WALLET", walletId);
        walletStore.setWalletInfo(newState);
        return newState;
    }
    async getActor(canisterId, idl, options = { anon: false, requiresSigning: false }) {
        if (options.anon) {
            return this.createAnonymousActorHelper(canisterId, idl);
        }

        if (!pnp.isWalletConnected()) {
            throw new Error('Anonymous user');
        }

        if (typeof idl == 'string'){
            if (Object.prototype.hasOwnProperty.call(preloadIdls, idl)) {
                idl = preloadIdls[idl];
            } else {
                throw new Error(idl + " is not a preloaded IDL");
            }
        }
        return pnp.getActor(canisterId, idl, options);
    }
    async createAnonymousActorHelper(canisterId, idl) {
        const agent = HttpAgent.createSync({
                host:
                process.env.DFX_NETWORK !== "ic"
                    ? "http://localhost:4943"
                    : "https://icp0.io",
            });
        if(process.env.DFX_NETWORK !== "ic") {
        agent.fetchRootKey();
        }
        if(typeof idl == 'string'){
            if (Object.prototype.hasOwnProperty.call(preloadIdls, idl)) {
                idl = preloadIdls[idl];
            } else {
                throw new Error(idl + " is not a preloaded IDL");
            }
        }
        const actor = Actor.createActor(idl, {
            agent,
            canisterId,
        });
        return actor;
    }
    async disconnect() {
        const walletStore = useWalletStore();

        try {
            await pnp.disconnect();
            // Clear all state
            walletStore.clearWalletInfo();
            return true;
        } catch (error) {
            console.error("Disconnect error:", error);
            throw error;
        }
    }
    async checkLoginStatus() {
        console.log("Initializing auth");
        const lastWallet = localStorage.getItem("LAST_WALLET");
        if (!lastWallet) return;

        try {
            await this.connect(lastWallet, true);
        } catch (error) {
            console.warn("Auto-connect failed:", error);
        } finally {
            console.log("Auto-connect finished");
        }
    }

}

const authService = new AuthService();
export default authService;
