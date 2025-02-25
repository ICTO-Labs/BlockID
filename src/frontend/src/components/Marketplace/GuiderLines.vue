<!-- pages/marketplace/guidelines.vue -->
<template>
    <v-row>
        <v-col cols="12" md="8">
            <h1 class="text-h4 mb-6">Provider Development Guidelines</h1>

            <v-card class="mb-6">
                <v-card-title>Provider Interface</v-card-title>
                <v-card-text>
                    <code-block language="motoko">
                        actor {
                        public type VerificationResult = {
                        isValid: Bool;
                        score: Nat;
                        message: Text;
                        };

                        public shared func verify(
                        walletId: Principal,
                        params: ?[{key: Text; value: Text}]
                        ) : async VerificationResult;
                        }
                    </code-block>
                </v-card-text>
            </v-card>

            <v-card class="mb-6">
                <v-card-title>Development Workflow</v-card-title>
                <v-card-text>
                    <v-timeline dense>
                        <v-timeline-item>
                            <strong>1. Development</strong>
                            <div class="mt-2">
                                - Clone template repository<br>
                                - Implement verification logic<br>
                                - Test locally with dfx
                            </div>
                        </v-timeline-item>

                        <v-timeline-item>
                            <strong>2. Testing</strong>
                            <div class="mt-2">
                                - Deploy to IC testnet<br>
                                - Use test environment to validate<br>
                                - Verify all edge cases
                            </div>
                        </v-timeline-item>

                        <v-timeline-item>
                            <strong>3. Submission</strong>
                            <div class="mt-2">
                                - Submit provider to marketplace<br>
                                - Include test cases and documentation<br>
                                - Wait for review
                            </div>
                        </v-timeline-item>
                    </v-timeline>
                </v-card-text>
            </v-card>

            <v-card>
                <v-card-title>Best Practices</v-card-title>
                <v-card-text>
                    <v-list>
                        <v-list-item>
                            <v-list-item-icon>
                                <v-icon>mdi-check-circle</v-icon>
                            </v-list-item-icon>
                            <v-list-item-content>
                                <v-list-item-title>Error Handling</v-list-item-title>
                                <v-list-item-subtitle>
                                    Always return meaningful error messages
                                </v-list-item-subtitle>
                            </v-list-item-content>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-icon>
                                <v-icon>mdi-check-circle</v-icon>
                            </v-list-item-icon>
                            <v-list-item-content>
                                <v-list-item-title>Parameter Validation</v-list-item-title>
                                <v-list-item-subtitle>
                                    Validate all input parameters thoroughly
                                </v-list-item-subtitle>
                            </v-list-item-content>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-icon>
                                <v-icon>mdi-check-circle</v-icon>
                            </v-list-item-icon>
                            <v-list-item-content>
                                <v-list-item-title>Documentation</v-list-item-title>
                                <v-list-item-subtitle>
                                    Include clear documentation and examples
                                </v-list-item-subtitle>
                            </v-list-item-content>
                        </v-list-item>
                    </v-list>
                </v-card-text>
            </v-card>
        </v-col>

        <v-col cols="12" md="4">
            <!-- Quick Links -->
            <v-card class="mb-6">
                <v-card-title>Quick Links</v-card-title>
                <v-card-text>
                    <v-list dense>
                        <v-list-item href="/marketplace/test-environment">
                            <v-list-item-icon>
                                <v-icon>mdi-test-tube</v-icon>
                            </v-list-item-icon>
                            <v-list-item-content>
                                <v-list-item-title>Test Environment</v-list-item-title>
                            </v-list-item-content>
                        </v-list-item>

                        <v-list-item href="https://github.com/blockid/provider-template">
                            <v-list-item-icon>
                                <v-icon>mdi-github</v-icon>
                            </v-list-item-icon>
                            <v-list-item-content>
                                <v-list-item-title>Template Repository</v-list-item-title>
                            </v-list-item-content>
                        </v-list-item>
                    </v-list>
                </v-card-text>
            </v-card>
        </v-col>
    </v-row>
</template>