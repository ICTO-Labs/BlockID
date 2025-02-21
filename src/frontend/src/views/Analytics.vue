<!-- src/frontend/src/views/Analytics.vue -->

<script setup>
import { ref, onMounted } from 'vue';
import { getOverallStats, getValidatorStats } from '@/services/backendService';
import Vue3ChartJs from "@j-t-mcc/vue3-chartjs";
import zoomPlugin from "chartjs-plugin-zoom";
import dataLabels from "chartjs-plugin-datalabels";

// globally registered and available for all charts
Vue3ChartJs.registerGlobalPlugins([zoomPlugin]);

// Data
const loading = ref(false);
const search = ref('');
const overallStats = ref({});
const validatorStats = ref([]);
const validatorStatsData = ref([]);

// Reactive chart data
const doughnutChart = ref({});
const lineChart = ref({});

const verificationGrowth = ref(0);
const walletGrowth = ref(0);
const scoreGrowth = ref(0);
// Table headers
const headers = ref([
    { title: 'Validator', value: 'validatorName', sortable: true, key: 'validatorName' },
    { title: 'Total Verifications', value: 'totalVerifications', sortable: true, key: 'totalVerifications' },
    { title: 'Average Score', value: 'avgScore', sortable: true, key: 'avgScore' },
    { title: 'Success Rate', value: 'successRate', sortable: true, key: 'successRate' },
    { title: 'Last Updated', value: 'lastUpdated', sortable: true, key: 'lastUpdated' },
]);

// Methods
const formatNumber = (num) => {
    return new Intl.NumberFormat().format(num);
};

const formatPercentage = (value) => {
    return value?.toFixed(1);
};

const getSuccessRateColor = (rate) => {
    if (rate >= 90) return 'success';
    if (rate >= 70) return 'warning';
    return 'error';
};

const growthColor = (value) => {
    return value > 0 ? 'success' : value < 0 ? 'error' : 'grey';
};

const growthIcon = (value) => {
    return value > 0 ? 'mdi-arrow-up' : value < 0 ? 'mdi-arrow-down' : 'mdi-minus';
};
const formatDate = (timestamp) => {
    // Convert nanoseconds to milliseconds
    return new Date(Number(timestamp) / 1_000_000).toLocaleString();
};
// Process data for Doughnut Chart (Top Validators)
const getDoughnutChartData = (stats) => {
    // Sort validators by totalVerifications and get top 5
    const topValidators = [...stats].sort((a, b) => Number(b[1].totalVerifications) - Number(a[1].totalVerifications)).slice(0, 5);
    
    return {
        type: "doughnut",
        data: {
            labels: topValidators.map(([id, stat]) => stat.validatorName[0]),
            datasets: [{
                backgroundColor: ["#41B883", "#E46651", "#00D8FF", "#DD1B16", "#7367F0"],
                data: topValidators.map(([_, stat]) => Number(stat.totalVerifications)),
            }]
        },
        options: {
            plugins: {
                legend: {
                    position: 'bottom'
                },
                title: {
                    display: true,
                    text: 'Top Validators by Verifications'
                }
            }
        }
    };
};

