
<script setup>
    import { ref, computed } from 'vue'
    import { getApplications, updateApplication, removeApplication, getValidators, updateValidator, removeValidator, updateCriteria, removeCriteria } from '@/services/backendService'
    import VcFlow from '@/components/icons/VcFlow.vue'
    import { toSimpleArray } from '@/plugins/common'
    import { getProviderParams } from '@/plugins/vcflow'
    const applications = ref([])
    const validators = ref([])
    const dialogCriteriaParams = ref(false)
    const dialog = ref(false)
    const dialogType = ref('')
    const editedIndex = ref(-1)
    const editedItem = ref({
        id: '',
        name: '',
        description: '',
        validators: []
    })
    const params = ref([])
    const paramTemplate = [
        {
            key: "issuerOrigin",
            value: [],
            dataType: { Text: null },
            arguments: []
        },
        {
            key: "issuerCanisterId",
            value: [],
            dataType: { Text: null },
            arguments: []
        },
        {
            key: "credentialType",
            value: [],
            dataType: { Text: null },
            arguments: []
        },
        {
            key: "arguments",
            value: [],
            dataType: { Text: null },
            arguments: []
        }
    ]
    const formTitle = computed(() => {
        if (dialogType.value === 'application') {
            return editedIndex.value === -1 ? 'New Application' : 'Edit Application'
        } else if (dialogType.value === 'validator') {
            return editedIndex.value === -1 ? 'New Validator' : 'Edit Validator'
        } else if (dialogType.value === 'criteria') {
            return editedIndex.value === -1 ? 'New Criteria' : 'Edit Criteria'
        }
        return ''
    })

    const fetchApplications = async () => {
        applications.value = toSimpleArray(await getApplications())
    }

    const fetchValidators = async (applicationId) => {
        validators.value = []
        validators.value = toSimpleArray(await getValidators(applicationId))
    }

    const showCriteriaParams = (item) => {
        editedItem.value = item
        params.value = getProviderParams(item.providerParams)
        console.log(params.value);

        dialogCriteriaParams.value = true
    }


    const deleteItem = async (id) => {
        if (confirm('Are you sure you want to delete this application?')) {
            await removeApplication(id)
            fetchApplications()
        }
    }

    const openDialog = (type, item = null) => {
        dialogType.value = type
        if (item) {
            editedIndex.value = type === 'application' ? applications.value.indexOf(item) : validators.value.indexOf(item)
            editedItem.value = Object.assign({}, item)
        } else {
            editedIndex.value = -1
            editedItem.value = {
                id: '',
                name: '',
                description: '',
                validators: [],
                providerParams: JSON.parse(JSON.stringify(paramTemplate))
            }
        }
        dialog.value = true
    }

    const closeDialog = () => {
        dialog.value = false
        editedIndex.value = -1
    }

    const saveItem = async () => {
        if (dialogType.value === 'application') {
            if (editedIndex.value > -1) {
                await updateApplication(editedItem.value)
            } else {
                await createApplication(editedItem.value)
            }
            fetchApplications()
        } else if (dialogType.value === 'validator') {
            if (editedIndex.value > -1) {
                await updateValidator(editedItem.value)
            } else {
                await createValidator(editedItem.value)
            }
            fetchValidators(editedItem.value.applicationId)
        } else if (dialogType.value === 'criteria') {
            if (editedIndex.value > -1) {
                await updateCriteria(editedItem.value)
            } else {
                await createCriteria(editedItem.value)
            }
            fetchValidators(editedItem.value.validatorId)
        }
        closeDialog()
    }

    const saveApplication = async () => {
        if (editedIndex.value > -1) {
            await updateApplication(editedItem.value)
        } else {
            await createApplication(editedItem.value)
        }
        closeDialog()
        fetchApplications()
    }

    // Similar methods for Validator and Criteria

    const addParam = () => {
        editedItem.value.providerParams.push({
            key: '',
            value: [],
            dataType: { Text: null },
            arguments: []
        })
    }

    const removeParam = (index) => {
        editedItem.value.providerParams.splice(index, 1)
    }

    const addArgument = (paramIndex) => {
        editedItem.value.providerParams[paramIndex].arguments.push({
            key: '',
            value: ''
        })
    }

    const removeArgument = (paramIndex, argIndex) => {
        editedItem.value.providerParams[paramIndex].arguments.splice(argIndex, 1)
    }
    fetchApplications()
