<script setup>
import { ref } from 'vue';
const currentSection = ref('overview');
const sections = ref([
    { id: 'overview', title: 'Overview' },
    { id: 'getting-started', title: 'Getting Started' },
    { id: 'provider', title: 'Create your own Provider' },
    { id: 'integration', title: 'Integration' }
]);

const scrollToSection = (id) => {
    currentSection.value = id;
    const element = document.getElementById(id);
    if (element) {
        element.scrollIntoView({ behavior: 'smooth' });
    }
}
</script>

<template>
    <div class="documentation">
        <div class="doc-sidebar">
            <nav>
                <ul>
                    <li 
                        v-for="section in sections" 
                        :key="section.id" 
                        :class="{ active: currentSection === section.id }"
                        @click="scrollToSection(section.id)"
                    >
                        {{ section.title }}
                    </li>
                </ul>
            </nav>
        </div>

        <div class="doc-content">
            <!-- Overview Section -->
            <div id="overview" class="content-section">
                <div class="section-header">
                    <h1>BlockID Overview</h1>
                </div>
                <div class="section-content">
                    <h2>What is BlockID?</h2>
                    <p>BlockID is a decentralized identity and reputation protocol built on the Internet Computer, enabling users to build and verify their Web3 identity through various on-chain activities.
                        <a href="https://forum.dfinity.org/t/blockid-one-id-infinite-trust/36740" target="_blank" class="text-primary">Forum Post</a>
                    </p>
                    <p>
                        <img src="https://us1.discourse-cdn.com/flex015/uploads/dfn/original/3X/0/2/0245df26e2dd10d5874f3cf69ebd2e6d4f763dc3.png">
                    </p>

                    <h2>Key Features</h2>
                    <ul>
                        <li><strong>Aggregates user’s on-chain activities across multiple providers (NNS, NFT, Ledger transactions and more…)</strong> </li>
                        <li><strong>Generates a comprehensive trust score based on verified activities</strong> </li>
                        <li><strong>Provides secure identity verification for dApps through Verifiable Credentials</strong> </li>
                    </ul>
                </div>
            </div>

            <!-- Getting Started Section -->
            <div id="getting-started" class="content-section">
                <div class="section-header">
                    <h1>Getting Started</h1>
                </div>
                <div class="section-content">
                    <h2>Creating an Application</h2>
                    
                    <h3>Step 1: Register your App on BlockID Dashboard: <router-link to="/applications">Applications</router-link></h3>
                    <p>
                        Click on the <v-btn size="small" color=""><v-icon>mdi-plus</v-icon> Create application</v-btn> button at the bottom left of the page.
                    </p>
                    <p>
                        Fill in application details:
                    </p>
                    <div class="mt-2"><v-chip size="small"  color="warning">Application ID</v-chip> This is a unique identifier for your application, it will be used to identify your application in the BlockID <v-chip size="small" label color="primary" variant="outlined">eg: my-app</v-chip></div>
                            <div class="mt-2"><v-chip size="small" color="primary">Application Name</v-chip> The name of your application.</div>
                            <div class="mt-2"><v-chip size="small" color="primary">Application Description</v-chip> A short description of your application.</div>
                            <div class="mt-2"><v-chip size="small" color="primary">Application Logo</v-chip> Logo url of your application</div>

                    <h3>Step 2: Application Setup</h3>
                    <div class="setup-steps">
                        <ol>
                            <li><strong>Set up Validator:</strong>
                                <div>
                                    Validator is colection of criteria that will be used to verify the user's identity.
                                </div>
                                <ul>
                                    <li>Create a validator by clicking on the <v-btn size="small" color=""><v-icon>mdi-plus</v-icon> Create Validator</v-btn> button</li>
                                    <li>Fill in the validator details</li>
                                    <li>Click on the <v-chip size="small" color="primary">Create</v-chip> button</li>
                                </ul>
                            </li>
                            <li><strong>Set up Criteria:</strong>
                                <div>
                                    Criteria is a set of rules that will be used to verify the user's identity.
                                </div>
                                <ul>
                                    <li>Create a criteria by clicking on the <v-btn size="small" color=""><v-icon>mdi-plus</v-icon> Create Criteria</v-btn> button</li>
                                    <li>
                                        Fill in the criteria details
                                        <ul>
                                            <li>
                                                <v-chip size="small" color="primary">Criteria Name</v-chip> The name of the criteria.
                                            </li>
                                            <li>
                                                <v-chip size="small" color="primary">Criteria Description</v-chip> A short description of the criteria.
                                            </li>
                                            <li>
                                                <v-chip size="small" color="warning">Criteria Score</v-chip> The score of the criteria if the user meets the criteria.
                                            </li>
                                            <li>
                                                <v-chip size="small" color="primary">Criteria Type</v-chip> The type of the criteria. Click to <v-chip size="small" color="primary">Using Verifiable Credentials (VC Flow)</v-chip> if you want to use <a href="https://internetcomputer.org/docs/current/developer-docs/identity/verifiable-credentials/how-it-works" target="_blank">VC Flow</a>
                                            </li>
                                            <li>
                                                <v-chip size="small" color="primary">Expiration Time</v-chip> The expiration time of the criteria (in seconds).
                                            </li>
                                            <li>
                                                <v-chip size="small" color="primary">Provider</v-chip> Provider is id of module that will be used to verify the criteria, eg: <v-chip size="small" color="primary">NNS, NFT Holder, Ledger, etc.</v-chip>. Some provider is built-in provider (built by BlockID), you can also create your own provider by using Remote Canister.
                                            </li>
                                        </ul>
                                    </li>
                                    <li>Click on the <v-chip size="small" color="primary">Create</v-chip> button</li>
                                </ul>
                            </li>
                        </ol>
                    </div>
                </div>
            </div>

            <!-- Integration Guide Section -->
            <div id="provider" class="content-section">
                <div class="section-header">
                    <h1>Create your own Provider</h1>
                </div>
                <div class="section-content">
                    <h2>1. Create a new Provider</h2>
                    
                    <h3>Step 1: Create a new Provider</h3>
                        Login to your BlockID Dashboard and click on the <v-btn size="small" ><v-icon>mdi-cog</v-icon> </v-btn> at left sidebar, or click on the <router-link to="/providers">Providers</router-link> and click on the <v-btn size="small" color=""><v-icon>mdi-plus</v-icon> Create Provider</v-btn> button at the bottom left of the page.
                        
                        <ul>
                            <li>Fill in the provider details</li>
                            <li><v-chip size="small" color="primary">Provider ID</v-chip> This is a unique identifier for your provider, it will be used to identify your provider in the BlockID <v-chip size="small" label color="primary" variant="outlined">eg: my-provider</v-chip></li>
                            <li><v-chip size="small" color="primary">Provider Name</v-chip> The name of your provider.</li>
                            <li><v-chip size="small" color="primary">Provider Description</v-chip> A short description of your provider.</li>
                            <li><v-chip size="small" color="primary">Module Type</v-chip> Choose <v-chip size="small" color="primary">Remote Canister</v-chip> if you want to create a new provider by using Remote Canister.</li>
                            <li><v-chip size="small" color="primary">Remote Canister ID</v-chip> Enter you canister ID, which implement the <v-chip size="small" color="primary">Provider Interface</v-chip>.</li>
                            <li><v-chip size="small" color="primary">Params</v-chip> Define the params that will be used to verify the criteria (optional).</li>
                        </ul>

                    <h3>Provider Interface</h3>
                    <p>
                        This interface will be implemented on your canister (Which you have entered in the <v-chip size="small" color="primary">Remote Canister ID</v-chip> field).
                    </p>
                    <div class="code-block">
