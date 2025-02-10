import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AdditionalParams {
    'value': bigint,
    'comparisonType': ComparisonType,
    'maxValue': [] | [bigint],
}
export interface Application {
    'id': ApplicationId,
    'owner': Principal,
    'name': string,
    'description': string,
    'validators': Array<ValidatorId>,
}
export type ApplicationId = string;
export interface ApplicationScore {
    'applicationId': ApplicationId,
    'validatorScores': Array<WalletScore>,
}
export type ComparisonType = { 'Equal': null } |
{ 'Between': null } |
{ 'LessThanOrEqual': null } |
{ 'GreaterThan': null } |
{ 'LessThan': null } |
{ 'GreaterThanOrEqual': null };
export interface CreateValidator {
    'applicationId': ApplicationId,
    'logo': string,
    'name': string,
    'description': string,
}
export interface Criteria {
    'id': CriteriaId,
    'autoVerify': boolean,
    'isVC': boolean,
    'name': string,
    'additionalParams': [] | [AdditionalParams],
    'description': string,
    'score': bigint,
    'expirationTime': bigint,
    'providerParams': [] | [Array<ProviderParams>],
    'providerArgs': [] | [Array<ProviderParams>],
    'providerId': [] | [string],
}
export type CriteriaId = string;
export interface CriteriaScore {
    'verified': boolean,
    'verificationTime': [] | [bigint],
    'score': bigint,
    'expirationTime': [] | [bigint],
    'criteriaId': CriteriaId,
}
export interface Provider {
    'id': string,
    'owner': [] | [Principal],
    'moduleType': { 'VC': null } |
    { 'Local': string } |
    { 'Remote': string } |
    { 'Custom': null },
    'name': string,
    'description': string,
    'params': Array<ProviderParams>,
}
export interface ProviderParams {
    'key': string,
    'value': [] | [string],
    'dataType': { 'Int': null } |
    { 'Bool': null } |
    { 'Text': null } |
    { 'Principal': null },
}
export type Result = { 'ok': bigint } |
{ 'err': string };
export type Result_1 = { 'ok': null } |
{ 'err': string };
export type Result_2 = { 'ok': Wallet } |
{ 'err': string };
export type Result_3 = { 'ok': Validator } |
{ 'err': string };
export type Result_4 = { 'ok': Application } |
{ 'err': string };
export interface UpdateValidator {
    'applicationId': ApplicationId,
    'logo': string,
    'name': string,
    'description': string,
}
export type ValidateResponse = { 'Ok': boolean } |
{ 'Err': string };
export interface Validator {
    'id': ValidatorId,
    'applicationId': ApplicationId,
    'owner': Principal,
    'logo': string,
    'name': string,
    'description': string,
    'totalScore': bigint,
    'criterias': Array<Criteria>,
}
export type ValidatorId = string;
export interface VerificationParams {
    'verificationTime': bigint,
    'expirationTime': bigint,
    'criteriaId': CriteriaId,
    'params': Array<ProviderParams>,
    'walletId': WalletId,
}
export interface Wallet {
    'id': WalletId,
    'applicationScores': Array<ApplicationScore>,
}
export type WalletId = Principal;
export interface WalletLink {
    'primaryWallet': WalletId,
    'creationTime': bigint,
    'secondaryWallet': WalletId,
}
export interface WalletScore {
    'criteriaScores': Array<CriteriaScore>,
    'totalScore': bigint,
    'expirationTime': bigint,
    'validatorId': ValidatorId,
    'lastVerificationTime': bigint,
}
export interface _SERVICE {
    'acceptLinkWallet': ActorMethod<[WalletId], Result_1>,
    'addAdmin': ActorMethod<[string], Result_1>,
    'addVcCanisterId': ActorMethod<[string], Result_1>,
    'createApplication': ActorMethod<[Application], Result_1>,
    'createCriteria': ActorMethod<[ValidatorId, Criteria], Result_1>,
    'createProvider': ActorMethod<[Provider], Result_1>,
    'createValidator': ActorMethod<[string, CreateValidator], Result_3>,
    'getAdmins': ActorMethod<[], Array<string>>,
    'getAllLinkedWallets': ActorMethod<[], Array<[WalletId, WalletLink]>>,
    'getAllVerificationParams': ActorMethod<
        [],
        Array<[string, VerificationParams]>
    >,
    'getApplication': ActorMethod<[string], Result_4>,
    'getApplications': ActorMethod<[], Array<[string, Application]>>,
    'getMyLinkedWallets': ActorMethod<
        [],
        Array<
            {
                'linkedWallet': WalletId,
                'creationTime': bigint,
                'isPrimary': boolean,
            }
        >
    >,
    'getNeuronIds': ActorMethod<[], BigUint64Array | bigint[]>,
    'getPendingLinkRequests': ActorMethod<[], Array<WalletId>>,
    'getProviders': ActorMethod<[], Array<[string, Provider]>>,
    'getScoreDistribution': ActorMethod<[], Array<[bigint, bigint]>>,
    'getTotalVerifiedWallets': ActorMethod<[], bigint>,
    'getValidator': ActorMethod<[ValidatorId], Result_3>,
    'getValidators': ActorMethod<[string], Array<[ValidatorId, Validator]>>,
    'getVcCanisterId': ActorMethod<[], Array<string>>,
    'getVerifiedCriteria': ActorMethod<
        [ApplicationId, ValidatorId, WalletId],
        Array<[CriteriaId, bigint]>
    >,
    'getWalletDetail': ActorMethod<[WalletId], Result_2>,
    'getWalletScore': ActorMethod<
        [WalletId, string],
        {
            'linkedWallet': [] | [[WalletId, bigint]],
            'linkedScore': bigint,
            'primaryScore': bigint,
            'totalScore': bigint,
            'percentileAbove': number,
        }
    >,
    'getWallets': ActorMethod<[], Array<[WalletId, Wallet]>>,
    'recountDistribution': ActorMethod<[string], string>,
    'rejectLinkWallet': ActorMethod<[WalletId], Result_1>,
    'removeAdmin': ActorMethod<[string], Result_1>,
    'removeApplication': ActorMethod<[string], Result_1>,
    'removeCriteria': ActorMethod<[ValidatorId, CriteriaId], Result_1>,
    'removeProvider': ActorMethod<[string], Result_1>,
    'removeValidator': ActorMethod<[ValidatorId], Result_1>,
    'removeVcCanisterId': ActorMethod<[string], Result_1>,
    'requestLinkWallet': ActorMethod<[WalletId], Result_1>,
    'setTotalVerifiedWallets': ActorMethod<[bigint], undefined>,
    'unlinkWallet': ActorMethod<[WalletId], Result_1>,
    'updateApplication': ActorMethod<[Application], Result_1>,
    'updateCriteria': ActorMethod<[ValidatorId, CriteriaId, Criteria], Result_1>,
    'updateProvider': ActorMethod<[string, Provider], Result_1>,
    'updateValidator': ActorMethod<[ValidatorId, UpdateValidator], Result_1>,
    'validateVC': ActorMethod<
        [string, string, string, string],
        ValidateResponse
    >,
    'verifyWalletByCriteria': ActorMethod<
        [string, ValidatorId, Array<CriteriaId>, [] | [Array<ProviderParams>]],
        Result
    >,
    'verifyWalletByValidator': ActorMethod<[string, ValidatorId], Result>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
