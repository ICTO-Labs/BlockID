// Composables
import { createRouter, createWebHistory } from 'vue-router';

const routes = [
    {
        path: '/home',
        name: 'Main',
        component: () => import('@/layouts/template/Main'),
        children: [
            {
                path: '/:applicationId?',
                name: 'Home',
                component: () => import('@/views/Home')
            },
            {
                path: '/demo',
                name: 'Demo',
                component: () => import('@/views/Demo')
            },
            {
                path: '/manage',
                name: 'Manage',
                component: () => import('@/views/Manage')
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
