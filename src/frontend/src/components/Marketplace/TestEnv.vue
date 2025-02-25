<script setup>
import { ref } from 'vue'
import { useWalletStore } from '@/store/walletStore'
import { runProviderTest, getProviderMetadata } from '@/services/marketplaceService'
import { Principal } from '@dfinity/principal'
import Notify from '@/plugins/notify'
const steps = ref([
    {
        title: 'Clone Template',
        description: 'Clone the provider template repository'
    },
    {
        title: 'Deploy to IC',
        description: 'Deploy the provider to the IC'
    },
    {
        title: 'Test Integration',
        description: 'Test the provider integration'
    }
])
const currentStep = ref(1)
const valid = ref(false)
const testing = ref(false)
const loadingMetadata = ref(false)
const providerMetadata = ref(null)
const testData = ref({
    canisterId: '',
    params: []
})

const newParam = ref({
    key: '',
    value: ''
})

const testResult = ref(null)

const addParameter = () => {
    if (newParam.value.key && newParam.value.value) {
        testData.value.params.push({ ...newParam.value })
        newParam.value = { key: '', value: '' }
    }
}
const isPrincipal = (p)=>{
    try {
        return (p === Principal.fromText(p).toText());
    } catch (e) {
        return false;
    }
}
const canisterIdRules = [
    v => !!v || 'Canister id is required',
    v => isPrincipal(v) || 'Canister id is not valid'
]
const removeParameter = (index) => {
    testData.value.params.splice(index, 1)
}

async function runTest() {
    testing.value = true
    try {
        // Run test
        const result = await runProviderTest(
            Principal.fromText(testData.value.canisterId),
            Principal.fromText(testData.value.wallet),
            testData.value.params.length ? [testData.value.params] : [[]]
        );
        console.log(result)
        if(result && "err" in result) {
            Notify.error('Test failed:' + JSON.stringify(result))
            testResult.value = {
                isValid: false,
                score: 0,
                message: `Test failed: ${result.err}`
            };
        }else{
            testResult.value = result;
        }
    } catch (err) {
        testResult.value = {
            isValid: false,
            score: 0,
            message: `Test failed: ${err.message}`
        };
    }
    testing.value = false
}
async function getMetadata() {
    loadingMetadata.value = true
    const result = await getProviderMetadata(Principal.fromText(testData.value.canisterId))
    console.log(result)
    if(result && "err" in result) {
        Notify.error('Failed to get metadata:' + JSON.stringify(result))
    }else{
        providerMetadata.value = result
    }
    loadingMetadata.value = false
}
</script>
<template>
    <v-row>
        <v-col cols="12">
            <v-card-title class="d-flex justify-space-between align-center">
                    Provider Test Environment
                    <div class="d-flex justify-space-between align-center">
                    <v-btn color="default" :to="{ path: '/marketplace' }" class="mr-2">
                        <v-icon left>mdi-arrow-left</v-icon>
                        Marketplace
                    </v-btn>
                    <v-btn color="primary" :to="{ path: '/marketplace/submit' }">
                        <v-icon left>mdi-console</v-icon>
                        Submit Provider
                    </v-btn>
                </div>
            </v-card-title>
            <!-- Quick Start Guide -->
            <v-card class="mb-6">
                <v-card-title>
                    <v-icon left>mdi-rocket-launch</v-icon>
                    Quick Start Guide

                </v-card-title>
                <v-card-text>
                    <v-stepper :items="steps">
                        <template v-slot:item.1>
                            <v-card title="Step One" >
                                <div class="mb-4">
                                    Clone the provider template repository to your local machine or use <strong>Motoko Playground</strong> by clicking <a href="https://play.motoko.org/?tag=6803447" target="_blank">here</a> to open sample project
                                    <div class="code-block"><pre><code>git clone https://github.com/ICTO-Labs/provider-template.git
cd provider-template</code></pre></div>

