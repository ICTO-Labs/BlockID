import { backend as Backend } from '@/../../declarations/backend';
import { Principal } from '@dfinity/principal';
import { config } from '@/config';
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
        return await Backend.getValidators(applicationId);
    } catch (error) {
        console.error(error);
        return [];
    }
};

export const getWallet = async (walletId) => {
    try {
        return await Backend.getWallet(walletId);
    } catch (error) {
        console.error(error);
        return null;
    }
};

export const getValidator = async (validatorId) => {
    try {
        return await Backend.getValidator(validatorId);
    } catch (error) {
        console.error(error);
        return null;
    }
};

export const getCurrentWalletScore = async (
    walletId,
    applicationId = config.APPLICATION_ID
) => {
    try {
        return await Backend.getCurrentWalletScore(
            Principal.fromText(walletId),
            applicationId
        );
    } catch (error) {
        console.error(error);
        return null;
    }
};

export const createApplication = async (application) => {
    try {
        return await Backend.createApplication(application);
    } catch (error) {
        console.error(error);
        return null;
    }
};
export const createValidator = async (applicationId, validator) => {
    try {
        return await Backend.createValidator(applicationId, validator);
    } catch (error) {
        console.error(error);
        return null;
    }
};

export const createCriteria = async (validatorId, criteria) => {
    try {
        return await Backend.createCriteria(validatorId, criteria);
    } catch (error) {
        console.error(error);
        return null;
    }
};

export const updateCriteria = async (validatorId, criteriaId, criteria) => {
    try {
        return await Backend.updateCriteria(validatorId, criteriaId, criteria);
    } catch (error) {
        console.error(error);
        return null;
    }
};

export const removeCriteria = async (validatorId, criteriaId) => {
    try {
        return await Backend.removeCriteria(validatorId, criteriaId);
    } catch (error) {
        console.error(error);
        return null;
    }
};

export const updateApplication = async (application) => {
    try {
        return await Backend.updateApplication(application);
    } catch (error) {
        console.error(error);
        return null;
    }
};

export const removeApplication = async (applicationId) => {
    try {
        return await Backend.removeApplication(applicationId);
    } catch (error) {
        console.error(error);
        return null;
    }
};

export const updateValidator = async (validator) => {
    try {
        return await Backend.updateValidator(validator);
    } catch (error) {
        console.error(error);
        return null;
    }
};
export const removeValidator = async (validatorId) => {
    try {
        return await Backend.removeValidator(validatorId);
    } catch (error) {
        console.error(error);
        return null;
    }
};

export const getProviders = async () => {
    try {
        return await Backend.getProviders();
    } catch (error) {
        console.error(error);
        return [];
    }
};
