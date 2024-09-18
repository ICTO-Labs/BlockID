<script setup>
    import Dialog from '@/plugins/dialog';

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
        subtitle="get verified"
        :title="validator.title"
        class="overflow-hidden mx-auto "
        hover
        height="100%"
    >
        <template v-slot:prepend>
            <v-avatar size="48">
                <v-img
                :alt="validator.title"
                :src="validator.logo"
                
                ></v-img>
            </v-avatar>
            
        </template>
        <template v-slot:title>
            {{ validator.title }} 
            <v-chip label size="small" color="warning" prepend-icon="mdi-account-cancel" variant="outlined">
                <span class="text-primary1">Not verified</span>
            </v-chip>
        </template>
        <template v-slot:subtitle>
            <v-chip-group>
                <v-chip class="ma-0"  size="small" prepend-icon="mdi-star" color="warning">
                {{ validator.score || 0 }} Points
                </v-chip>
            </v-chip-group>
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