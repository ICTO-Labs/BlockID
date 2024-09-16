import { useDialogStore } from '@/store/dialogStore'

class AuthService {
    constructor() {
        this.dialogStore = useDialogStore()
    }

    async connect(wallet) {
        try {
        // Simulate API call
        await new Promise(resolve => setTimeout(resolve, 1000))
        
        if (username === 'admin' && password === 'password') {
            // Login successful
            this.dialogStore.closeDialog('connectWallet')
            // You can also open a success dialog here if needed
            this.dialogStore.openDialog('alert', {
                title: 'Success',
                message: 'Login successful!',
                color: 'success'
            })
            return true
        } else {
            throw new Error('Invalid credentials')
        }
        } catch (error) {
            // Open error dialog
            this.dialogStore.openDialog('alert', {
                title: 'Error',
                message: error.message,
                color: 'error'
            })
            return false
        }
    }

    logout() {
        // Logout logic here
        this.dialogStore.openDialog('alert', {
            title: 'Logged Out',
            message: 'You have been successfully logged out.',
            color: 'info'
        })
    }
}

const authService = new AuthService()
export default authService