</script>
<template>
    <v-container>
        <h1 class="text-h5 font-weight-bold mb-4">Manage Applications</h1>

        <v-expansion-panels>
            <v-expansion-panel v-for="app in applications" :key="app.id">
                <v-expansion-panel-title @click="fetchValidators(app.id)">
                    <v-avatar>
                        <v-icon>mdi-application</v-icon>
                    </v-avatar>
                    <span class="font-weight-bold">{{ app.name }}</span>
                    <template v-slot:actions>
                        <v-btn size="small" class="mr-2" @click.stop="openDialog('application', app)">
                            <v-icon>mdi-pencil</v-icon>
                        </v-btn>
                        <v-btn size="small" color="error" @click.stop="deleteItem(app.id)">
                            <v-icon>mdi-delete</v-icon>
                        </v-btn>
                    </template>
                </v-expansion-panel-title>
                <v-expansion-panel-text>
                    <div class="mb-4">{{ app.description }}</div>

                    <!-- Danh sách Validator -->
                    <v-expansion-panels>
                        <v-expansion-panel v-for="validator in validators" :key="validator.id">
                            <v-expansion-panel-title>
                                <v-avatar size="48" class="me-2">
                                    <v-img
                                    :alt="validator.name"
                                    :src="validator.logo"
                                    ></v-img>
                                </v-avatar>
                                {{ validator.name }}
                                <template v-slot:actions>
                                    <v-btn size="small" class="mr-2" @click.stop="openDialog('validator',validator)">
                                        <v-icon>mdi-pencil</v-icon>
                                    </v-btn>
                                    <v-btn size="small" color="error" @click.stop="deleteItem('validator', app.id, validator.id)">
                                        <v-icon>mdi-delete</v-icon>
                                    </v-btn>
                                </template>
                            </v-expansion-panel-title>
                            <v-expansion-panel-text>
                                <p>{{ validator.description }}</p>
                                <v-table hover>
                                    <thead>
                                        <tr>
                                            <th>Criteria</th>
                                            <th>Description</th>
                                            <th>Provider</th>
                                            <th>Score</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr v-for="criteria in validator.criterias" :key="criteria.id">
                                            <td>{{ criteria.name }} <VcFlow v-if="criteria.isVC"></VcFlow></td>
                                            <td>{{ criteria.description }}</td>
                                            <td>
                                                <v-chip v-if="criteria.providerId.length > 0" size="small" color="secondary" label="" text-color="white" @click.stop="showCriteriaParams(criteria)">
                                                    {{ criteria.providerId[0] }}
                                                    <v-tooltip activator="parent" location="top">Show Params</v-tooltip>
                                                </v-chip>
                                            </td>
                                            <td>{{ criteria.score }}</td>
                                            <td>
                                                <v-btn size="small" class="mr-2" @click.stop="openDialog('criteria', criteria)">
                                                    <v-icon>mdi-pencil</v-icon>
                                                </v-btn>
                                                <v-btn size="small" color="error" @click.stop="deleteItem('criteria', validator.id, criteria.id)">
                                                    <v-icon>mdi-delete</v-icon>
                                                </v-btn>
                                            </td>
                                        </tr>
                                    </tbody>
                                </v-table>
                                <v-divider></v-divider>
                                <div class="mt-4">
                                    <v-btn @click="openDialog('criteria', null)"><v-icon>mdi-plus</v-icon> Add Criteria</v-btn>
                                </div>
                            </v-expansion-panel-text>
                        </v-expansion-panel>
                    </v-expansion-panels>
                    <v-divider></v-divider>
                    <div class="mt-4">
                        <v-btn @click="openDialog('validator', app.id)"><v-icon>mdi-plus</v-icon> Add Validator</v-btn>
                    </div>
                </v-expansion-panel-text>
            </v-expansion-panel>
        </v-expansion-panels>
        <v-divider></v-divider>
        <div class="mt-4">
            <v-btn @click="openDialog('application', null)"><v-icon>mdi-plus</v-icon> Add Application</v-btn>
        </div>

        <!-- Dialogs for adding/editing -->

        <v-dialog v-model="dialog" max-width="900px">
            <v-card>
                <v-card-title>
                    <span class="text-h6">{{ formTitle }}</span>
                </v-card-title>
                <v-card-text>
                    <v-text-field v-if="dialogType === 'application'" v-model="editedItem.id" label="Application ID" readonly></v-text-field>
                    <v-text-field v-if="dialogType === 'application'" v-model="editedItem.name" label="Application Name"></v-text-field>
                    <v-textarea v-if="dialogType === 'application'" v-model="editedItem.description" label="Description"></v-textarea>

                    <v-select v-if="dialogType === 'validator'" v-model="editedItem.applicationId" :items="applications" item-title="name" item-value="id" label="Application ID"></v-select>
                    <v-text-field v-if="dialogType === 'validator'" v-model="editedItem.name" label="Validator Name"></v-text-field>
                    <v-text-field v-if="dialogType === 'validator'" v-model="editedItem.logo" label="Logo url"></v-text-field>
                    <v-textarea v-if="dialogType === 'validator'" v-model="editedItem.description" label="Description"></v-textarea>

                    <v-text-field v-if="dialogType === 'criteria'" v-model="editedItem.name" label="Criteria Name"></v-text-field>
                    <v-textarea v-if="dialogType === 'criteria'" v-model="editedItem.description" label="Description"></v-textarea>
                    <v-row>
                        <v-col cols="6">
                            <v-checkbox v-if="dialogType === 'criteria'" v-model="editedItem.isVC" label="Is VC" value="true"></v-checkbox>
                        </v-col>
                        <v-col cols="6">
                            <v-checkbox v-if="dialogType === 'criteria'" v-model="editedItem.autoVerify" label="Auto Verify" value="true"></v-checkbox>
                        </v-col>
                    </v-row>
                    <v-text-field v-if="dialogType === 'criteria'" v-model="editedItem.score" label="Score"></v-text-field>
                    <v-select v-if="dialogType === 'criteria'" v-model="editedItem.providerId" :items="providers" item-title="name" item-value="id" label="Provider ID"></v-select>
                    <v-text-field v-if="dialogType === 'criteria'" v-model="editedItem.expirationTime" label="Expiration Time in seconds"></v-text-field>

                    <!-- Add dynamic data multi for provider params -->
                    <!-- Dynamic params -->
                    <div v-if="dialogType === 'criteria'">
                        <v-card class="px-5 py-5" color="containerBg">
                        <div v-for="(param, index) in editedItem.providerParams" :key="index">
                            <v-row>
                                <v-col cols="10">
                                    <div v-if="param.key === 'arguments'">
                                        Arguments
                                        <v-divider></v-divider>
                                        <div v-for="(arg, argIndex) in param.arguments" :key="argIndex" class="mt-4">
                                            <v-row width="100%">
                                                <v-col cols="5">
                                                    <v-text-field v-model="arg.key" label="Key"></v-text-field>
                                                </v-col>
                                                <v-col cols="5">
                                                    <v-text-field v-model="arg.value" label="Value"></v-text-field>
                                                </v-col>
                                                <v-col cols="2">
                                                    <v-btn color="error" @click="removeArgument(index, argIndex)">Remove</v-btn>
                                                </v-col>
                                            </v-row>
                                        </div>
                                        <v-btn @click="addArgument(index)"> <v-icon>mdi-plus</v-icon> Add Argument</v-btn>
                                    </div>
                                    <div v-else>
                                        <v-text-field v-model="param.value" :label="param.key" ></v-text-field>
                                    </div>
                                </v-col>
                                <v-col cols="2">
                                    <v-btn icon size="small" color="error" @click="removeParam(index)"> <v-icon>mdi-minus</v-icon></v-btn>
                                </v-col>
                            </v-row>
                            
                            
                        </div>
                    </v-card>
                        <v-btn @click="addParam" class="mt-4"> <v-icon>mdi-plus</v-icon> Add Param</v-btn>
                    </div>
                    
                </v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="blue darken-1" text @click="closeDialog">Cancel</v-btn>
                    <v-btn color="blue darken-1" text @click="saveItem">Save</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- Show criteria params -->
        <v-dialog v-model="dialogCriteriaParams" max-width="600px">
            <v-card>
                <v-card-title>
                    <span class="text-h6">{{editedItem.name}} params</span>
                </v-card-title>
                <v-card-text class="text-body-2 pt-0">
                    <v-table>
                        <thead>
                            <tr>
                                <th>Key</th>
                                <th>Value</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Loop from object -->
                            <tr v-for="(value, key) in params" :key="key">
                                <td>{{ key }}</td>
                                <td>
                                    <div v-if="key === 'arguments'">
                                        <v-table density="compact">
                                            <thead>
                                                <tr>
                                                    <th>Key</th>
                                                    <th>Value</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr v-for="(item, k) in value" :key="k">
                                                    <td>{{k}}</td>
                                                    <td>{{item}}</td>
                                                </tr>
                                            </tbody>
                                        </v-table>
                                    </div>
                                    <div v-else>
                                        {{ value }}
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </v-table>
                </v-card-text>
            </v-card>
        </v-dialog>
    </v-container>
</template>