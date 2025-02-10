// src/sdk/src/tests/blockid-sdk.test.ts
import { BlockID } from '../blockid-sdk';

describe('BlockIDSDK', () => {
    let sdk: BlockID;

    beforeEach(() => {
        sdk = new BlockID({
            canisterId: 'rrkah-fqaaa-aaaaa-aaaaq-cai',
            host: 'https://icp0.io'
        });
    });

    test('should initialize with default app ID', () => {
        expect(sdk).toBeDefined();
    });

    // Add more tests as needed
});