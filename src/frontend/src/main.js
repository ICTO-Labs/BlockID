import { createPinia } from 'pinia';
import { createApp } from 'vue';
import router from './router';
import * as filter from './filter';
// Vuetify
import 'vuetify/styles'
import vuetify from './plugins/vuetify';

import { config} from './config';
import App from './App.vue';

const app = createApp(App);
app.config.globalProperties.$config = config;
app.config.globalProperties.$filters = filter;

app.use(vuetify);
app.use(router);
app.use(createPinia());
app.mount('#app');
