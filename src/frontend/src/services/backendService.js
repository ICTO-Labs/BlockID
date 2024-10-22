import { backend as Backend } from '@/../../declarations/backend';
import { Principal } from '@dfinity/principal';
import { BACKEND_CANISTER_ID, APPLICATION_ID } from '@/config';
import Connect from "@/actor/Connect";

export const getVerifiedCriteria = async (applicationId, validatorId, walletId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').getVerifiedCriteria(applicationId, validatorId, walletId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const verifyByCriteria = async (applicationId, validatorId, criteriaIds, params) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').verifyWalletByCriteria(applicationId, validatorId, criteriaIds, params);
    } catch (error) {
        console.log(error);
        return {err: error};
    }
};

export const verifyByValidator = async (applicationId, validatorId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').verifyWalletByValidator(applicationId, validatorId);
    } catch (error) {
        console.error("verifyByValidator:", error);
        return {err: error};
    }
};

export const getWallets = async () => {
    try {
        return await Backend.getWallets();
    } catch (error) {
        console.error(error);
        return [];
    }
};
export const getApplication = async (applicationId = APPLICATION_ID) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).getApplication(applicationId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};
export const getApplications = async () => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').getApplications();
    } catch (error) {
        console.error(error);
        return [];
    }
};

export const getValidators = async (applicationId = APPLICATION_ID) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).getValidators(applicationId);
    } catch (error) {
        console.error(error);
        return [];
    }
};

export const getWallet = async (walletId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).getWallet(walletId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const getValidator = async (validatorId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).getValidator(validatorId);
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
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').getWalletScore(
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
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').createApplication(application);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};
export const createValidator = async (applicationId, validator) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').createValidator(applicationId, validator);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const createCriteria = async (validatorId, criteria) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').createCriteria(validatorId, criteria);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const updateCriteria = async (validatorId, criteriaId, criteria) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').updateCriteria(validatorId, criteriaId, criteria);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const removeCriteria = async (validatorId, criteriaId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').removeCriteria(validatorId, criteriaId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const updateApplication = async (application) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').updateApplication(application);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const removeApplication = async (applicationId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').removeApplication(applicationId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const updateValidator = async (validatorId, validator) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').updateValidator(validatorId, validator);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};
export const removeValidator = async (validatorId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').removeValidator(validatorId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const getProviders = async () => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).getProviders();
    } catch (error) {
        console.error(error);
        return [];
    }
};

export const getLinkedWallets = async (walletId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').getLinkedWallets(walletId);
    } catch (error) {
        console.log(error);
        return [];
    }
};

export const requestLinkWallet = async (secondaryWalletId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').requestLinkWallet(secondaryWalletId);
    } catch (error) {
        console.log(error);
        return {err: error};
    }
};

export const acceptLinkWallet = async (primaryWalletId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').acceptLinkWallet(primaryWalletId);
    } catch (error) {
        console.log(error);
        return {err: error};
    }
};

export const rejectLinkWallet = async (primaryWalletId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').rejectLinkWallet(primaryWalletId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const getMyLinkedWallets = async () => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').getMyLinkedWallets();
    } catch (error) {
        console.log(error);
        return [];
    }
};

export const getPendingLinkRequests = async () => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').getPendingLinkRequests();
    } catch (error) {
        console.log(error);
        return [];
    }
};

export const unlinkWallet = async (walletId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').unlinkWallet(walletId);
    } catch (error) {
        console.log(error);
        return {err: error};
    }
}

export const createProvider = async (provider) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').createProvider(provider);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const updateProvider = async (providerId, provider) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').updateProvider(providerId, provider);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const removeProvider = async (providerId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').removeProvider(providerId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};
export const getTotalVerifiedWallets = async () => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).getTotalVerifiedWallets();
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};