import { marketplace as Marketplace } from '@/../../declarations/marketplace';
import { Principal } from '@dfinity/principal';
import { MARKETPLACE_CANISTER_ID, APPLICATION_ID } from '@/config';
import Connect from "@/actor/Connect";


export const listProviders = async () => {
    try {
        return await Connect.canister(MARKETPLACE_CANISTER_ID, 'marketplace', true).listProviders();
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const getProvider = async (providerId) => {
    try {
        return await Connect.canister(MARKETPLACE_CANISTER_ID, 'marketplace', true).getProvider(providerId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};
export const submitProvider = async (name, description, sourceUrl, moduleName) => {
    try {
        return await Connect.canister(MARKETPLACE_CANISTER_ID, 'marketplace').submitProvider(name, description, sourceUrl, moduleName);
    } catch (error) {
        console.error(error);   
        return {err: error};
    }
};

export const reviewProvider = async (providerId, status) => {
    try {
        return await Connect.canister(MARKETPLACE_CANISTER_ID, 'marketplace').reviewProvider(providerId, status, [], []);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

