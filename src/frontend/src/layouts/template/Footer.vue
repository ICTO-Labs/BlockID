<script setup>
	import { sha } from '~build/git'
	import time from '~build/time'
	console.log(`Build ${sha} at ${time}`)

const links = [
    { url: 'https://github.com/ICTO-Labs/BlockID', icon: 'mdi-github' },
    { url: 'https://twitter.com/icto_app', icon: 'mdi-twitter' },
    { url: 'https://blockid.cc', icon: 'mdi-link' }
];
</script>
<template>
    <v-footer color="copyright" app>
        <v-container fluid>
            <v-row no-gutters align="center" justify="space-between">
                <v-col cols="12" sm="auto" class="text-center text-sm-left">
                    <div class="text-body-2">
                        {{ new Date().getFullYear() }} — <strong>BlockID</strong> | Entirely
                        on-chain with
                        <a href="https://internetcomputer.org" target="_blank" class="text-decoration-none">Internet Computer</a>  
                    </div>
                </v-col>
                <v-col cols="12" sm="auto" class="text-center text-sm-right mt-4 mt-sm-0">
                    <v-chip size="small" color="grey-darken-3" class="text-default">
                            <a target="_blank" :href="`https://github.com/ICTO-Labs/BlockID/commit/${sha}`" class="text-decoration-none text-gray-lighten-1" title="Github commit"><v-icon>mdi-code-tags</v-icon> {{ sha.substring(0,7) }}</a>
                        <v-tooltip activator="parent" location="top">
                            <span>Github commit</span>
                        </v-tooltip>
                    </v-chip>
                    <v-btn
                        v-for="link in links"
                        :key="link.icon"
                        :icon="link.icon"
                        variant="plain"
                        size="small"
                        :href="link.url"
                        target="_blank"
                        class="mx-1"
                    ></v-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-footer>
</template>