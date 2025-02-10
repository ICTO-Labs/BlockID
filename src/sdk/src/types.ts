// src/sdk/src/types.ts
import { Principal } from '@dfinity/principal';

export interface BlockIDConfig {
    host?: string;
    appId?: string;
}

export interface WalletDetail {
    applicationScores: ApplicationScore[];
    totalScore: number;
    percentileAbove: number;
}

export interface WalletScore {
    totalScore: number;
    percentileAbove: number;
    linkedWallet: Principal | null;
    linkedScore: number;
    primaryScore: number;
}

export interface ApplicationScore {
    applicationId: string;
    validatorScores: ValidatorScore[];
}

export interface ValidatorScore {
    validatorId: string;
    totalScore: number;
    criteriaScores: CriteriaScore[];
}

export interface CriteriaScore {
    criteriaId: string;
    score: number;
    verificationTime: bigint;
    expirationTime: bigint;
}

export interface Validator {
    id: string;
    applicationId: string;
    owner: Principal;
    logo: string;
    name: string;
    description: string;
    totalScore: number;
    criterias: Criteria[];
}

export interface Criteria {
    id: string;
    autoVerify: boolean;
    isVC: boolean;
    name: string;
    description: string;
    score: number;
    expirationTime: bigint;
    providerId: string[];
    providerParams: Array<Array<{
        key: string;
        value: string[];
        dataType: { [key: string]: null };
    }>>;
    providerArgs: string[][];
    additionalParams: Array<{
        value: number;
        comparisonType: { [key: string]: null };
        maxValue: number[];
    }>;
}