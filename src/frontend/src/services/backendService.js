import { backend as Backend } from '@/../../declarations/backend';
import { Principal } from '@dfinity/principal';
import { BACKEND_CANISTER_ID, APPLICATION_ID } from '@/config';
import Connect from "@/actor/Connect";

export const getVerifiedCriteria = async (applicationId, validatorId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').getVerifiedCriteria(applicationId, validatorId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const verifyByCriteria = async (applicationId, validatorId, criteriaIds) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').verifyWalletByCriteria(applicationId, validatorId, criteriaIds);
    } catch (error) {
        console.error(error);
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
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend').getApplication(applicationId);
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
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).getCurrentWalletScore(
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
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).updateValidator(validatorId, validator);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};
export const removeValidator = async (validatorId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).removeValidator(validatorId);
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
