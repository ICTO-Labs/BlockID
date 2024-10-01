<script setup>
import { ref, onMounted } from 'vue';
import { Actor, HttpAgent } from '@dfinity/agent';
import { Principal } from '@dfinity/principal';
import { AuthClient } from '@dfinity/auth-client';
import { requestVerifiablePresentation } from '@dfinity/verifiable-credentials/request-verifiable-presentation';
import { useWalletStore } from '@/store/walletStore';
//load data from localstorage when refresh
const walletStore = useWalletStore();
walletStore.loadFromLocalStorage();

// import { BlockID_backend } from 'declarations/BlockID_backend/index';
import { validate } from '../../declarations/validate/index';
const loading = ref(true);
const isAuthenticated = ref(false);
const userPrincipal = ref(null);
const errorMessage = ref('');
const jwt = ref('');
console.log('ENV:', import.meta.env);
const validateJwt = async () => {
    console.log('Start verify...');
    try {
        const requestVerify = await validate.validate_ii_vp({
            effective_vc_subject: Principal.fromText(userPrincipal.value),
            issuer_origin: 'https://id.decideai.xyz/',
            issuer_canister_id: Principal.fromText(
                'qgxyr-pyaaa-aaaah-qdcwq-cai'
            ),
            vp_jwt: jwt.value,
            credential_spec: {
                credential_type: 'ProofOfUniqueness',
                arguments: []
            }
        });
        console.log('requestVerify', requestVerify);
        if ('Err' in requestVerify) {
            console.log('Err', requestVerify.Err);
        }
        // Then 'Ok' is in response and the credentials are valid.
        console.log('OK', requestVerify.Ok);
    } catch (error) {
        console.log('Error validating JWT:', error);
    }
};

const verify = async () => {
    try {
        const issuerData = {
            origin: 'https://id.decideai.xyz',
            canisterId: Principal.fromText('qgxyr-pyaaa-aaaah-qdcwq-cai')
        };
        const credentialData = {
            credentialSpec: {
                credentialType: 'ProofOfUniqueness',
                arguments: {}
            },
            credentialSubject: Principal.fromText(userPrincipal.value)
        };
        const onSuccess = async (response) => {
            console.log('VC Request Successful:', response);
            //Send request to validate
            jwt.value = response.Ok;
            await validateJwt();
        };

        const onError = (error) => console.error('VC Request Failed:', error);

        const identityProvider = new URL('https://identity.ic0.app/');

        const derivationOrigin = 'https://3f66t-ryaaa-aaaap-qhriq-cai.icp0.io';

        const requestParams = {
            onSuccess,
            onError,
            credentialData,
            issuerData,
            identityProvider,
            derivationOrigin
        };
        console.log(requestParams);
        requestVerifiablePresentation(requestParams);
    } catch (error) {
        console.error('Error getting credentials:', error);
    }
};
const checkAuth = async () => {
    try {
        const authClient = await AuthClient.create();
        isAuthenticated.value = await authClient.isAuthenticated();
        if (isAuthenticated.value) {
            const identity = authClient.getIdentity();
            userPrincipal.value = identity.getPrincipal().toText();
            errorMessage.value = ''; // Clear any previous error message
        }
    } catch (error) {
        console.error('Error checking authentication:', error);
        errorMessage.value = 'An error occurred while checking authentication.';
    } finally {
        loading.value = false;
    }
};

const handleLogin = async () => {
    loading.value = true;
    try {
        const authClient = await AuthClient.create();
        await authClient.login({
            identityProvider: 'https://identity.ic0.app',
            derivationOrigin: 'https://3f66t-ryaaa-aaaap-qhriq-cai.icp0.io',
            onSuccess: async () => {
                const identity = authClient.getIdentity();
                userPrincipal.value = identity.getPrincipal().toText();
                isAuthenticated.value = true;
                errorMessage.value = ''; // Clear error message on successful login
            }
        });
    } catch (error) {
        console.error('Error during login:', error);
        errorMessage.value = 'Login failed. Please try again later.';
    } finally {
        loading.value = false;
    }
};

const logout = async () => {
    try {
        const authClient = await AuthClient.create();
        await authClient.logout();
        isAuthenticated.value = false;
        userPrincipal.value = null;
        errorMessage.value = ''; // Clear error message on successful logout
    } catch (error) {
        console.error('Error during logout:', error);
        errorMessage.value = 'An error occurred while trying to logout.';
    }
};

onMounted(() => {
    checkAuth();
});

const drawer = ref(false);
const menuItems = [
    { title: 'Blog', icon: 'mdi-post', to: '/blog' },
    { title: 'Learn', icon: 'mdi-school', to: '/learn' },
    { title: 'Support', icon: 'mdi-lifebuoy', to: '/support' },
    { title: 'Ecosystem', icon: 'mdi-earth', to: '/ecosystem' },
    { title: 'Team', icon: 'mdi-account-group', to: '/team' },
    { title: 'Playground', icon: 'mdi-play-circle', to: '/playground' }
];
</script>

<template>
    <router-view></router-view>
</template>
