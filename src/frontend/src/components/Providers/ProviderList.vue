<script setup>
import { ref, onMounted } from 'vue';
import { getProviders, removeProvider } from '@/services/backendService';
import { toSimpleArray } from '@/plugins/common';
import Dialog from '@/plugins/dialog';
import Notify from '@/plugins/notify';

const providers = ref([]);
const loading = ref(false);

const fetchProviders = async () => {
    providers.value = toSimpleArray(await getProviders());
};

const deleteProvider = async (id) => {
    const confirm = await Dialog.confirm({
        title: 'Warning',
        message: 'Are you sure you want to delete this provider: ' + id + '?',
        color: 'warning',
        icon: 'mdi-alert'
    });
    if (confirm) {
        loading.value = true;
        Dialog.showLoading('Deleting provider...');
        let _rs = await removeProvider(id);
        console.log('_rs', _rs);
        if(_rs && "ok" in _rs){
            fetchProviders();
            Notify.success('Provider deleted successfully');
        } else {
            Notify.error(_rs.err);
        }
        loading.value = false;
        Dialog.closeLoading();
    } else {
        Dialog.close('confirm');
    }
};

const showEditDialog = (provider) => {
    Dialog.custom('providerDialog', {
        provider: Object.assign({}, provider),
        method: 'edit',
        maxWidth: 1000,
        title: 'Edit provider: ' + provider.name,
        onSave: () => {
            fetchProviders();
        }
    });
};

const showAddDialog = () => {
    Dialog.custom('providerDialog', {
        method: 'add',
        maxWidth: 1000,
        title: 'Create provider',
        onSave: () => {
            fetchProviders();
        }
    });
};

onMounted(fetchProviders);
</script>

<template>
    <v-data-table
        :headers="[
            { title: 'ID', key: 'id' },
            { title: 'Name', key: 'name' },
            { title: 'Description', key: 'description' },
            { title: 'Module Type', key: 'moduleType' },
            { title: 'Actions', key: 'actions', sortable: false }
        ]"
        :items="providers"
        class="elevation-1"
    >
        <template v-slot:item.moduleType="{ item }">
            {{ Object.keys(item.moduleType)[0] }} <v-chip size="small" color="primary" v-if="item.moduleType[Object.keys(item.moduleType)[0]]">{{ item.moduleType[Object.keys(item.moduleType)[0]] }}</v-chip>
        </template>
        <template v-slot:item.actions="{ item }">
            <v-btn
                size="small"
                class="mr-2"
                @click="showEditDialog(item)"
            >
                <v-icon>mdi-pencil</v-icon>
            </v-btn>
            <v-btn
                size="small"
                color="error"
                @click="deleteProvider(item.id)"
            >
                <v-icon>mdi-delete</v-icon>
            </v-btn>
        </template>
    </v-data-table>
    <v-divider class="my-4"></v-divider>
    <v-btn @click="showAddDialog">
        <v-icon>mdi-plus</v-icon> Create provider
    </v-btn>
</template>