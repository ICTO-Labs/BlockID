import { backend as Backend } from '@/../../declarations/backend';
import { Principal } from '@dfinity/principal';
import { config } from '@/config';
import Connect from "@/actor/Connect";
const BACKEND_CANISTER_ID = 'cbopz-duaaa-aaaaa-qaaka-cai';
export const getWallets = async () => {
    try {
        return await Backend.getWallets();
    } catch (error) {
        console.error(error);
        return [];
    }
};

export const getApplications = async () => {
    try {
        return await Backend.getApplications();
    } catch (error) {
        console.error(error);
        return [];
    }
};

export const getValidators = async (applicationId = config.APPLICATION_ID) => {
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
    applicationId = config.APPLICATION_ID
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
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).createApplication(application);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};
export const createValidator = async (applicationId, validator) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).createValidator(applicationId, validator);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const createCriteria = async (validatorId, criteria) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).createCriteria(validatorId, criteria);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const updateCriteria = async (validatorId, criteriaId, criteria) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).updateCriteria(validatorId, criteriaId, criteria);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const removeCriteria = async (validatorId, criteriaId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).removeCriteria(validatorId, criteriaId);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const updateApplication = async (application) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).updateApplication(application);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
};

export const removeApplication = async (applicationId) => {
    try {
        return await Connect.canister(BACKEND_CANISTER_ID, 'backend', true).removeApplication(applicationId);
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
