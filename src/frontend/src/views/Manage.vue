<script setup>
    import { ref, onMounted, computed } from 'vue';
    import { getValidators, getGroups, getCriterias, createValidator, createGroup, createCriteria } from '@/services/backendService';

    const _validators = [
	{
		id: "decide-ai",
		name: "DecideAI",
		description: "Got verified with Unique identity verification on DecidedAI",
		logo: "https://pbs.twimg.com/profile_images/1787516653145632768/vlRMkJVq_400x400.jpg",
		totalScore: 20,
		groups: [
			{
				"id":"unique-person",
				"name":"Proof Of Uniqueness",
				"description":"Provide the Unique Person verifiable credential",
				"criterias": [
					{
					"id":"unique-person",
					"autoVerify":false,
					"name":"Proof of Unique Person",
					"description":"Unique Person verifiable credential",
					"score":"20",
					"expirationTime":"1758203990000000000",
					"providerId":"decide-ai",
					"params":{"minValue":"1","additionalParams":[],"comparisonType":{"Equal":null},"maxValue":[],"canisterId":[]}
					}
				]
			}
		]
        }
    ];
    const validators = ref([]);
    const allGroups = ref([]);
    const criterias = ref([]);

    const newValidator = ref({
        id: '',
        name: '',
        description: '',
        logo: '',
        groups: [],
        verifyMethod: {
            Module: null
        },
    });

    const newGroup = ref({
        groupId: '',
        name: '',
        groupDescription: '',
        validatorId: ''
    });

    const newCriteria = ref({
        groupId: '',
        criteriaId: '',
        name: '',
        description: '',
        score: 0,
        expirationTime: new Date().getTime() * 1000000,//Nanosecond
        providerId: '',
        params: {
            minValue: 1,
            additionalParams: [],
            comparisonType: {
                Equal: null,
            },
            maxValue: [],
            canisterId: [],
        },
    });

    const fetchData = async () => {
        // validators.value = await getValidators();
        allGroups.value = await getGroups();
        criterias.value = await getCriterias();
    };

    onMounted(fetchData);

    const addValidator = async () => {
        // Implement create validator logic
        console.log('Creating validator:', newValidator.value);
        const response = await createValidator(newValidator.value);
        console.log('Validator created:', response);
        // After creating, refetch data
        await fetchData();
    };

    const addGroup = async () => {
        // Implement create group logic
        console.log('Creating group:', newGroup.value);
        const response = await createGroup(newGroup.value);
        console.log('Group created:', response);
        // After creating, refetch data
        await fetchData();
    };

    const addCriteria = async () => {
        // Implement create criteria logic
        console.log('Creating criteria:', newCriteria.value);
        const response = await createCriteria(newCriteria.value);
        console.log('Criteria created:', response);
        // After creating, refetch data
        await fetchData();
    };
</script>
<template>
    <div>
        <h4>Validators</h4>
        <v-expansion-panels>
            <v-expansion-panel v-for="validator in _validators" :key="validator.id">
                <v-expansion-panel-title>
                    <v-row no-gutters>
                        <v-col cols="4"><v-img :src="validator.logo" max-width="32"></v-img> {{ validator.name }}</v-col>
                        <v-col cols="8" class="text-grey">
                            {{ validator.description }}
                        </v-col>
                    </v-row>
                </v-expansion-panel-title>
                <v-expansion-panel-text>
                    <p>Total score: {{ validator.totalScore }}</p>

                    <!-- Groups -->
                    <v-expansion-panels>
                        <v-expansion-panel v-for="group in validator.groups" :key="group.id">
                            <v-expansion-panel-title>
                                {{ group.name }}
                            </v-expansion-panel-title>
                            <v-expansion-panel-text>
                                <p>{{ group.description }}</p>

                                <!-- Criterials -->
                                <v-list>
                                    <v-list-item v-for="criteria in group.criterias" :key="criteria.id">
                                        <v-list-item-title>{{ criteria.name }}</v-list-item-title>
                                        <v-list-item-subtitle>Score: {{ criteria.score }}</v-list-item-subtitle>
                                    </v-list-item>
                                </v-list>
                            </v-expansion-panel-text>
                        </v-expansion-panel>
                    </v-expansion-panels>
                </v-expansion-panel-text>
            </v-expansion-panel>
        </v-expansion-panels>

        <v-row>
            <v-col cols="12" md="4">
                <!-- Create Validator -->
                <v-card class="mt-4">
                    <v-card-title>Create Validator</v-card-title>
                        <v-card-text>
                            <v-form @submit.prevent="addValidator">
                                <v-text-field v-model="newValidator.id" label="Validator ID"></v-text-field>
                                <v-text-field v-model="newValidator.name" label="Validator Name"></v-text-field>
                                <v-text-field v-model="newValidator.description" label="Description"></v-text-field>
                                <v-text-field v-model="newValidator.logo" label="Logo URL"></v-text-field>
                                <v-btn type="submit" color="primary">Create</v-btn>
                        </v-form>
                    </v-card-text>
                </v-card>
            </v-col>
            <v-col cols="12" md="4">
                <!-- Create Group -->
                <v-card class="mt-4">
                    <v-card-title>Create Group</v-card-title>
                    <v-card-text>
                        <v-form @submit.prevent="addGroup">
                            <v-select v-model="newGroup.validatorId" :items="validators" item-title="name" item-value="id"
                                label="Select Validator"></v-select>
                            <v-text-field v-model="newGroup.name" label="Group Name"></v-text-field>
                            <v-text-field v-model="newGroup.description" label="Group Description"></v-text-field>
                            <v-btn type="submit" color="primary">Create Group</v-btn>
                        </v-form>
                    </v-card-text>
                </v-card>
            </v-col>
            <v-col cols="12" md="4">
                <!-- Create Criteria -->
                <v-card class="mt-4">
                    <v-card-title>Create Criteria</v-card-title>
                    <v-card-text>
                        <v-form @submit.prevent="addCriteria">
                            <v-select v-model="newCriteria.groupId" :items="allGroups" item-title="name" item-value="id"
                                label="Select Group"></v-select>
                            <v-text-field v-model="newCriteria.criteriaId" label="Criteria ID"></v-text-field>
                            <v-text-field v-model="newCriteria.name" label="Criteria Name"></v-text-field>
                            <v-text-field v-model="newCriteria.description" label="Description"></v-text-field>
                            <v-text-field v-model="newCriteria.score" label="Score" type="number"></v-text-field>
                            <v-text-field v-model="newCriteria.expirationTime" label="Expiration Time"></v-text-field>
                            <v-text-field v-model="newCriteria.providerId" label="Provider ID"></v-text-field>
                            <v-text-field v-model="newCriteria.params.minValue" label="Min Value"></v-text-field>
                            <v-btn type="submit" color="primary">Create Criteria</v-btn>
                        </v-form>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>

    </div>
</template>