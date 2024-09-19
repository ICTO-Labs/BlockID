<script setup>
    const props = defineProps({
        verifyMethod: {
            type: Object,
            required: true
        }
    })
</script>
<template>
    <v-chip class="ms-2 ma-0" color="success" size="small" variant="outlined" prepend-icon="mdi-check-decagram" v-if="'VcFlow' in verifyMethod">
        VCFlow
    </v-chip>
</template>