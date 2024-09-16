<template>
    <v-toolbar class="px-5" color="transparent"> 
        
          <span class="text-h6">{{ $route.name}}</span>
 
          <v-spacer></v-spacer>

          <v-responsive
            class="ml-5"
            max-width="300"
            >
            <v-text-field
              density="compact"
              variant="underlined"
              label="Search"
              append-inner-icon="mdi-magnify"
              placeholder="Input search text"
              single-line
              hide-details="auto"              
            ></v-text-field>            
            
          </v-responsive>
           
    </v-toolbar>
</template>

<script>
export default {
 
}
</script>

<style>

</style>