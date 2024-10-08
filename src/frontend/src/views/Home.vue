<script setup>
    import Validators from '@/components/Validators';
    import WalletInfo from '@/components/Validators/WalletInfo';
    import { APPLICATION_ID, FRONTEND_DOMAIN } from '@/config';
    import { getApplication } from '@/services/backendService';
    import { ref, onMounted, watch } from 'vue';
    import { useRoute } from 'vue-router';
    const route = useRoute();
    const applicationId = ref(route.params.applicationId || APPLICATION_ID);
    const application = ref(null);
    const getApplicationInfo = async () => {
        const _application = await getApplication(applicationId.value);
        console.log('application:', _application);
        if (_application && "ok" in _application) {
            application.value = _application.ok;
        }
    }
    onMounted(async () => {
        await getApplicationInfo()
    });

    watch(() => route.path, (newPath, oldPath) => {
        console.log('Route changed from', oldPath, 'to', newPath, route.params.applicationId)
        applicationId.value = newPath == '/' ? APPLICATION_ID : route.params.applicationId
        console.log('applicationId:', applicationId.value)
        getApplicationInfo()
    })
</script>
<template>
    <div>
        <v-alert
            color="gray"
            title="Custom Application: "
            class="mb-4"
            :style="{ backgroundImage: 'url(https://png.pngtree.com/thumb_back/fh260/background/20190220/ourmid/pngtree-upgrade-online-notification-version-replacement-cartoon-image_4317.jpg)', backgroundSize: 'cover' }"
            v-if="applicationId !== APPLICATION_ID"
        >
        <template #title>
            {{application?.name}} Application
        </template>
        <template #text>
            You are viewing the application page named: {{application?.name}}, powered by the BlockID platform. 
            Please note that any project can create custom validators along with the scores they deem appropriate for their project. 
            Make sure you are verifying through the correct URL provided by the project. 
            This application is created by {{application?.owner}} and have url <v-chip color="default" >{{ FRONTEND_DOMAIN }}/{{ applicationId }}</v-chip>
        </template>
    </v-alert>
        <WalletInfo :applicationId="applicationId" />
        <Validators :applicationId="applicationId" />
    </div>
</template>
