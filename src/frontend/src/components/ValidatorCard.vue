<script setup>
    import Dialog from '@/plugins/dialog';
    import VcFlow from '@/components/icons/VcFlow.vue';
    const props = defineProps({
        validator: {
            type: Object,
            required: true
        }
    });
    const showVerifyDialog = async (validatorId) => {
        await Dialog.showVerify(validatorId);
    };
</script>

<template>
    <v-card
        class="overflow-hidden mx-auto "
        hover
        height="100%"
    >
        <template v-slot:prepend>
            <v-avatar size="48">
                <v-img
                :alt="validator.name"
                :src="validator.logo"
                
                ></v-img>
            </v-avatar>
            
        </template>
        <template v-slot:title>
            {{ validator.name }} 
            <v-chip label size="small" color="warning" prepend-icon="mdi-account-cancel" variant="outlined">
                <span class="text-primary1">Not verified</span>
            </v-chip>
        </template>
        <template v-slot:subtitle>
            <v-card-text class="py-1 px-0">
                <v-chip class="ma-0 fw-bold" size="small" prepend-icon="mdi-star" color="warning">
                {{ validator.totalScore || 0 }} Points
                </v-chip>
                <VcFlow :verifyMethod="validator.verifyMethod" />
            </v-card-text>
        </template>
        
        <v-card-text class="pt-4">
            {{ validator.description }}
        </v-card-text>
        <template v-slot:actions>
            <v-btn
                @click="showVerifyDialog(validator.id)"
                append-icon="mdi-chevron-right"
                color="primary"
                text="Verify"
                block
                variant="flat"
            ></v-btn>
        </template>
    </v-card>
</template>
<style scoped>
.v-card {
    display: flex;
    flex-direction: column;
}

.v-card__actions {
    margin-top: auto;
}
</style>