<template>
    
    <v-alert
        color="warning"
        icon="mdi-alert-circle"
        variant="flat"
        >
        <v-alert-title>{{ $route.name}}</v-alert-title>
        <v-alert-content>
            <v-chip>{{ $route.path}}</v-chip> 
            <v-chip variant="text">
                This page you are looking was moved, removed, renamed, or might never exist!
            </v-chip></v-alert-content>
    </v-alert>
    <v-btn to="/" block class="mt-3">
        <template v-slot:prepend>
            <v-icon>mdi-home</v-icon>
        </template>
        Home</v-btn>
</template>