import { marketplace as Marketplace } from '@/../../declarations/marketplace';
import { Principal } from '@dfinity/principal';
import { MARKETPLACE_CANISTER_ID, APPLICATION_ID } from '@/config';
import Connect from "@/actor/Connect";

const moduleIdlFactory = ({ IDL }) => {
    const ParameterType = IDL.Variant({
        'Text': IDL.Null,
        'Boolean': IDL.Null,
        'Principal': IDL.Null,
        'Number': IDL.Null,
    });
    const ParameterDefinition = IDL.Record({
        'paramType': ParameterType,
        'name': IDL.Text,
        'description': IDL.Text,
        'required': IDL.Bool,
    });
    const ProviderMetadata = IDL.Record({
        'name': IDL.Text,
        'parameters': IDL.Vec(ParameterDefinition),
        'description': IDL.Text,
        'author': IDL.Principal,
        'version': IDL.Text,
    });
    const VerificationResult = IDL.Record({
        'score': IDL.Nat,
        'message': IDL.Text,
        'isValid': IDL.Bool,
    });
    return IDL.Service({
        'metadata': IDL.Func([], [ProviderMetadata], []),
        'verify': IDL.Func(
            [
                IDL.Principal,
                IDL.Opt(
                    IDL.Vec(IDL.Record({ 'key': IDL.Text, 'value': IDL.Text }))
                ),
            ],
            [VerificationResult],
            [],
        ),
    });
};
export const init = ({ IDL }) => { return []; };

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
export const submitProvider = async (name, description, sourceUrl, moduleName, canisterId) => {
    try {
        return await Connect.canister(MARKETPLACE_CANISTER_ID, 'marketplace').submitProvider(name, description, sourceUrl, moduleName, [Principal.fromText(canisterId)]);
    } catch (error) {
        console.error(error);   
        return {err: error};
    }
};
export const getMyProviders = async () => {
    try {
        return await Connect.canister(MARKETPLACE_CANISTER_ID, 'marketplace').getMyProviders();
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
export const runProviderTest = async (canisterId, wallet, params) => {
    try {
        return await Connect.canister(canisterId, moduleIdlFactory, true).verify(wallet, params);
    } catch (error) {
        console.error(error);
        return {err: error};
    }
}
export const getProviderMetadata = async (canisterId) => {
    try {
        return await Connect.canister(canisterId, moduleIdlFactory, true).metadata();
    } catch (error) {
        console.error(error);
        return {err: error};
    }
}