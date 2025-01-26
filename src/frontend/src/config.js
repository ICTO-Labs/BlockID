export const IS_DEV = import.meta.env.DEV;
export const DERIVATION_ORIGIN = IS_DEV ? 'http://localhost:3000' : 'https://y3yam-6aaaa-aaaap-qb7aq-cai.icp0.io';
export const END_POINT = IS_DEV ? 'http://localhost:4943' : 'https://icp0.io';
export const INTERNET_INDENTITY = IS_DEV ? 'http://be2us-64aaa-aaaaa-qaabq-cai.localhost:4943' : 'https://identity.ic0.app';
export const BACKEND_CANISTER_ID = IS_DEV ? 'bkyz2-fmaaa-aaaaa-qaaaq-cai' : '3c7yh-4aaaa-aaaap-qhria-cai';
export const FRONTEND_CANISTER_ID = IS_DEV ? 'cgpjn-omaaa-aaaaa-qaakq-cai' : '3f66t-ryaaa-aaaap-qhriq-cai';
export const VC_VALIDATOR_CANISTER_ID = IS_DEV ? 'cpmcr-yeaaa-aaaaa-qaala-cai' : 'uspxb-mqaaa-aaaap-qhxqq-cai';
export const ISSUER_CANISTER_ID = IS_DEV ? 'cinef-v4aaa-aaaaa-qaalq-cai' : 'znqos-ziaaa-aaaap-qkmia-cai';
console.log('IS_DEV', IS_DEV, END_POINT);
console.log('FRONTEND_CANISTER_ID', import.meta);
export const FRONTEND_DOMAIN = `https://blockid.cc`;
export const APPLICATION_ID = 'block-id';
export const WALLETS = {
    'INTERNET_IDENTITY': {
        name: 'Internet Identity',
        logo: 'https://app.icpswap.com/images/connect/InternetIdentity.svg',
        id: 'INTERNET_IDENTITY',
        default: true
    },
    'PLUG': {
        name: 'Plug Wallet',
        logo: 'https://app.icpswap.com/images/connect/Plug.svg',
        id: 'PLUG',
        default: false
    },
    'NFID': {
        name: 'NFID',
        logo: 'https://app.icpswap.com/images/connect/NFID.svg',
        id: 'NFID',
        default: false
    },
    'STOIC': {
        name: 'Stoic Wallet',
        logo: 'https://entrepot.app/stoic.png',
        id: 'STOIC',
        default: false
    }
};

export const WHITELIST = [
    BACKEND_CANISTER_ID,
    FRONTEND_CANISTER_ID,
    VC_VALIDATOR_CANISTER_ID,
    ISSUER_CANISTER_ID
];

export const config = {
    BACKEND_CANISTER_ID,
    APPLICATION_ID
};
