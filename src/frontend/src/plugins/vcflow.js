export const getProviderParams = (providerParams) => {
    //Check if providerParams is an array then get element 0
    if (Array.isArray(providerParams) && providerParams.length > 0) {
        providerParams = providerParams[0];
    }
    let params = {};
    providerParams.forEach((param) => {
        if (Array.isArray(param.value) && param.value.length > 0) {
            param.value = param.value[0];
        }
        params[param.key] = param.value;
    });
    return params;
};
