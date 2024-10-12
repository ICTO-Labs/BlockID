import { validate } from '@/../../declarations/validate/index.js';
import { Principal } from '@dfinity/principal';
import { requestVerifiablePresentation } from '@dfinity/verifiable-credentials/request-verifiable-presentation';
import { DEVRIVATION_ORIGIN, INTERNET_INDENTITY, VC_VALIDATOR_CANISTER_ID } from '@/config';
import Connect from "@/actor/Connect";

class VerifyService {
    async getCredential(userPrincipal, providerParams, providerArgs, validateData) {
        console.log('--------providerArgs', providerArgs);
        try {
            const issuerData = {
                origin: providerParams.issuerOrigin,
                canisterId: Principal.fromText(providerParams.issuerCanisterId)
            };
            const credentialData = {
                credentialSpec: {
                    credentialType: providerParams.credentialType,
                    arguments: {}
                },
                credentialSubject: Principal.fromText(userPrincipal)
            };
            return new Promise((resolve, reject) => {
                const onSuccess = async (response) => {
                    console.log('VC Request Successful:', response);
                    //Send request to validate
                    try {
                        const validationResult = await this.validateCredential(
                            userPrincipal,
                            response.Ok,
                            providerParams,
                            providerArgs,
                            validateData
                        );
                        resolve({
                            success: validationResult && 'Ok' in validationResult,
                            validationResult
                        });
                    } catch (error) {
                        reject(error);
                    }
                };

                const onError = (error) => {
                    console.error('VC Request Failed:', error);
                    reject(error);
                };

                const identityProvider = new URL(INTERNET_INDENTITY);
                const derivationOrigin = DEVRIVATION_ORIGIN;
                const requestParams = {
                    onSuccess,
                    onError,
                    credentialData,
                    issuerData,
                    identityProvider,
                    derivationOrigin
                };
                console.log('requestParams', requestParams);
                requestVerifiablePresentation(requestParams);
            });
        } catch (error) {
            console.error('Error getting credentials:', error);
            throw error;
        }
    }
    async validateCredential(userPrincipal, jwt, providerParams, providerArgs, validateData) {
        // console.log('jwt decoded', decodeJwt(jwt));
        // let _decodedJWT = decodeJwt(jwt);
        // try{
        //     _decodedJWT.vp.verifiableCredential.forEach(vc => {
        //         console.log('vc', vc);
        //         console.log('decoded', decodeJwt(vc));
        //     });
        // }catch(error){
        //     console.log('Error validating JWT:', error);
        //     throw error;
        // }
        console.log('Start verify...', providerParams, userPrincipal);
    
        try {
            const _request_data = {
                effective_vc_subject: Principal.fromText(userPrincipal),
                issuer_origin: providerParams.issuerOrigin,
                issuer_canister_id: Principal.fromText(providerParams.issuerCanisterId),
                vp_jwt: jwt,
                credential_spec: {
                    credential_type: providerParams.credentialType,
                    arguments: Object.keys(providerArgs).length > 0 ? [providerArgs] : []
                },
                validate_data: validateData
            }
            console.log('request_data', _request_data);
            const requestVerify = await Connect.canister(VC_VALIDATOR_CANISTER_ID, 'validate').validate(_request_data);
            console.log('requestVerify', requestVerify);
            return requestVerify;
        } catch (error) {
            console.log('Error validating JWT:', error);
            throw error;
        }
    }
}

export default new VerifyService();
