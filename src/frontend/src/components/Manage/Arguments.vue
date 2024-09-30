<script setup>
    import { ref, watch, computed } from 'vue'
    // const props = defineProps(['providerArgs'])\
    const props = defineProps({
        providerArgs: {
            type: Array,
            required: true,
            default: []
        }
    })
    const emit = defineEmits(['updateProviderArgs'])
    
    const providerArgs = ref([])

    const initializeArgs = () => {
        console.log('props.providerArgs', props.providerArgs)
        providerArgs.value = Array.isArray(props.providerArgs) && props.providerArgs.length > 0 ? props.providerArgs[0] : []
    }

    const addArgument = (paramIndex) => {
        providerArgs.value.push({
            key: '',
            value: '',
            dataType: { Text: null },
        })
    }
    const removeArgument = (argIndex) => {
        providerArgs.value.splice(argIndex, 1)
    }

    watch(providerArgs, (newValue) => {
        emit('updateProviderArgs', newValue);
    }, { deep: false });

    watch(() => props.providerArgs, initializeArgs, { immediate: true, deep: true })

    // watch(() => props.providerArgs, (newValue) => {
    //     providerArgs.value = JSON.parse(JSON.stringify(newValue));
    // }, { deep: true });

    

</script>

<template>
    <v-card>
        <v-card-title>
            <span class="text-h6 mb-4">Arguments <v-icon class="text-h5">mdi-code-braces</v-icon></span>
        </v-card-title>
            <v-card-text>
            <v-list-item v-for="(arg, argIndex) in providerArgs" :key="argIndex">
                <v-row>
                    <v-col class="pa-1">
                        <v-text-field density="comfortable" v-model="arg.key"
                            label="Key" clearable
                            @click:clear="removeArgument(index, argIndex)"
                            @blur="arg.key && arg.key.length > 0 ? arg.key = arg.key.trim() : arg.key = ''"></v-text-field>
                    </v-col>
                    <v-col class="pa-1">
                        <v-text-field density="comfortable" v-model="arg.value"
                            label="Value"
                            @blur="arg.value && arg.value.length > 0 ? arg.value = arg.value.trim() : arg.value = ''"></v-text-field>
                    </v-col>
                    <v-col cols="auto">
                        <v-btn variant="text" @click="removeArgument(argIndex)" color="red"><v-icon>mdi-minus</v-icon></v-btn>
                    </v-col>
                </v-row>
            </v-list-item>
        </v-card-text>
        <v-card-actions>
            <v-btn @click="addArgument" variant="tonal"> <v-icon>mdi-plus</v-icon> New Argument</v-btn>
        </v-card-actions>
    </v-card>
</template>