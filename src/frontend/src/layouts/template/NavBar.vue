<template>
    <v-navigation-drawer permanent>
       <v-sheet
        color="grey-lighten-4"
        class="pa-4"
      >
        <v-avatar
          class="mb-4"
          color="grey-darken-1"
          size="64"
        ></v-avatar>
    

        <div>{{ this.$store.state.email }}</div>
      </v-sheet>

      <v-divider></v-divider>

      <v-list-item
          v-for="[icon, text] in links"
          :key="icon"
          link
        >
          <template v-slot:prepend>
            <v-icon>{{ icon }}</v-icon>
          </template>

          <v-list-item-title>{{ text }}</v-list-item-title>
        </v-list-item>

    </v-navigation-drawer>
</template>

<script>
export default {
  data () {
      return {
       links: [
            ['mdi-inbox-arrow-down', 'Inbox'],
            ['mdi-send', 'Send'],
            ['mdi-delete', 'Trash'],
            ['mdi-alert-octagon', 'Spam'],
        ],
      }
  }
}
</script>

<style>

</style>