Customize your verification logic, then run deploy in local:
<div class="code-block"><pre><code>dfx start --background
dfx canister create providerTemplate
dfx deploy providerTemplate</code></pre></div>
                                </div>
                            </v-card>
                        </template>

                        <template v-slot:item.2>
                            <v-card title="Step Two" flat>
                                <div class="mb-4">
                                    Deploy the provider module to the IC (mainnet) when you are ready to test on mainnet:
                                    <div class="code-block"><pre><code>dfx deploy providerTemplate --network ic</code></pre></div>
                                </div>
                            </v-card>
                        </template>

                        <template v-slot:item.3>
                            <v-card title="Step Three" flat>
                                <div class="mb-4">
                                    Test the provider integration or use the test console below to test the provider integration:
                                    <div class="code-block"><pre><code>dfx canister call providerTemplate verify(principal \"aaaaa-aa\", null) --network ic</code></pre></div>
                                </div>
                            </v-card>
                        </template>

                    </v-stepper>
                </v-card-text>
            </v-card>

            <!-- Test Console -->
            <v-card>
                <v-card-title>
                    <v-icon left>mdi-console</v-icon>
                    Test Console
                </v-card-title>

                <v-card-text>
                    <v-form ref="form" v-model="valid">
                        <!-- Canister ID Input -->
                        <v-row>
                            <v-col cols="12" md="6">
                                <v-text-field v-model="testData.canisterId" label="Provider Canister ID"
                            :rules="canisterIdRules"
                            hint="Enter your deployed test provider canister ID" persistent-hint />
                            </v-col>
                            <v-col cols="12" md="6">
                                <v-text-field v-model="testData.wallet" label="Wallet Principal"
                            :rules="[v => !!v || 'Wallet Principal is required']"
                            hint="Enter your wallet principal" persistent-hint />
                            </v-col>
                        </v-row>

                        <!-- Test Parameters -->
                        <v-row>
                            <v-col cols="12" md="6">
                                <v-text-field v-model="newParam.key" label="Parameter Key" />
                            </v-col>
                            <v-col cols="12" md="6">
                                <v-text-field v-model="newParam.value" label="Parameter Value" />
                            </v-col>
                        </v-row>

                        <v-btn small color="secondary" class="mb-4" @click="addParameter">
                            Add Parameter
                        </v-btn>

                        <!-- Parameters List -->
                        <v-list dense v-if="testData.params.length">
                            <v-list-item v-for="(param, i) in testData.params" :key="i">
                                <v-list-item-content>
                                    <v-list-item-title>
                                        {{ param.key }}: {{ param.value }}
                                    </v-list-item-title>
                                    <v-list-item-action>
                                        <v-btn icon small @click="removeParameter(i)">
                                            <v-icon>mdi-delete</v-icon>
                                        </v-btn>
                                    </v-list-item-action>
                                </v-list-item-content>
                            </v-list-item>
                        </v-list>

                        <!-- Test Actions -->
                        <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn color="primary" :loading="testing" :disabled="!valid" @click="runTest" variant="outlined">
                                Run Test <v-icon>mdi-console</v-icon>
                            </v-btn>
                            <v-btn color="info" :loading="loadingMetadata" @click="getMetadata" variant="outlined">
                                Get Provider Metadata <v-icon>mdi-code-json</v-icon>
                            </v-btn>
                        </v-card-actions>
                    </v-form>

                    <!-- Test Results -->
                    <v-expand-transition>
                        <div v-if="testResult">
                            <v-divider class="my-4"></v-divider>
                            <h3 class="text-h6 mb-2">Test Results</h3>
                            <v-alert :type="testResult?.isValid ? 'success' : 'error'" border="left">
                                <div><strong>Status:</strong> {{ testResult?.isValid ? 'Valid' : 'Invalid' }}</div>
                                <div><strong>Score:</strong> {{ testResult?.score }}</div>
                                <div><strong>Message:</strong> {{ testResult?.message }}</div>
                            </v-alert>
                        </div>
                    </v-expand-transition>
                    <v-expand-transition>
                        <div v-if="providerMetadata">
                            <v-divider class="my-4"></v-divider>
                            <h3 class="text-h6 mb-2">Provider Metadata</h3>
                            <div class="code-block"><pre><code>name = "{{ providerMetadata.name }}";
description = "{{ providerMetadata.description }}";
version = "{{ providerMetadata.version }}";
author = "{{ providerMetadata.author }}";
parameters = [
    {
        name = "{{ providerMetadata.parameters?.[0]?.name }}";
        description = "{{ providerMetadata.parameters?.[0]?.description }}";
        required = {{ providerMetadata.parameters?.[0]?.required }};
        paramType = #{{ providerMetadata.parameters?.[0]?.paramType }};
    }
];</code></pre></div>
                            
                        </div>
                    </v-expand-transition>
                </v-card-text>
            </v-card>
        </v-col>
    </v-row>
</template>
<style scoped>
.code-block {
    margin: 1rem 0;
    background: #f5f5f5;
    padding: 1rem;
    border-radius: 4px;
}
</style>