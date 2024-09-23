
export const getProviderParams = (providerParams) => {
    //Check if providerParams is an array then get element 0
    if(Array.isArray(providerParams) && providerParams.length > 0){
        providerParams = providerParams[0];
    }
    let params = {};
    providerParams.forEach(param => {
        if(Array.isArray(param.value) && param.value.length > 0){
            param.value = param.value[0];
        }
        if(param.key === 'arguments' && Array.isArray(param.arguments) && param.arguments.length > 0){
            //convert array to object
            param.value = getProviderParams(param.arguments);
            console.log('param.value', param.value);
        }
        params[param.key] = param.value;
    })
    return params;
}
