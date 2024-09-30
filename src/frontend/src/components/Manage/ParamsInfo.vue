<script setup>
import { ref, onMounted } from 'vue'
import { getProviderParams } from '@/plugins/vcflow'
const props = defineProps({
    providerParams: {
        type: Array,
        required: true,
        default: []
    },
    title: {
        type: String,
        required: true,
    },
    providerArgs: {
        type: Array,
        required: true,
        default: []
    }
})
const params = ref(getProviderParams(props.providerParams))
const args = ref(Array.isArray(props.providerArgs) && props.providerArgs.length > 0 ? props.providerArgs[0] : [])
</script>
<template>
    <v-card>
        <v-card-title>
            <span class="text-h6">{{ title }}</span>
        </v-card-title>
        <v-card-text class="text-body-2 pt-0">
            <v-table>
                <thead>
                    <tr>
                        <th>Key</th>
                        <th>Value</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Loop from object -->
                    <tr>
                        <td colspan="2" class="text-primary text-h6">Params <v-chip label size="small" class="font-weight-bold">{{ Object.keys(params).length }}</v-chip></td>
                    </tr>
                    <tr v-for="(value, key) in params" :key="key">
                        <td>{{ key }}</td>
                        <td>
                            {{ value }}
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" class="text-primary text-h6">Arguments <v-chip label size="small" class="font-weight-bold">{{ args.length }}</v-chip></td>
                    </tr>
                    <tr v-for="(item, k) in args" :key="k">
                        <td>{{ item.key }}</td>
                        <td>{{ item.value[0] }}</td>
                    </tr>
                </tbody>
            </v-table>
        </v-card-text>
    </v-card>
</template>