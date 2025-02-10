<!-- src/frontend/src/components/WalletSearch.vue -->
<template>
    <v-row justify="center" class="mb-6">
        <v-col cols="12" md="10">
            <v-form @submit.prevent="handleSearch">
                <v-text-field
                    v-model="searchQuery"
                    :label="label || 'Search Wallet by Principal ID'"
                    :loading="loading"
                    clearable
                    hide-details="auto"
                    :placeholder="placeholder || 'Enter Principal ID'"
                    append-inner-icon="mdi-magnify"
                    @click:append-inner="handleSearch"
                    variant="outlined"
                    density="comfortable"
                >
                    <template v-slot:prepend>
                        <v-tooltip text="Example: aaaaa-aa">
                            <template v-slot:activator="{ props }">
                                <v-icon v-bind="props" color="primary">
                                    mdi-help-circle
                                </v-icon>
                            </template>
                        </v-tooltip>
                    </template>
                </v-text-field>
            </v-form>
        </v-col>
    </v-row>
</template>

<script setup>
import { ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import { Principal } from '@dfinity/principal';
import Notify from '@/plugins/notify';

const props = defineProps({
    label: String,
    placeholder: String,
    initialValue: String
});

const router = useRouter();
const searchQuery = ref(props.initialValue || '');
const loading = ref(false);

watch(() => props.initialValue, (newValue) => {
    if (newValue) {
        searchQuery.value = newValue;
    }
});

async function handleSearch() {
    if (!searchQuery.value) return;
    
    loading.value = true;
    try {
        // Validate principal
        Principal.fromText(searchQuery.value);
        // Navigate to wallet explorer
        router.push(`/wallet/${searchQuery.value}`);
    } catch (error) {
        Notify.error('Invalid principal');
    } finally {
        loading.value = false;
    }
}
</script>