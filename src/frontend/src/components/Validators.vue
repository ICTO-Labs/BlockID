<script setup>
    import ValidatorCard from '@/components/ValidatorCard'
    import { shallowRef } from 'vue';
    const validators = shallowRef([
        { id: 'known-neuron', title: 'Known Neuron', description: 'Connect and verify your neurons.', score: 100, logo: 'https://nns.ic0.app/_app/immutable/assets/icp-rounded.0be14f6b.svg' },
        { id: 'decide-ai', title: 'Decide AI', description: 'Got verified with Unique identity verification on DecidedAI.', score: 99, logo: 'https://pbs.twimg.com/profile_images/1787516653145632768/vlRMkJVq_400x400.jpg' },
        { id: 'openchat', title: 'OpenChat', description: 'Connect OpenChat wallet to verify your account status.', score: 98, logo: 'https://dgegb-daaaa-aaaar-arlhq-cai.raw.icp0.io/avatar/319398709384407980892342373791723159552' },
        { id: 'btcflower', title: 'BTCFlower', description: 'Verify NFT ownership of BTC Flower collection', score: 97, logo: 'https://hdem4-ryaaa-aaaam-qa4xa-cai.raw.ic0.app/?index=615' },
        { id: 'btcflower', title: 'BTCFlower', description: 'Verify NFT ownership of BTC Flower collection', score: 97, logo: 'https://hdem4-ryaaa-aaaam-qa4xa-cai.raw.ic0.app/?index=615' },
        { id: 'btcflower', title: 'BTCFlower', description: 'Verify NFT ownership of BTC Flower collection', score: 97, logo: 'https://hdem4-ryaaa-aaaam-qa4xa-cai.raw.ic0.app/?index=615' },
        { id: 'btcflower', title: 'BTCFlower', description: 'Verify NFT ownership of BTC Flower collection', score: 97, logo: 'https://hdem4-ryaaa-aaaam-qa4xa-cai.raw.ic0.app/?index=615' },
    ]);

</script>
<template>
    <v-item-group selected-class="bg-primary">
        <v-row>  
            <v-col
            v-for="validator in validators"
            :key="validator.title"
            cols="3"
            >
            <ValidatorCard :validator="validator" :to="`/validator/${validator.id}`"/>
            <!-- <v-item v-slot="{ isSelected, selectedClass, toggle }">
                <v-card
                :class="['align-center', selectedClass]"
                dark
                :title="`Photo ${n}`"
                :subtitle="isSelected? `Content ${n} is selected.` : `Subtitle for Content ${n}`"
                @click="toggle"
                >

                <v-img src="https://picsum.photos/512/128?random" height="128" cover></v-img>

                <v-card-text>
                During my last trip to South America, I spent 2 weeks traveling through Patagonia in Chile.
                </v-card-text>

                </v-card>
            </v-item> -->
            </v-col>
        </v-row>
    </v-item-group>
</template>