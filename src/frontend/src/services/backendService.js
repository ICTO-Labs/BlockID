import { backend as Backend} from "@/../../declarations/backend";
import { Principal } from "@dfinity/principal";
export const getWallets = async () => {
    try {
        return await Backend.getWallets()
    } catch (error) {
        console.error(error)
        return []
    }
};

export const getGroups = async () => {
    try {
        return await Backend.getGroups()
    } catch (error) {
        console.error(error)
        return []
    }
};

export const getCriterias = async () => {
    try {
        return await Backend.getCriterias()
    } catch (error) {
        console.error(error)
        return []
    }
};

export const getValidators = async () => {
    try {
        return await Backend.getValidators()
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

export const getGroup = async (groupId) => {
    try {
        return await Backend.getGroup(groupId)
    } catch (error) {
        console.error(error)
        return null
    }
};


export const getValidatorById = async (validatorId) => {
    try {
        return await Backend.getValidatorById(validatorId)
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