import NNSType "./nnsTypes";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Nat64 "mo:base/Nat64";
import Utils "../../Utils";
import Types "../../Types";
module {
    let NNS : NNSType.Self = actor "rrkah-fqaaa-aaaaa-aaaaq-cai";

    //Get hotkeys neurons id
    public func get_neuron_ids() : async [Nat64] {
        let neuron_ids = await NNS.get_neuron_ids();
        return neuron_ids;
    };
    func get_neuron_info(neuron_id : Nat64) : async NNSType.Result_5 {
        let neuron_info = await NNS.get_neuron_info(neuron_id);
        return neuron_info;
    };
    func list_known_neurons() : async NNSType.ListKnownNeuronsResponse {
        let known_neurons = await NNS.list_known_neurons();
        return known_neurons;
    };
    func get_full_neuron(neuron_id : Nat64) : async NNSType.Result_2 {
        try{
            let neuron_info = await NNS.get_full_neuron(neuron_id);
            return neuron_info;
        }catch(e){
            return #Err({error_message = "Unknown"; error_type = 0});
        };
    };
    public func verifyNNS(neuron_id : Nat64, key : Text, walletId : ?Principal, additionalParams : ?Types.AdditionalParams) : async Bool {
        switch(await get_full_neuron(neuron_id)){
            case (#Ok(neuronInfo)) {
                switch(key){
                    case "known-neuron" {
                        let _data = Option.get(neuronInfo.known_neuron_data, {name = ""; description = ""});
                        if(_data.name != ""){
                            return true;
                        };
                        return false;
                    };
                    case "hot-keys" {
                        if(neuronInfo.hot_keys.size() > 0){
                            //Check if walletId in hotkeys
                            switch(walletId){
                                case (?id) {
                                    for (hotkey in neuronInfo.hot_keys.vals()){
                                        if(Principal.equal(hotkey, id)){
                                            return true;
                                        };
                                    };
                                };
                                case (null) {
                                    return false;
                                };
                            };
                            return false;
                        };
                        return false;
                    };
                    case "neuron-age" {
                        //Verify age greater than 3 years old
                        let _current_time = Time.now() / 1000000000;
                        let age = switch (neuronInfo.dissolve_state) {
                            case (?#DissolveDelaySeconds(_delay)) {
                                Nat64.toNat(_delay);//Using dissolve delay as age
                            };
                            case (?#WhenDissolvedTimestampSeconds(_whenDissolved)) {
                                // Neuron is dissolving
                                // current_time - Nat64.toNat(neuronInfo.created_timestamp_seconds)
                                0;
                            };
                            case (null) { 0 };
                        };
                        switch (additionalParams) {
                            case (null) return age > 3*365*24*60*60; // if no additionalParams, consider it valid!! Keep default value
                            case (?params) {
                                return Utils.compareValues(age, params.value, params.comparisonType, params.maxValue);
                            };
                        };
                    };
                    case "8-years-gang" {
                        let requiredTime = 8 * 365 * 24 * 60 * 60; // 8 years in seconds
                        switch (neuronInfo.dissolve_state) {
                            case (?#DissolveDelaySeconds(_delay)) {//Only accept dissolve delay (not dissolving)
                                let age = Nat64.toNat(_delay);
                                switch (additionalParams) {
                                    case (null) { return age >= requiredTime; };
                                    case (?params) {
                                        return age >= requiredTime and Utils.compareValues(Nat64.toNat(neuronInfo.cached_neuron_stake_e8s/100000000), params.value, params.comparisonType, params.maxValue);
                                    };
                                };
                            };
                            case (_) { return false; };
                        };
                    };
                    case "golden-sunset" {
                        let requiredTime = 8 * 365 * 24 * 60 * 60; // 8 years in seconds
                        switch (neuronInfo.dissolve_state) {
                            //Only check if neuron is dissolving
                            case (?#WhenDissolvedTimestampSeconds(_dateToDissolve)) {
                                let age = 0;//Nat64.toNat(dateToDissolve) - Nat64.toNat(neuronInfo.created_timestamp_seconds);
                                switch (additionalParams) {
                                    case (null) { return age >= requiredTime and neuronInfo.cached_neuron_stake_e8s >= 100_00000000; };
                                    case (?params) {
                                        let minimumStake: Nat64 = Utils.intToNat64(params.value) * 100000000; // Convert ICP to E8S
                                        return age >= requiredTime and neuronInfo.cached_neuron_stake_e8s >= minimumStake and 
                                            Utils.compareValues(Nat64.toNat(neuronInfo.cached_neuron_stake_e8s), params.value, params.comparisonType, params.maxValue);
                                    };
                                };
                            };
                            case (_) { return false; };
                        };
                    };
                    case _ {
                        return false;
                    };
                };
            };
            case (#Err(_)) {
                return false;
            };
        };
        return false;
    };
}