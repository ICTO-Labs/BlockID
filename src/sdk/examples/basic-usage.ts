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
        const wallet = await blockID.getWalletDetail('principal-id');
        console.log('Wallet details:', wallet);

        // Check requirements
        const meets = await blockID.meetsRequirements('principal-id', 50);
        console.log('Meets requirements:', meets);

        // Get validators
        const validators = await blockID.getValidators();
        console.log('Validators:', validators);
    } catch (error: any) {
        console.error('Error:', error.message);
    }
}

example();