// src/sdk/examples/basic-usage.ts
import { BlockID } from '../src/blockid-sdk';
// import { BlockIDSDK } from '@blockid/sdk'; // for npm

async function example() {
    // Initialize SDK
    const blockID = new BlockID({
        host: 'https://icp0.io'
    });

    try {
        // Get wallet details
        const result = await blockID.verifyScore({required: 10, principal: 'principal-id'});
        console.log('Verification result:', result);

        // Get validators
        const validators = await blockID.getValidators();
        console.log('Validators:', validators);
    } catch (error: any) {
        console.error('Error:', error.message);
    }
}

example();