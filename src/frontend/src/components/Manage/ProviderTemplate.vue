<script>
export default {
    data() {
        return {
            template: {
                id: '',
                name: '',
                description: '',
                paramTemplates: []
            },
            paramTypes: ['Int', 'Text', 'Bool', 'Select']
        };
    },
    methods: {
        addParam() {
            this.template.paramTemplates.push({
                key: '',
                type: 'Text',
                label: '',
                description: ''
            });
        },
        removeParam(index) {
            this.template.paramTemplates.splice(index, 1);
        },
        async createTemplate() {
            // Ở đây, bạn sẽ gọi API để tạo template mới
            // Ví dụ:
            // try {
            //   await api.createTemplate(this.template)
            //   this.$router.push('/templates')
            // } catch (error) {
            //   console.error('Lỗi khi tạo template:', error)
            // }
            console.log('Template được tạo:', this.template);
        }
    }
};
</script>
<template>
    <v-container>
        <v-row justify="center">
            <v-col cols="12" sm="8" md="6">
                <v-card class="elevation-12">
                    <v-toolbar color="primary" dark flat>
                        <v-toolbar-title>Tạo Template Mới</v-toolbar-title>
                    </v-toolbar>
                    <v-card-text>
                        <v-form @submit.prevent="createTemplate">
                            <v-text-field
                                v-model="template.id"
                                label="ID"
                                required
                            ></v-text-field>
                            <v-text-field
                                v-model="template.name"
                                label="Tên"
                                required
                            ></v-text-field>
                            <v-textarea
                                v-model="template.description"
                                label="Mô tả"
                                required
                            ></v-textarea>
                            <v-card-title>Tham số</v-card-title>
                            <v-btn @click="addParam" color="secondary"
                                >Thêm tham số</v-btn
                            >
                            <v-list>
                                <v-list-item
                                    v-for="(
                                        param, index
                                    ) in template.paramTemplates"
                                    :key="index"
                                >
                                    <v-text-field
                                        v-model="param.key"
                                        label="Tên tham số"
                                    ></v-text-field>
                                    <v-select
                                        v-model="param.type"
                                        :items="paramTypes"
                                        label="Loại"
                                    ></v-select>
                                    <v-text-field
                                        v-model="param.label"
                                        label="Nhãn"
                                    ></v-text-field>
                                    <v-text-field
                                        v-model="param.description"
                                        label="Mô tả"
                                    ></v-text-field>
                                    <v-btn icon @click="removeParam(index)">
                                        <v-icon>mdi-delete</v-icon>
                                    </v-btn>
                                </v-list-item>
                            </v-list>
                        </v-form>
                    </v-card-text>
                    <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn color="primary" @click="createTemplate"
                            >Tạo Template</v-btn
                        >
                    </v-card-actions>
                </v-card>
            </v-col>
        </v-row>
    </v-container>
</template>
