// src/sdk/src/blockid-sdk.ts
import { Actor, HttpAgent, Identity } from '@dfinity/agent';
import { Principal } from '@dfinity/principal';
import { idlFactory } from './did/blockid.did';
import type {
    BlockIDConfig,
    WalletDetail,
    WalletScore,
    Validator
} from './types';

export class BlockID {
    private agent: HttpAgent;
    private actor: any;
    private config: BlockIDConfig;
    private readonly DEFAULT_APP_ID = 'block-id';
    private readonly BLOCKID_CANISTER_ID = '3c7yh-4aaaa-aaaap-qhria-cai';

    constructor(config: BlockIDConfig) {
        this.config = {
            host: config.host || 'https://icp0.io',
            appId: config.appId || this.DEFAULT_APP_ID
        };

        this.initialize();
    }

    private async initialize() {
        this.agent = new HttpAgent({ host: this.config.host });

        if (this.config.host && this.config.host.includes('localhost')) {
            await this.agent.fetchRootKey();
        }

        this.actor = Actor.createActor(idlFactory, {
            agent: this.agent,
            canisterId: this.BLOCKID_CANISTER_ID,
        });
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
    async getWalletScore(principal: string): Promise<WalletScore> {
        try {
            const walletId = Principal.fromText(principal);
            return await this.actor.getWalletScore(walletId);
        } catch (error: any) {
            throw new Error(`Failed to get wallet score: ${error.message}`);
        }
    }

    /**
     * Get all validators for an application
     */
    async getValidators(applicationId?: string): Promise<Validator[]> {
        try {
            return await this.actor.getValidators(applicationId || this.config.appId);
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