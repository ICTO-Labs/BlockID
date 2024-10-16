<script setup>
    import { ref, computed } from 'vue';

    const props = defineProps({
        params: {
            type: Array,
            required: true
        }
    });

    const emit = defineEmits(['submit', 'close']);

    const dialog = ref(true);
    const valid = ref(false);
    const paramValues = ref({});

    const form = ref(null);

    const close = () => {
        dialog.value = false;
        emit('close');
    };

    const submit = () => {
        if (form.value.validate()) {
            emit('submit', paramValues.value);
            close();
        }
    };
</script>
<template>
    <v-card>
        <v-card-text>
            <v-form ref="form" v-model="valid">
                    <v-row v-for="param in params[0]" :key="param.key">
                        <v-col cols="12">
                            <v-text-field v-model="paramValues[param.key]" :label="param.key" :placeholder="`Enter your ${param.key}`"
                                :rules="[(v) => !!v || 'This field is required']" required></v-text-field>
                        </v-col>
                    </v-row>
            </v-form>
        </v-card-text>
        <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn color="blue darken-1" text @click="close">Cancel</v-btn>
            <v-btn color="blue darken-1" text @click="submit" :disabled="!valid">Submit</v-btn>
        </v-card-actions>
    </v-card>
</template>