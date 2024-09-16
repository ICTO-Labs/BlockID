<script setup>
    import { computed } from 'vue'
    import { useDialogStore } from '@/store/dialogStore'
    // import LoginDialog from './LoginDialog.vue'
    // import FormDialog from './FormDialog.vue'
    import WalletConnect from './Wallet/ConnectWallet.vue'
    import Alert from './Alert.vue'
    const dialogStore = useDialogStore()
    
    const dialogs = computed(() => dialogStore.dialogs)

    const getDialogComponent = (name) => {
        const components = {
            walletConnect: WalletConnect,
            // login: LoginDialog,
            // form: FormDialog,
            alert: Alert,
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
            :max-width="dialog.props.maxWidth || 500"
        >
            <component
            :is="getDialogComponent(name)"
            v-bind="dialog.props"
            @close="closeDialog(name)"
            />
        </v-dialog>
    </div>
</template>
    
    