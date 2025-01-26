import { backend as Backend } from '@/../../declarations/backend';
import { Principal } from '@dfinity/principal';
import { BACKEND_CANISTER_ID, APPLICATION_ID } from '@/config';
import Connect from "@/actor/Connect";
import AuthService from '@/services/authService';

export const getVerifiedCriteria = async (applicationId, validatorId, walletId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.getVerifiedCriteria(applicationId, validatorId, walletId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const verifyByCriteria = async (applicationId, validatorId, criteriaIds, params) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.verifyWalletByCriteria(applicationId, validatorId, criteriaIds, params);
    } catch (error) {
        console.log(error);
        return {err: error};
    }
};

export const verifyByValidator = async (applicationId, validatorId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.verifyWalletByValidator(applicationId, validatorId);
    } catch (error) {
        console.error("verifyByValidator:", error);
        return {err: error};
    }
};

export const getWallets = async () => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.getWallets();
    } catch (error) {
        console.error(error);
        return [];
    }
};
export const getApplication = async (applicationId = APPLICATION_ID) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend', { anon: true });
        return await actor.getApplication(applicationId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};
export const getApplications = async () => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.getApplications();
    } catch (error) {
        console.error(error);
        return [];
    }
};

export const getValidators = async (applicationId = APPLICATION_ID) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend', { anon: true });
        return await actor.getValidators(applicationId);
    } catch (error) {
        console.error(error);
        return [];
    }
};

export const getWallet = async (walletId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend', { anon: true });
        return await actor.getWallet(walletId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const getValidator = async (validatorId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend', { anon: true });
        return await actor.getValidator(validatorId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const getCurrentWalletScore = async (
    walletId,
    applicationId = APPLICATION_ID
) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.getWalletScore(
            Principal.fromText(walletId),
            applicationId
        );
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const createApplication = async (application) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend', { requiresSigning: true });
        return await actor.createApplication(application);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};
export const createValidator = async (applicationId, validator) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.createValidator(applicationId, validator);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const createCriteria = async (validatorId, criteria) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.createCriteria(validatorId, criteria);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const updateCriteria = async (validatorId, criteriaId, criteria) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.updateCriteria(validatorId, criteriaId, criteria);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const removeCriteria = async (validatorId, criteriaId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.removeCriteria(validatorId, criteriaId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const updateApplication = async (application) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend', { requiresSigning: true });
        return await actor.updateApplication(application);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const removeApplication = async (applicationId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.removeApplication(applicationId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const updateValidator = async (validatorId, validator) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.updateValidator(validatorId, validator);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};
export const removeValidator = async (validatorId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.removeValidator(validatorId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const getProviders = async () => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend', { anon: true });
        return await actor.getProviders();
    } catch (error) {
        console.error(error);
        return [];
    }
};

export const getLinkedWallets = async (walletId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.getLinkedWallets(walletId);
    } catch (error) {
        console.log(error);
        return [];
    }
};

export const requestLinkWallet = async (secondaryWalletId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.requestLinkWallet(secondaryWalletId);
    } catch (error) {
        console.log(error);
        return {err: error};
    }
};

export const acceptLinkWallet = async (primaryWalletId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.acceptLinkWallet(primaryWalletId);
    } catch (error) {
        console.log(error);
        return {err: error};
    }
};

export const rejectLinkWallet = async (primaryWalletId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.rejectLinkWallet(primaryWalletId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const getMyLinkedWallets = async () => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.getMyLinkedWallets();
    } catch (error) {
        return [];
    }
};

export const getPendingLinkRequests = async () => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.getPendingLinkRequests();
    } catch (error) {
        return [];
    }
};

export const unlinkWallet = async (walletId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.unlinkWallet(walletId);
    } catch (error) {
        console.log(error);
        return {err: error};
    }
}

export const createProvider = async (provider) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.createProvider(provider);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const updateProvider = async (providerId, provider) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.updateProvider(providerId, provider);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const removeProvider = async (providerId) => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend');
        return await actor.removeProvider(providerId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};
export const getTotalVerifiedWallets = async () => {
    try {
        const actor = await AuthService.getActor(BACKEND_CANISTER_ID, 'backend', { anon: true });
        let res = await actor.getTotalVerifiedWallets();
        console.log('res', res);
        return res;
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};