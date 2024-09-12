<script setup>
    import { ref, onMounted } from 'vue';
    import { Principal } from '@dfinity/principal';
    import { AuthClient } from '@dfinity/auth-client';
    import { requestVerifiablePresentation } from "@dfinity/verifiable-credentials/request-verifiable-presentation";

    const loading = ref(true);
    const isAuthenticated = ref(false);
    const userPrincipal = ref(null);
    const errorMessage = ref('');
    const verify = async () => {
        try {
            const issuerData = {
                origin: 'https://id.decideai.xyz',
                canisterId: Principal.fromText('qgxyr-pyaaa-aaaah-qdcwq-cai'),
            };
            const credentialData = {
                credentialSpec: {
                    credentialType: 'ProofOfUniqueness',
                    arguments: {}
                },
                credentialSubject: Principal.fromText(userPrincipal.value)
            };
            const onSuccess = (response) => 
                console.log('VC Request Successful:', response);

            const onError = (error) =>
                console.error('VC Request Failed:', error);
            
            const identityProvider =  new URL("https://identity.ic0.app/");
            
            const derivationOrigin = undefined;
            
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
                console.error("Error getting credentials:", error);
            }
    }
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
            console.error("Error checking authentication:", error);
            errorMessage.value = "An error occurred while checking authentication.";
        } finally {
            loading.value = false;
        }
    };

    const handleLogin = async () => {
        loading.value = true;
        try {
            const authClient = await AuthClient.create();
            await authClient.login({
                identityProvider: "https://identity.ic0.app",
                onSuccess: async () => {
                    const identity = authClient.getIdentity();
                    userPrincipal.value = identity.getPrincipal().toText();
                    isAuthenticated.value = true;
                    errorMessage.value = ''; // Clear error message on successful login
                },
            });
        } catch (error) {
            console.error("Error during login:", error);
            errorMessage.value = "Login failed. Please try again later.";
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
            console.error("Error during logout:", error);
            errorMessage.value = "An error occurred while trying to logout.";
        }
    };

    const shortenPrincipal = (principal) => {
        if (!principal) return '';
        return `${principal.slice(0, 6)}...${principal.slice(-3)}`;
    };

    onMounted(checkAuth);
</script>
<template>
    <!-- start header --> 
    <header class="header-with-topbar">
            <div class="header-top-bar top-bar-dark cover-background" style="background-image: url('/images/demo-hosting-header-bg.jpg')">
                <div class="container-fluid">
                    <div class="row h-42px align-items-center m-0">
                        <div class="col-md-7 text-center text-md-start">
                            <div class="fs-13 text-white"><span class="opacity-6 me-5px">Build your identity and reputation on blockchain with a multifaceted and flexible</span><span class="fw-600">verification system</span></div>
                        </div>
                        <div class="col-5 text-end d-none d-md-flex">
                            <a href="demo-hosting-contact.html" class="widget fs-13 me-20px text-white opacity-8 d-none d-lg-inline-block"><i class="feather icon-feather-phone"></i>Call us</a> 
                            <a href="mailto:support@domain.com" class="widget fs-13 text-white text-white-hover opacity-8"><i class="feather icon-feather-mail text-white position-relative top-1px"></i>support@blockid.cc</a>
                        </div>
                    </div>
                </div>
            </div>
            <!-- start navigation -->
            <nav class="navbar navbar-expand-lg header-transparent" data-header-hover="dark">
                <div class="container-fluid">
                    <div class="col-auto col-lg-2 me-lg-0 me-auto">
                        <a class="navbar-brand" href="#">
                            <img src="" data-at2x="images/logo-ok.png" alt="" class="default-logo  bg-white border-radius-6px p-2">
                            <img src="" data-at2x="images/logo-ok.png" alt="" class="alt-logo">
                            <img src="" data-at2x="images/logo-ok.png" alt="" class="mobile-logo"> 
                        </a>
                    </div>
                    <div class="col-auto menu-order position-static">
                        <button class="navbar-toggler float-start" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                            <span class="navbar-toggler-line"></span>
                            <span class="navbar-toggler-line"></span>
                            <span class="navbar-toggler-line"></span>
                            <span class="navbar-toggler-line"></span>
                        </button>
                        <div class="collapse navbar-collapse" id="navbarNav"> 
                            <ul class="navbar-nav"> 
                                <li class="nav-item"><a href="demo-hosting.html" class="nav-link">Home</a></li>
                                <li class="nav-item"><a href="demo-hosting-about.html" class="nav-link">About Block ID</a></li>
                                <li class="nav-item"><a href="demo-hosting-contact.html" class="nav-link">Contact</a></li>
                            </ul>
                        </div>
                    </div>
                    <div class="col-auto col-lg-2 text-end lg-pe-5px">
                        <div class="header-icon">
                            <span v-if="isAuthenticated" class="me-2 text-danger">
                                    {{ shortenPrincipal(userPrincipal) }}
                                </span>
                            <div class="header-button ms-30px xxl-ms-10px xs-ms-0">
                                <a href="#" class="btn btn-white btn-small btn-rounded btn-box-shadow btn-switch-text fw-600" @click="isAuthenticated ? logout() : handleLogin()">
                                    <span>
                                        <span v-if="!isAuthenticated" class="btn-double-text" data-text="Connect">Connect</span> 
                                        <span v-if="isAuthenticated" class="btn-double-text btn-danger" data-text="Disconnect">Disconnect</span> 
                                    </span>
                                </a>
                            </div>
                        </div>  
                    </div>
                </div>
            </nav>
            <!-- end navigation -->
        </header>
        <!-- end header --> 
</template>