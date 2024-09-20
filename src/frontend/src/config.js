const IS_DEV = import.meta.env.DEV;

console.log('IS_DEV', IS_DEV);

const INTERNET_IDENTITY_CANISTER_ID = import.meta.env.VITE_INTERNET_IDENTITY_CANISTER_ID;
const FRONTEND_CANISTER_ID = import.meta.env.VITE_FRONTEND_CANISTER_ID;
const BACKEND_CANISTER_ID = import.meta.env.VITE_BACKEND_CANISTER_ID;
const host = import.meta.env.VITE_HOST;

console.log('env', { INTERNET_IDENTITY_CANISTER_ID, BACKEND_CANISTER_ID, host });

const II_CANISTER_ID = !IS_DEV
    ? 'https://identity.ic0.app'
    : `http://${INTERNET_IDENTITY_CANISTER_ID}.${host}`;

const BACKEND_CANISTER_URL = !IS_DEV
    ? `https://${BACKEND_CANISTER_ID}.icp0.io` // consistently use the icp0.io domain, don't use the ic0.app domain
    : `http://${BACKEND_CANISTER_ID}.${host}`;

const FRONTEND_URL = !IS_DEV
    ? `https://${FRONTEND_CANISTER_ID}.icp0.io` // consistently use the icp0.io domain, don't use the ic0.app domain
    : `http://${FRONTEND_CANISTER_ID}.${host}`;


const FRONTEND_DOMAIN = `https://blockid.cc`;
const APPLICATION_ID = 'block-id';

export const config = {
    II_CANISTER_ID,
    BACKEND_CANISTER_ID,
    FRONTEND_URL,
    APPLICATION_ID
};