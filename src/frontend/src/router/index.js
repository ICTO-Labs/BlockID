// Composables
import { createRouter, createWebHistory } from 'vue-router';

const routes = [
    {
        path: '/home',
        name: 'Main',
        component: () => import('@/layouts/template/Main'),
        children: [
            {
                path: '/',
                name: 'Home',
                component: () => import('@/views/Home')
            },
            {
                path: '/analytics',
                name: 'Analytics',
                component: () => import('@/views/Analytics')
            },
            {
                path: '/app/:applicationId?',
                name: 'Verify',
                component: () => import('@/views/Verify')
            },
            {
                path: '/applications',
                name: 'Applications',
                component: () => import('@/views/Applications')
            },
            {
                path: '/providers',
                name: 'Providers',
                component: () => import('@/views/Manage')
            },
            {
                path: '/marketplace',
                name: 'Marketplace',
                component: () => import('@/views/marketplace/Index'),
                children: [
                    {
                        path: '',
                        name: 'List Providers',
                        component: () => import('@/views/marketplace/List')
                    },
                    {
                        path: 'provider/:providerId',
                        name: 'Provider',
                        component: () => import('@/views/marketplace/Provider')
                    },
                    {
                        path: 'submit',
                        name: 'Submit',
                        component: () => import('@/views/marketplace/Submit')
                    },
                    {
                        path: 'manage',
                        name: 'Manage',
                        component: () => import('@/views/marketplace/Manage')
                    }
                ]
            },
            {
                path: '/docs',
                name: 'Docs',
                component: () => import('@/views/Docs')
            },
            {
                path: '/wallet/:walletId?',
                name: 'Wallet',
                component: () => import('@/views/Wallet')
            },
            {
                path: '/:pathMatch(.*)*',
                name: 'Error404',
                component: () => import('@/views/Error404')
            }
        ]
    }
];

const router = createRouter({
    history: createWebHistory(process.env.BASE_URL),
    routes
});

export default router;
