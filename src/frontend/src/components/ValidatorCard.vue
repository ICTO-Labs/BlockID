<script setup>
const props = defineProps({
    validator: {
        type: Object,
        required: true
    }
});
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
        <template v-slot:append>
            <v-badge
            color="yellow"
            content="12"
            inline></v-badge>
        </template>
        <v-card-text class="pt-4">
            {{ validator.description }}
        </v-card-text>
        <template v-slot:actions>
            <v-btn
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