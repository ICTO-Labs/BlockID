<template>
    <v-footer color="copyright" app inset height="45">
        <h5 class="font-weight-light">
            {{ new Date().getFullYear() }} — <strong>BlockID</strong> | Entirely
            on-chain with
            <a href="https://internetcomputer.org" target="_blank"
                >Internet Computer</a
            >
        </h5>
        <v-spacer></v-spacer>

        <v-btn
            v-for="link in links"
            :key="link.icon"
            class="mx-2"
            :icon="link.icon"
            variant="plain"
            size="small"
        ></v-btn>
    </v-footer>
</template>

<script setup>
const links = [
    { url: 'https://github.com/blockid-cc', icon: 'mdi-github' },
    { url: 'https://twitter.com/blockid_cc', icon: 'mdi-twitter' },
    { url: 'https://blockid.cc', icon: 'mdi-link' }
];
</script>
