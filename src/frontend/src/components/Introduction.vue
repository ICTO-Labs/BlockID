<template>
    <v-container class="introduction-container">
        <v-row justify="center" align="center">
            <v-col cols="12" md="12" lg="10">
                <!-- Hero Section -->
                <div class="text-center mb-8">
                    <h1 class="text-h2 font-weight-bold mb-4">
                        One ID, Infinite Trust
                    </h1>
                    <p class="text-h6 text-medium-emphasis mb-6">
                        Revolutionizing digital identity verification on Internet Computer through comprehensive trust scoring and verifiable credentials
                    </p>
                    <v-row justify="center" class="mb-8">
                        <v-col cols="auto">
                            <v-btn
                                color="primary"
                                size="large"
                                to="/app"
                            >
                                Start Verification <v-icon>mdi-arrow-right</v-icon>
                            </v-btn>
                        </v-col>
                        <v-col cols="auto">
                            <v-btn
                                color="secondary"
                                size="large"
                                to="/docs"
                                variant="outlined"
                            >
                                Integration Guide <v-icon>mdi-book-open-page-variant</v-icon>
                            </v-btn>
                        </v-col>
                    </v-row>
                </div>

                <!-- Features Grid -->
                <v-row class="mb-8">
                    <v-col cols="12" sm="6" md="4">
                        <v-card class="feature-card" elevation="2">
                            <v-card-title>
                                <v-icon color="primary" size="32" class="mb-4">
                                    mdi-shield-check
                                </v-icon>
                                <h3 class="text-h6">Secure Verification</h3>
                            </v-card-title>
                            <v-card-text>
                                Decentralized identity verification using VC Flow and trusted providers
                            </v-card-text>
                        </v-card>
                    </v-col>

                    <v-col cols="12" sm="6" md="4">
                        <v-card class="feature-card" elevation="2">
                            <v-card-title>
                                <v-icon color="primary" size="32" class="mb-4">
                                    mdi-chart-bar
                                </v-icon>
                                <h3 class="text-h6">Trust Scoring</h3>
                            </v-card-title>
                            <v-card-text>
                                Comprehensive scoring system based on verified on-chain activities
                            </v-card-text>
                        </v-card>
                    </v-col>

                    <v-col cols="12" sm="6" md="4">
                        <v-card class="feature-card" elevation="2">
                            <v-card-title>
                                <v-icon color="primary" size="32" class="mb-4">
                                    mdi-cog
                                </v-icon>
                                <h3 class="text-h6">Custom Rules</h3>
                            </v-card-title>
                            <v-card-text>
                                Create and manage custom verification rules for your project
                            </v-card-text>
                        </v-card>
                    </v-col>
                </v-row>

                <!-- For Projects Section -->
                <v-card class="mb-8" elevation="2">
                    <v-card-title class="text-h5 font-weight-bold">
                        For Projects
                    </v-card-title>
                    <v-card-text>
                        <v-list>
                            <v-list-item
                                v-for="(feature, index) in projectFeatures"
                                :key="index"
                                :title="feature.title"
                                :subtitle="feature.description"
                            >
                                <template v-slot:prepend>
                                    <v-icon :color="feature.color">
                                        {{ feature.icon }}
                                    </v-icon>
                                </template>
                            </v-list-item>
                        </v-list>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>
    </v-container>
</template>

<script setup>
const projectFeatures = [
    {
        title: 'Easy Integration',
        description: 'Simple API and SDK for quick implementation',
        icon: 'mdi-puzzle',
        color: 'primary'
    },
    {
        title: 'Flexible Provider Framework',
        description: 'Create custom providers or use built-in ones',
        icon: 'mdi-view-grid-plus',
        color: 'secondary'
    },
    {
        title: 'Comprehensive Documentation',
        description: 'Detailed guides and API references',
        icon: 'mdi-book-open-page-variant',
        color: 'info'
    },
    {
        title: 'Security First',
        description: 'Built on Internet Computer with VC Flow integration',
        icon: 'mdi-shield-lock',
        color: 'success'
    }
];
</script>

<style scoped>
.introduction-container {
    padding-top: 4rem;
    padding-bottom: 4rem;
}

.feature-card {
    height: 100%;
    display: flex;
    flex-direction: column;
    text-align: center;
    padding: 1.5rem;
}

.feature-card .v-card-title {
    flex-direction: column;
    align-items: center;
}

@media (max-width: 600px) {
    .introduction-container {
        padding-top: 2rem;
        padding-bottom: 2rem;
    }
}
</style>