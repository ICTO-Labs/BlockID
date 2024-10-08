<script setup>
    import ValidatorCard from '@/components/ValidatorCard';
    import { ref, onMounted, computed, watchEffect } from 'vue';
    import { getValidators } from '@/services/backendService';
    const validators = ref([]);
    const props = defineProps({
        applicationId: {
            type: String,
            required: true
        }
    });
    const applicationId = ref(props.applicationId);
    const _getValidators = async () => {
        const _validators = await getValidators(applicationId.value);
        if(_validators && _validators.length > 0){
            validators.value = _validators
        }else{
            validators.value = []
        }
    }
    onMounted(async () => {
        _getValidators()
    });
    watchEffect(() => {
        applicationId.value = props.applicationId
        _getValidators()
    })
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
                <ValidatorCard :validator="validator[1]" :applicationId="applicationId" />
            </v-col>
        </v-row>
    </v-item-group>
</template>
