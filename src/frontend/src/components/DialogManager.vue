<script setup>
    import { computed } from 'vue'
    import { useDialogStore } from '@/store/dialogStore'
    import ConnectWallet from './Wallet/ConnectWallet.vue'
    import ConfirmDialog from './ConfirmDialog.vue'
    import AlertDialog from './AlertDialog.vue'
    import VerifyDialog from '@/components/Validators/VerifyDialog.vue'
    import LoadingDialog from '@/components/LoadingDialog.vue'
    const dialogStore = useDialogStore()
    
    const dialogs = computed(() => dialogStore.dialogs)

    const getDialogComponent = (name) => {
        const components = {
            connectWallet: ConnectWallet,
            AlertDialog: AlertDialog,
            confirm: ConfirmDialog,
            verifyDialog: VerifyDialog,
            loadingDialog: LoadingDialog,
        // Add more dialog components as needed
        }
        return components[name] || null
    }

    const closeDialog = (name) => {
        dialogStore.closeDialog(name)
    }

</script>
<template>
    <div>
        <v-dialog
            v-for="(dialog, name) in dialogs"
            :key="name"
            v-model="dialog.isOpen"
            :max-width="dialog.props.maxWidth || 400"
            :persistent="dialog.props.persistent || false"
            @confirm="dialog.props.onConfirm"
            @cancel="dialog.props.onCancel"
        >
            <component
            :is="getDialogComponent(name)"
            v-bind="dialog.props"
            @close="closeDialog(name)"
            />
        </v-dialog>
    </div>
</template>
    
    