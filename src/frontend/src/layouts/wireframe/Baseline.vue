<template>
 <v-app :theme="theme"> 
    <Sidebar />
    <Header /> 
     <v-main>        
        <Toolbar />
          <v-container fluid>    
             <Contents />
          </v-container>
        <Footer />
      </v-main>        
  </v-app>
</template>

<script setup>
import Header from './AppBar.vue'
import Sidebar from './NavBar.vue'
import Toolbar from './Tools.vue'
import Contents from '@/components/List.vue'
import Footer from './Footer.vue'
</script>