// Process data for Line Chart (Verification Trends)
const getLineChartData = (stats) => {
    // Create map to group data by date
    const dailyData = new Map();
    stats.forEach(([id, stat]) => {
        const date = new Date(Number(stat.lastUpdated) / 1000000).toISOString().split('T')[0];
        if (!dailyData.has(date)) {
            dailyData.set(date, {
                verifications: 0,
                avgScore: 0,
                count: 0
            });
        }
        const data = dailyData.get(date);
        data.verifications += Number(stat.totalVerifications);
        data.avgScore += Number(stat.avgScore);
        data.count++;
    });

    // Convert data to array and sort by date
    const sortedDates = Array.from(dailyData.keys()).sort();
    
    return {
        type: "line",
        plugins: [dataLabels],
        data: {
            labels: sortedDates,
            datasets: [
                {
                    label: "Total Verifications",
                    data: sortedDates.map(date => Number(dailyData.get(date).verifications)),
                    fill: false,
                    borderColor: "#41B883",
                    backgroundColor: "#41B883",
                },
                {
                    label: "Average Score",
                    data: sortedDates.map(date => 
                        Number(dailyData.get(date).avgScore) / Number(dailyData.get(date).count)
                    ),
                    fill: false,
                    borderColor: "#00D8FF",
                    tension: 0.5,
                    backgroundColor: "#00D8FF",
                }
            ]
        },
        options: {
            responsive: true,
            plugins: {
                zoom: {
                    zoom: {
                        wheel: { enabled: true },
                        pinch: { enabled: true },
                        mode: "y",
                    }
                },
                datalabels: {
                    backgroundColor: function(context) {
                        return context.dataset.backgroundColor;
                    },
                    borderRadius: 4,
                    color: "white",
                    font: { weight: "bold" },
                    formatter: Math.round,
                    padding: 6
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    };
};

//Generate data for validatorStats
const generateValidatorStats = (stats) => {
    return stats.map(([id, stat]) => ({
        id: id,
        validatorName: stat.validatorName || id,  // Use ID if name is not available
        totalVerifications: formatNumber(stat.totalVerifications),
        avgScore: formatNumber(stat.avgScore),
        successRate: Number(stat.successRate) * 100, // Convert to percentage
        lastUpdated: formatDate(stat.lastUpdated),
        // Raw values for sorting
        _totalVerifications: Number(stat.totalVerifications),
        _avgScore: stat.avgScore,
        _successRate: Number(stat.successRate) * 100,
        _lastUpdated: stat.lastUpdated,
    }));
};

// Load data
onMounted(async () => {
    loading.value = true;
    try {
        // await analyticsStore.fetchAnalytics(dateRange.value);
        overallStats.value = await getOverallStats();
        validatorStats.value = await getValidatorStats();
        validatorStatsData.value = generateValidatorStats(validatorStats.value);

        // Update charts
        doughnutChart.value = getDoughnutChartData(validatorStats.value);
        lineChart.value = getLineChartData(validatorStats.value);
    } finally {
        loading.value = false;
    }
});
</script>
<template>
    <v-container fluid>
        <!-- Overview Cards -->
        <v-row>
            <v-col cols="12" sm="6" md="3">
                <v-card>
                    <v-card-text>
                        <div class="text-subtitle-1">Total Verifications</div>
                        <div class="text-h4">{{ formatNumber(overallStats?.totalVerifications) }}</div>
                        <div class="text-caption">
                            <v-icon :color="growthColor(verificationGrowth)" small>
                                {{ growthIcon(verificationGrowth) }}
                            </v-icon>
                            {{ formatPercentage(verificationGrowth) }} vs last period
                        </div>
                    </v-card-text>
                </v-card>
            </v-col>

            <v-col cols="12" sm="6" md="3">
                <v-card>
                    <v-card-text>
                        <div class="text-subtitle-1">Active Wallets</div>
                        <div class="text-h4">{{ formatNumber(overallStats?.totalUsers) }}</div>
                        <div class="text-caption">
                            <v-icon :color="growthColor(walletGrowth)" small>
                                {{ growthIcon(walletGrowth) }}
                            </v-icon>
                            {{ formatPercentage(walletGrowth) }} vs last period
                        </div>
                    </v-card-text>
                </v-card>
            </v-col>

            <v-col cols="12" sm="6" md="3">
                <v-card>
                    <v-card-text>
                        <div class="text-subtitle-1">Average Score</div>
                        <div class="text-h4">{{ formatNumber(overallStats?.avgScore) }}</div>
                        <div class="text-caption">
                            <v-icon :color="growthColor(scoreGrowth)" small>
                                {{ growthIcon(scoreGrowth) }}
                            </v-icon>
                            {{ formatPercentage(scoreGrowth) }} vs last period
                        </div>
                    </v-card-text>
                </v-card>
            </v-col>

            <v-col cols="12" sm="6" md="3">
                <v-card>
                    <v-card-text>
                        <div class="text-subtitle-1">Success Rate</div>
                        <div class="text-h4">{{ formatPercentage(Number(overallStats?.successRate) * 100) }}%</div>
                        <div class="text-caption">
                            <v-icon :color="growthColor(successRateGrowth)" small>
                                {{ growthIcon(successRateGrowth) }}
                            </v-icon>
                            {{ formatPercentage(successRateGrowth) }} vs last period
                        </div>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>

        <!-- Charts Section -->
        <v-row class="mt-6">
            <v-col cols="12" md="8">
                <v-card height="100%">
                    <v-card-title>Verification Trends</v-card-title>
                    <v-card-text class="d-flex flex-column fill-height">
                        <vue3-chart-js v-bind="{ ...lineChart }" v-if="lineChart && !loading" />
                        <v-skeleton-loader
                            v-if="loading"
                            class="ma-0 pa-0"
                            max-width="100"
                            max-height="64"
                        ></v-skeleton-loader>

                        <!-- <LineChart :data="verificationTrends" :options="chartOptions" /> -->
                        
                    </v-card-text>
                </v-card>
            </v-col>

            <v-col cols="12" md="4">
                <v-card height="100%">
                    <v-card-title>Top Validators</v-card-title>
                    <v-card-text class="d-flex flex-column fill-height">
                        <vue3-chart-js v-bind="{ ...doughnutChart }" v-if="doughnutChart && !loading" />
                        <v-skeleton-loader
                            v-if="loading"
                            class="ma-0 pa-0"
                            max-width="100"
                            max-height="64"
                        ></v-skeleton-loader>
                        <!-- <DoughnutChart :data="validatorDistribution" :options="doughnutOptions" /> -->
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>

        <!-- Detailed Stats Table -->
        <v-row class="mt-6">
            <v-col cols="12">
                <v-card>
                    <v-card-title>
                        Validator Performance
                        <v-spacer></v-spacer>
                        <!-- <v-text-field v-model="search" append-icon="mdi-magnify" label="Search" single-line
                            hide-details></v-text-field> -->
                    </v-card-title>
                    
                    <v-data-table-virtual 
                        :headers="headers" 
                        :items="validatorStatsData" 
                        :search="search" 
                        :loading="loading"
                    >
                        <!-- Validator Name Column -->
                        <template v-slot:item.validatorName="{ item }">
                            {{ item.validatorName[0] }}
                        </template>

                        <!-- Total Verifications Column -->
                        <template v-slot:item.totalVerifications="{ item }">
                            {{ item.totalVerifications }}
                        </template>

                        <!-- Average Score Column -->
                        <template v-slot:item.avgScore="{ item }">
                            {{ item.avgScore }}
                        </template>

                        <!-- Success Rate Column -->
                        <template v-slot:item.successRate="{ item }">
                            <v-progress-linear 
                                :value="item.successRate" 
                                :color="getSuccessRateColor(item.successRate)"
                                height="25"
                            >
                                <template v-slot:default="{ value }">
                                    <strong>{{ formatPercentage(value) }}%</strong>
                                </template>
                            </v-progress-linear>
                        </template>

                        <!-- Last Updated Column -->
                        <template v-slot:item.lastUpdated="{ item }">
                            {{ item.lastUpdated }}
                        </template>
                    </v-data-table-virtual>
                </v-card>
            </v-col>
        </v-row>

    </v-container>
</template>
