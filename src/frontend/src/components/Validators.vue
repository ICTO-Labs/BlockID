<script setup>
    import ValidatorCard from '@/components/ValidatorCard'
    import { ref, onMounted, computed } from 'vue';
    import { getValidators } from '@/services/backendService';
    const validators = ref([]);
    onMounted(async () => {
        validators.value = await getValidators();
        console.log(validators.value);
    });

</script>
<template>
    <v-item-group selected-class="bg-primary">
        <v-row>  
            <v-col
            v-for="validator in validators"
            :key="validator[0]"
            cols="12"
            sm="6"
            md="4"
            lg="3"
            >
            <ValidatorCard :validator="validator[1]" />
            </v-col>
        </v-row>
    </v-item-group>
</template>