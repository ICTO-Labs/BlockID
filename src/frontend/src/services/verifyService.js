import { validate } from '@/../../declarations/validate/index.js';
import { Principal } from '@dfinity/principal';
import { requestVerifiablePresentation } from "@dfinity/verifiable-credentials/request-verifiable-presentation";

class VerifyService {
    async getCredential(userPrincipal){
        try {
            const issuerData = {
                origin: 'https://id.decideai.xyz',
                canisterId: Principal.fromText('qgxyr-pyaaa-aaaah-qdcwq-cai'),
            };
            const credentialData = {
                credentialSpec: {
                    credentialType: 'ProofOfUniqueness',
                    arguments: {}
                },
                credentialSubject: Principal.fromText(userPrincipal)
            };
            return new Promise((resolve, reject) => {
                const onSuccess = async (response) => {
                    console.log('VC Request Successful:', response);
                    //Send request to validate
                    try{
                        const validationResult = await this.validateCredential(userPrincipal, response.Ok);
                        resolve({success: validationResult && 'Ok' in validationResult, validationResult, score: 15});
                    }catch(error){
                        reject(error);
                    }
                }

                const onError = (error) => {
                    console.error('VC Request Failed:', error);
                    reject(error);
                }
            
                const identityProvider =  new URL("https://identity.ic0.app/");
                const derivationOrigin = undefined;//"http://localhost:3000/";//https://3f66t-ryaaa-aaaap-qhriq-cai.icp0.io";
                const requestParams = {
                    onSuccess,
                    onError,
                    credentialData,
                    issuerData,
                    identityProvider,
                    derivationOrigin
                };
                console.log('requestParams',requestParams);
                requestVerifiablePresentation(requestParams);
            })
        } catch (error) {
            console.error("Error getting credentials:", error);
            throw error;
        }
    }
    async validateCredential(userPrincipal, jwt){
        console.log('Start verify...');
        try{
            const requestVerify = await validate.validate_ii_vp({
                effective_vc_subject: Principal.fromText(userPrincipal),
                issuer_origin: 'https://id.decideai.xyz/',
                issuer_canister_id: Principal.fromText('qgxyr-pyaaa-aaaah-qdcwq-cai'),
                vp_jwt: jwt,
                credential_spec: {
                    credential_type: 'ProofOfUniqueness',
                    arguments: [] 
                },
            });
            console.log('requestVerify', requestVerify);
            return requestVerify && 'Ok' in requestVerify;
        }catch(error){
            console.log('Error validating JWT:', error);
            throw error;
        }
    }
}

export default new VerifyService();