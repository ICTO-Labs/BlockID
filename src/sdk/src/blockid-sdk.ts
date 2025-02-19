// src/sdk/src/blockid-sdk.ts
import { Actor, HttpAgent, Identity } from '@dfinity/agent';
import { Principal } from '@dfinity/principal';
import { decodeJwt } from "jose";
import { 
    requestVerifiablePresentation, 
    type VerifiablePresentationResponse 
} from "@dfinity/verifiable-credentials/request-verifiable-presentation";
import { idlFactory } from './did/blockid.did';

export interface BlockIDConfig {
    host?: string;
    appId?: string;
}

export interface WalletDetail {
    id: Principal;
    applicationScores: ApplicationScore[];
    createdAt: bigint;
    updatedAt: bigint;
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
}

export interface WalletScore {
    totalScore: number;
    validatorScores: { [key: string]: number };
}

export interface Validator {
    id: string;
    name: string;
    description: string;
    criteria: ValidatorCriteria[];
}

export interface ValidatorCriteria {
    id: string;
    name: string;
    description: string;
    score: number;
}

export interface VerifyScoreResult {
    success: boolean;
    message?: string;
    details?: any;
}

export class BlockID {
    private agent: HttpAgent | undefined;
    private actor: any;
    private readonly DEFAULT_HOST = 'https://icp0.io';
    private readonly DEFAULT_APP_ID = 'block-id';
    private readonly BLOCKID_CANISTER_ID = '3c7yh-4aaaa-aaaap-qhria-cai';
    private readonly II_URL = 'https://identity.ic0.app';
    private readonly ISSUER_ORIGIN = 'https://blockid.cc';
    private readonly ISSUER_CANISTER_ID = 'znqos-ziaaa-aaaap-qkmia-cai';

    constructor(config?: BlockIDConfig) {
        const host = config?.host || this.DEFAULT_HOST;
        this.initialize(host);
    }

    private async initialize(host: string) {
        this.agent = new HttpAgent({ host });

        if (host.includes('localhost')) {
            await this.agent.fetchRootKey();
        }

        this.actor = Actor.createActor(idlFactory, {
            agent: this.agent,
            canisterId: this.BLOCKID_CANISTER_ID,
        });
    }

    /**
     * Verify if wallet meets minimum score requirement
     * @param score Required minimum score
     * @param principal User's principal
     * @param options Optional parameters for II verification
     * @returns VerifyScoreResult
     */
    async verifyScore(
        score: number,
        principal: string,
        options?: {
            walletType?: 'blockid' | 'ii';
            identity?: Identity;
        }
    ): Promise<VerifyScoreResult> {
        const walletType = options?.walletType || 'blockid';

        // Validate II requirements
        if (walletType === 'ii' && !options?.identity) {
            return {
                success: false,
                message: 'Identity is required for Internet Identity verification'
            };
        }

        try {
            if (walletType === 'ii') {
                return this.verifyScoreWithII(score, principal, options?.identity!);
            } else {
                return this.verifyScoreWithBlockID(score, principal);
            }
        } catch (error: any) {
            return {
                success: false,
                message: error.message
            };
        }
    }

    private async verifyScoreWithII(
        score: number,
        principal: string,
        identity: Identity
    ): Promise<VerifyScoreResult> {
        try {
            const response = await new Promise<VerifiablePresentationResponse>((resolve, reject) => {
                requestVerifiablePresentation({
                    onSuccess: (response) => resolve(response),
                    onError: (error) => reject(error),
                    issuerData: {
                        origin: this.ISSUER_ORIGIN,
                        canisterId: Principal.fromText(this.ISSUER_CANISTER_ID),
                    },
                    credentialData: {
                        credentialSpec: {
                            credentialType: "VerifiedScore",
                            arguments: { score }
                        },
                        credentialSubject: identity.getPrincipal(),
                    },
                    identityProvider: new URL(this.II_URL),
                    derivationOrigin: undefined,
                });
            });

            if ("Ok" in response) {
                const decoded = decodeJwt(response.Ok) as any;
                const [alias, credential] = decoded.vp.verifiableCredential.map((cred: string) => 
                    decodeJwt(cred)
                );

                const verifiedScore = credential?.vc?.credentialSubject?.score || 0;
                const success = verifiedScore >= score;

                return {
                    success,
                    message: success 
                        ? `Score verification successful: ${verifiedScore} >= ${score}`
                        : `Score verification failed: ${verifiedScore} < ${score}`,
                    details: { presentation: decoded, alias, credential }
                };
            }

            return {
                success: false,
                message: 'Failed to obtain verifiable presentation'
            };
        } catch (error: any) {
            return {
                success: false,
                message: `II verification failed: ${error.message}`
            };
        }
    }

    private async verifyScoreWithBlockID(
        score: number,
        principal: string
    ): Promise<VerifyScoreResult> {
        try {
            const walletScore = await this.getWalletScore(principal, this.DEFAULT_APP_ID);
            const success = walletScore.totalScore >= score;

            return {
                success,
                message: success 
                    ? `Score verification successful: ${walletScore.totalScore} >= ${score}`
                    : `Score verification failed: ${walletScore.totalScore} < ${score}`,
                details: walletScore
            };
        } catch (error: any) {
            return {
                success: false,
                message: `BlockID verification failed: ${error.message}`
            };
        }
    }

    /**
     * Get wallet verification details
     */
    async getWalletDetail(principal: string): Promise<WalletDetail> {
        try {
            const walletId = Principal.fromText(principal);
            const result = await this.actor.getWalletDetail(walletId);

            if ('err' in result) {
                throw new Error(result.err);
            }

            return result.ok;
        } catch (error: any) {
            throw new Error(`Failed to get wallet details: ${error.message}`);
        }
    }

    /**
     * Get wallet score
     */
    async getWalletScore(principal: string, applicationId: string): Promise<WalletScore> {
        try {
            const walletId = Principal.fromText(principal);
            return await this.actor.getWalletScore(walletId, applicationId);
        } catch (error: any) {
            throw new Error(`Failed to get wallet score: ${error.message}`);
        }
    }

    /**
     * Get all validators for an application
     */
    async getValidators(applicationId?: string): Promise<Validator[]> {
        try {
            return await this.actor.getValidators(applicationId || this.DEFAULT_APP_ID);
        } catch (error: any) {
            throw new Error(`Failed to get validators: ${error.message}`);
        }
    }

    /**
     * Check if a wallet meets score requirements
     */
    async meetsRequirements(
        principal: string,
        minScore: number,
        validatorId?: string
    ): Promise<boolean> {
        try {
            const walletDetail = await this.getWalletDetail(principal);

            if (!walletDetail) return false;

            let totalScore = 0;

            for (const appScore of walletDetail.applicationScores) {
                for (const validator of appScore.validatorScores) {
                    if (validatorId && validator.validatorId !== validatorId) continue;
                    totalScore += validator.totalScore;
                }
            }

            return totalScore >= minScore;
        } catch (error: any) {
            throw new Error(`Failed to check requirements: ${error.message}`);
        }
    }

    /**
     * Get specific validator details
     */
    async getValidator(validatorId: string): Promise<Validator | null> {
        try {
            const validators = await this.getValidators();
            return validators.find(v => v.id === validatorId) || null;
        } catch (error: any) {
            throw new Error(`Failed to get validator: ${error.message}`);
        }
    }
}