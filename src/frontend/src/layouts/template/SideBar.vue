<script setup>
    import { ref, watch } from 'vue';
    import { useProjectStore } from '@/store';
    import { storeToRefs } from 'pinia';

    const projectStore = useProjectStore();
    const { isDrawerOpen } = storeToRefs(projectStore);

    const drawer = ref(true);
    const rail = ref(true);

    watch(isDrawerOpen, (newValue)=>{
        rail.value = !newValue
    })
    const menus = ref([
        { title: 'Verify', value: 1, prependIcon: 'mdi-star', link: '/'},
        { title: 'Validators', value: 2, prependIcon: 'mdi-account-multiple', link: '/demo'},
        { title: 'Gallery', value: 4, prependIcon: 'mdi-image-multiple', link: '/gallery'},
        { title: 'Usage', value: 6, prependIcon: 'mdi-cloud-outline', link: '/usage'},
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
        <v-avatar color="grey-darken-3" size="42" class="d-block text-center mx-auto mb-9"><span class="text-h4">B</span></v-avatar>
        

        <v-divider></v-divider>
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
                </v-list-item>
            </v-list>
        </v-navigation-drawer>
    </div>
</template>