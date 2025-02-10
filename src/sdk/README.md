# BlockID SDK

Official SDK for integrating BlockID verification system into your applications.

## Installation

```bash
npm install @blockid/sdk
```

## Quick Start

```javascript
import { BlockID } from '@blockid/sdk';

// Initialize SDK
const blockID = new BlockID({
  host: 'https://icp0.io',        // Optional, defaults to https://icp0.io
  appId: 'your-app-id'           // Optional, defaults to 'block-id'
});

// Get wallet verification details
const walletDetail = await blockID.getWalletDetail('principal-id');

// Get wallet score
const score = await blockID.getWalletScore('principal-id');

// Check if wallet meets requirements
const meetsRequirement = await blockID.meetsRequirements('principal-id', 50);

// Check score for specific validator
const meetsValidatorRequirement = await blockID.meetsRequirements('principal-id', 20, 'validator-id');
```

## API Reference

### Configuration

```typescript
interface BlockIDConfig {
  host?: string;         // IC network host
  appId?: string;        // Application ID (defaults to 'block-id')
}
```

### Methods

#### `getWalletDetail(principal: string)`
Get detailed verification information for a wallet

#### `getWalletScore(principal: string)`
Get wallet's score information

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