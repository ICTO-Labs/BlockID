<template>
   <v-card flat class="mt-5">
        <v-list lines="two">
        <v-list-subheader>Messages</v-list-subheader>
        <template v-for="n in 5" :key="n">
            <v-list-item>
            <template v-slot:prepend>
                <v-avatar>
                <v-img
                    :src="`https://randomuser.me/api/portraits/women/1${n}.jpg`"
                    :alt="`women1${n}`"
                ></v-img>
                </v-avatar>
            </template>

            <v-list-item-title>Message {{ n }}</v-list-item-title>

            <v-list-item-subtitle>
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nihil repellendus distinctio similique
            </v-list-item-subtitle>
            </v-list-item>

            <v-divider
            v-if="n !== 6"
            :key="`divider-${n}`"
            inset
            ></v-divider>
        </template>
        </v-list>
    </v-card>
</template>

<script>
export default {

}
</script>

<style>

</style>