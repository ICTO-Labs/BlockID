# BlockID SDK

Official SDK for integrating BlockID verification system into your applications.

We support all IC wallets, including Internet Identity using VC Flow.
## Installation

```bash
npm install @blockid/sdk
```

## Quick Start

```javascript
import { BlockID } from '@blockid/sdk';

// Initialize SDK
const blockID = new BlockID({
  host: 'https://icp0.io',// Optional, defaults to https://icp0.io
  appId: 'your-app-id'// Optional, defaults to 'block-id'
});

// Verify with BlockID, ensure your wallet is connected to your dApp
const result = await blockID.verifyScore({required: 10, principal: 'principal-id'});
console.log('Verification result:', result);

// Verify score with Internet Identity using VC Flow
const result = await blockID.verifyScore({required: 10, principal: 'principal-id', vcFlow: true});
console.log('Verification result:', result);
```

Create your app on [BlockID Dashboard](https://blockid.cc/applications) and get your appId. Or use default appId and verify with BlockID.

## API Reference

### Configuration and Result

```typescript
interface BlockIDConfig {
  host?: string;         // IC network host
  appId?: string;        // Application ID (defaults to 'block-id')
}

interface VerifyScoreResult {
    success: boolean; // true if wallet meets score requirements
    message?: string; // error message
    details?: any; // verification details
    score?: number; // wallet score, not show if vcFlow is true
    principal?: string; // wallet principal
}
```

### Methods

#### `verifyScore(obj: {required: number, principal: string, vcFlow?: boolean})`
Verify if wallet meets score requirements

#### `getValidators(applicationId?: string)`
Get list of validators for an application

#### `meetsRequirements(principal: string, minScore: number, validatorId?: string)`
Check if wallet meets score requirements

## Error Handling

```javascript
try {
  const score = await blockID.getWalletScore('principal-id');
} catch (error) {
  console.error('Error:', error.message);
}
```

## TypeScript Support
This SDK is written in TypeScript and includes type definitions.

## Contributing
We welcome contributions! Please see our contributing guidelines for details.

## License
MIT