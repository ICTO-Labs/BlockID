const IS_DEV = import.meta.env.VITE_ENV === 'development';

console.log('IS_DEV', IS_DEV);

const internetIdentityCanisterId = import.meta.env.VITE_INTERNET_IDENTITY_CANISTER_ID;
const civicBackendCanisterId = IS_DEV ? import.meta.env.VITE_CIVIC_BACKEND_CANISTER_ID : 'be2us-64aaa-aaaaa-qaabq-cai';
const host = import.meta.env.VITE_HOST;

console.log('env', { internetIdentityCanisterId, civicBackendCanisterId, host });

const II_CANISTER_ID = !IS_DEV
    ? 'https://identity.ic0.app'
    : `http://${internetIdentityCanisterId}.${host}`;

const BACKEND_CANISTER_ID = !IS_DEV
    ? `https://${civicBackendCanisterId}.icp0.io` // consistently use the icp0.io domain, don't use the ic0.app domain
    : `http://${civicBackendCanisterId}.${host}`;

const FRONTEND_URL = !IS_DEV
    ? `https://${civicBackendCanisterId}.icp0.io` // consistently use the icp0.io domain, don't use the ic0.app domain
    : `http://${civicBackendCanisterId}.${host}`;


const FRONTEND_CANISTER_ID = `https://icp-getpass.civic.com`;
const FRONTEND_CANISTER_URL = `https://icp-getpass.civic.com`;


export const config = {
    II_CANISTER_ID,
    BACKEND_CANISTER_ID,
    FRONTEND_URL
};