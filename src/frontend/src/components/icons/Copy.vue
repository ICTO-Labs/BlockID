<script setup>
    import { ref } from 'vue';
    import {copyToClipboard} from "@/plugins/common";
    const props = defineProps(['text', 'item']);
    const isCopied = ref(false);
    const _copyToClipboard = () => {
        copyToClipboard(props.text, props.item);
        isCopied.value = true;
        setTimeout(() => {
            isCopied.value = false;
        }, 3000);
    }
</script>
<template>
    <button href="javascript:void(0)" @click.stop="_copyToClipboard()" title="Copy">
        <v-icon v-if="!isCopied" class="text-primary">mdi-content-copy</v-icon>
        <v-icon v-if="isCopied" class="text-success">mdi-check</v-icon>
        <v-tooltip activator="parent" location="top" v-if="isCopied">
            Copied!
        </v-tooltip>
    </button>
</template>
<style>
    .copy{
        cursor: pointer;
        font-size: 12px;
    }
    .copy:hover{
        color: #009ef7;
    }
</style>