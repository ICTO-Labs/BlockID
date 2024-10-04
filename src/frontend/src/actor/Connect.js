import { storeToRefs } from 'pinia';
import { actor } from "./Actor";
import { useWalletStore } from '@/store/walletStore'
import { preloadIdls, mapIdls } from './didList';
class CreateActor {
    _canister = false;
    _idl = false;
    _actor = false;
    _type = "";
    constructor(canister, idl, isAnonymous=false) {
        const walletStore = useWalletStore();
        const { wallet, walletInfo } = storeToRefs(walletStore);
        if (canister) this._canister = canister;
        if (idl) this._idl = idl;
        return new Proxy(this, {
            get : (target, name) => {
                return async function() {
                    if (!target._actor) {
                        if(isAnonymous == true){
                            target._actor = await actor.create({
                                identity: null,
                                canisterId: canister,
                                idlFactory: idl,
                            });
                        }else{
                            if(wallet.value == "PLUG"){
                                target._actor = await window.ic.plug.createActor({
                                    canisterId: target._canister,
                                    interfaceFactory: target._idl,
                                });
                            }else{
                                target._actor = await actor.create({
                                    identity: walletInfo.value[wallet.value].identity,
                                    canisterId: canister,
                                    idlFactory: idl,
                                });
                            }
                        }
                        
                    }
                    try{
                        return await target._actor[name](...arguments);
                    }catch(e){
                        console.log('Create Proxy failed:', e, name);
                        return null;
                    }
                    
                }
            }
        });
    }
}

class Connect {
    _requiredAuth = false;
    _preloadedIdls = preloadIdls;
    _mapIdls = mapIdls;
    _canisters = {};
    _actor = null;
    _provider = null;

    constructor(cid, idl, isAnonymous=false) {
        const walletStore = useWalletStore();
        const { wallet, walletInfo } = storeToRefs(walletStore);

        if(!cid) throw new Error("No Canister Id");
        if (!idl){
            if (Object.prototype.hasOwnProperty.call(this._mapIdls, cid)) {
                idl = this._mapIdls[cid];
            } else {
                idl = this._preloadedIdls['ledger'];
            }
        }else if (typeof idl == 'string'){
            if (Object.prototype.hasOwnProperty.call(this._preloadedIdls, idl)) {
                idl = this._preloadedIdls[idl];
            } else {
                throw new Error(idl + " is not a preloaded IDL");
            }
        }
        if (!Object.prototype.hasOwnProperty.call(this._canisters, cid)){
            this._canisters[cid] = new CreateActor(cid, idl, isAnonymous);
        }
        return this._canisters[cid];
    }
}


export default {
    canister : (cid, idl, isAnonymous) => new Connect(cid, idl, isAnonymous)
};