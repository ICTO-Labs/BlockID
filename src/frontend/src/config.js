export const IS_DEV = import.meta.env.DEV;
export const DERIVATION_ORIGIN = IS_DEV ? 'http://localhost:3000' : 'https://y3yam-6aaaa-aaaap-qb7aq-cai.icp0.io';
export const END_POINT = IS_DEV ? 'http://localhost:4943' : 'https://icp0.io';
export const INTERNET_INDENTITY = IS_DEV ? 'https://identity.ic0.app' : 'https://identity.ic0.app';
export const BACKEND_CANISTER_ID = import.meta.env.VITE_BACKEND_CANISTER_ID
export const FRONTEND_CANISTER_ID = import.meta.env.VITE_FRONTEND_CANISTER_ID
export const VC_VALIDATOR_CANISTER_ID = import.meta.env.VITE_VALIDATE_CANISTER_ID
export const ISSUER_CANISTER_ID = import.meta.env.VITE_INTERNET_IDENTITY_CANISTER_ID
console.log('IS_DEV', IS_DEV, import.meta.env)

export const FRONTEND_DOMAIN = import.meta.env.VITE_DERIVATION_ORIGIN;
export const APPLICATION_ID = 'block-id';
export const WALLETS = {
    'INTERNET_IDENTITY': {
        name: 'Internet Identity',
        logo: '/images/partners/ii.svg',
        id: 'INTERNET_IDENTITY',
        default: true
    },
    'PLUG': {
        name: 'Plug Wallet',
        logo: '/images/partners/plug.svg',
        id: 'PLUG',
        default: false
    },
    'STOIC': {
        name: 'Stoic Wallet',
        logo: '/images/partners/stoic.svg',
        id: 'STOIC',
        default: false
    },
    'METAMASK': {
        name: 'MetaMask',
        logo: '/images/partners/metamask.svg',
        id: 'METAMASK',
        default: false
    }
};

export const config = {
    BACKEND_CANISTER_ID,
    APPLICATION_ID
};