<pre><code>module {
    public type VerificationResult = {
            score : Nat;
            message : Text;
            isValid : Bool;
    };
    public type Self = actor {
            verify : shared Principal -> async VerificationResult;
    }
}</code></pre>

                    </div>
                    We have built the Whitelist Canister for Quokka, you can checkout our git repo for more details: <a href="https://github.com/ICTO-Labs/BlockID/tree/main/src/whitelist" target="_blank">BlockID Interface</a>

                    <h2>2. Add to your Criteria</h2>
                    
                    <p>
                        After you have created a new provider, you can add it to your criteria by <v-btn size="small" color="primary" @click="scrollToSection('getting-started')">Create Criteria section</v-btn> and add your provider ID to the <v-chip size="small" color="primary">Provider</v-chip> field.
                    </p>
                </div>
            </div>

            <!-- API Reference Section -->
            <div id="integration" class="content-section">
                <div class="section-header">
                    <h1>Integration</h1>
                </div>
                <div>
                    This will show you how to use BlockID in your project.
                    <v-alert type="warning">
                        Note: If your project uses Internet Identity, you will need to utilize VC Flow for verification, where BlockID will act as the issuer and your project will serve as the relying party (see details in the later section). If other wallets with fixed identities are used eg: Oisy, Plugwallet, NFID, they will follow the method outlined below
                    </v-alert>
                </div>
                <div class="section-content">

                    <h3>Get Wallet Score (From your canister)</h3>
                        <div class="code-block">
<pre><code>stable var REQUIRED_SCORE: Nat = 0;//BlockID required score
let BLOCK_ID_CANISTER_ID = "3c7yh-4aaaa-aaaap-qhria-cai";
let BLOCK_ID_APPLICATION = "block-id";
let _blockID : BlockID.Self = actor(BLOCK_ID_CANISTER_ID);
private func checkBlockIDScore(principal: Principal) : async Bool {
    try {
        if(REQUIRED_SCORE == 0) return true;
        let score = await _blockID.getWalletScore(principal, BLOCK_ID_APPLICATION);
        score.totalScore >= REQUIRED_SCORE;
    } catch (e) {
        false;
    };
};</code></pre></div>
                        
                <h3>Verify Wallet (From your frontend)</h3>
                <div>
                    This will show you how to use BlockID in your project from frontend.
                Please note: This will be verify if the connected wallet is not using Internet Identity (NNS wallet)
                </div>
                <div class="section-content">

