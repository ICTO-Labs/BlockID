import { backend as Backend} from "@/../../declarations/backend";
import { Principal } from "@dfinity/principal";
import { config } from "@/config";
export const getWallets = async () => {
    try {
        return await Backend.getWallets()
    } catch (error) {
        console.error(error)
        return []
    }
};

export const getValidators = async (applicationId=config.APPLICATION_ID) => {
    try {
        return await Backend.getValidators(applicationId)
    } catch (error) {
        console.error(error)
        return []
    }
};

export const getWallet = async (walletId) => {
    try {
        return await Backend.getWallet(walletId)
    } catch (error) {
        console.error(error)
        return null
    }
};  

export const getValidator = async (validatorId) => {
    try {
        return await Backend.getValidator(validatorId)
    } catch (error) {
        console.error(error)
        return null
    }
};

export const getWalletScore = async (walletId, criteriaId) => {
    try {
        return await Backend.getCurrentWalletScore(Principal.fromText(walletId), criteriaId)
    } catch (error) {
        console.error(error)
        return null
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