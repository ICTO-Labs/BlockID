<script setup>
import { ref, watch } from 'vue';
import { useProjectStore } from '@/store';
import { storeToRefs } from 'pinia';

const projectStore = useProjectStore();
const { isDrawerOpen } = storeToRefs(projectStore);

const drawer = ref(true);
const rail = ref(true);

watch(isDrawerOpen, (newValue) => {
    rail.value = !newValue;
});
const menus = ref([
    { title: 'Home', value: 0, prependIcon: 'mdi-home', link: '/' },
    { title: 'Verify', value: 1, prependIcon: 'mdi-check-decagram', link: '/app' },
    { title: 'Analytics', value: 2, prependIcon: 'mdi-chart-box', link: '/analytics' },
    {
        title: 'Applications',
        value: 3,
        prependIcon: 'mdi-apps',
        link: '/applications'
    },
    {
        title: 'Docs',
        value: 4,
        prependIcon: 'mdi-file-document',
        link: '/docs'
    },
    {
        title: 'Providers',
        value: 5,
        prependIcon: 'mdi-cog',
        link: '/providers'
    }
]);
</script>
<template>
    <div>
        <v-navigation-drawer
            class="pt-4"
            color="primary"
            model-value
            :rail="drawer"
            v-model="isDrawerOpen"
        >
            <v-list density="compact" nav>
                <v-list-item
                    v-for="item in menus"
                    :key="item.title"
                    :value="item.value"
                    :title="item.title"
                    :to="item.link"
                >
                    <template v-slot:prepend>
                        <v-icon :icon="item.prependIcon"></v-icon>
                    </template>
                    <v-tooltip activator="parent" location="right">
                        {{ item.title }}
                    </v-tooltip>
                </v-list-item>
            </v-list>
        </v-navigation-drawer>
    </div>
</template>