<div class="code-block"><pre><code>public type WalletId = Principal;
//Wallet ID is the principal of the wallet
//Text is the ID of the application you want to verify, eg: block-id
getWalletScore : shared query (WalletId, Text) -> async {
    linkedWallet : ?(WalletId, Nat);
    linkedScore : Nat;
    primaryScore : Nat;
    totalScore : Nat;
    percentileAbove : Float;
};
</code></pre></div>
                        
See more details in <a href="https://github.com/ICTO-Labs/icto.app/blob/main/frontend/services/BlockId.js" target="_blank">BlockId.js</a>

                </div>

                <h3 class="danger">VC Flow</h3>
                <div>
                    This is the flow for using VC Flow to verify the wallet. Which BlockID will act as the issuer and your project will serve as the relying party.
                </div>
                <div class="code-block">
<pre><code>IdentityProviderUrl: https://identity.ic0.app
issuerOrigin: https://blockid.cc
issuerCanisterId: znqos-ziaaa-aaaap-qkmia-cai
credentialType: VerifiedScore</code></pre>
                </div>

                <p>
                    See more details in <a href="https://github.com/ICTO-Labs/dummy-relying-party/tree/main" target="_blank">dummy-relying-party</a>
                </p>
            </div>
        </div>
    </div>
    </div>
</template>

<style scoped>
.documentation {
    display: flex;
    margin: 0 auto;
    padding: 2rem;
    gap: 2rem;
}

.doc-sidebar {
    position: sticky;
    top: 2rem;
    width: 250px;
    height: fit-content;
    background: #fff;
    border-right: 1px solid #eee;
    padding-right: 1rem;
}

.doc-content {
    flex: 1;
}

nav ul {
    list-style: none;
    padding: 0;
    margin: 0;
}

nav li {
    padding: 0.75rem 1rem;
    cursor: pointer;
    border-left: 3px solid transparent;
    transition: all 0.2s ease;
    font-size: 0.95rem;
}

nav li:hover {
    border-left-color: #3498db;
    background: #f5f5f5;
}

nav li.active {
    border-left-color: #3498db;
    background: #f5f5f5;
    font-weight: bold;
}

.content-section {
    margin-bottom: 4rem;
    scroll-margin-top: 2rem;
}

.section-header {
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 2px solid #eee;
}

.section-header h1 {
    font-size: 2rem;
    margin: 0;
    color: #2c3e50;
}

.section-content {
    font-size: 1rem;
    line-height: 1.6;
    color: #34495e;
}

.endpoint-block {
    margin: 2rem 0;
    padding: 1rem;
    border: 1px solid #eee;
    border-radius: 4px;
}

.endpoint-method {
    font-family: monospace;
    font-weight: bold;
    padding: 0.5rem;
    background: #f5f5f5;
    border-radius: 4px;
}

.code-block {
    margin: 1rem 0;
    background: #f5f5f5;
    padding: 1rem;
    border-radius: 4px;
}

.setup-steps {
    margin: 1rem 0;
}

h2 {
    margin-top: 2rem;
    margin-bottom: 1rem;
    font-size: 1.5rem;
    color: #2c3e50;
}

h3 {
    margin-top: 1.5rem;
    margin-bottom: 0.75rem;
    font-size: 1.25rem;
    color: #2c3e50;
}

h4 {
    margin-top: 1rem;
    margin-bottom: 0.5rem;
    font-size: 1.1rem;
    color: #2c3e50;
}

ul, ol {
    padding-left: 1.5rem;
    margin: 1rem 0;
}

li {
    margin: 0.5rem 0;
}

pre {
    margin: 0;
    overflow-x: auto;
}

code {
    font-family: 'Courier New', Courier, monospace;
}

/* Responsive Design */
@media (max-width: 768px) {
    .documentation {
        flex-direction: column;
        padding: 1rem;
    }

    .doc-sidebar {
        width: 100%;
        position: relative;
        top: 0;
        border-right: none;
        border-bottom: 1px solid #eee;
        margin-bottom: 2rem;
        padding-bottom: 1rem;
    }

    .doc-content {
        width: 100%;
    }
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
    .documentation {
        background: #1a1a1a;
        color: #fff;
    }

    .doc-sidebar {
        background: #1a1a1a;
        border-color: #333;
    }

    nav li:hover {
        background: #2a2a2a;
    }

    nav li.active {
        background: #2a2a2a;
    }

    .section-header {
        border-color: #333;
    }

    .section-header h1,
    h2, h3, h4 {
        color: #fff;
    }

    .section-content {
        color: #ddd;
    }

    .endpoint-block {
        border-color: #333;
    }

    .endpoint-method,
    .code-block {
        background: #2a2a2a;
        color: #fff;
    }
}
</style>