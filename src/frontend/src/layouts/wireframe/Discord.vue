<template>
  <v-app :theme="theme"> 
      <Header />
      <Sidebar />
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
import Sidebar from './SideBar.vue'
import Toolbar from './Tools.vue'
import Contents from './Content.vue'
import Footer from './Footer.vue'
</script>
