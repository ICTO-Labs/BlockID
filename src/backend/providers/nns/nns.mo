import NNSType "./nnsTypes";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
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
    public func verifyNNS(neuron_id : Nat64, key : Text, walletId : ?Principal) : async Bool {
        switch(await get_full_neuron(neuron_id)){
            case (#Ok(data)) {
                switch(key){
                    case "known-neuron" {
                        let _data = Option.get(data.known_neuron_data, {name = ""; description = ""});
                        if(_data.name != ""){
                            return true;
                        };
                        return false;
                    };
                    case "hot-keys" {
                        if(data.hot_keys.size() > 0){
                            //Check if walletId in hotkeys
                            switch(walletId){
                                case (?id) {
                                    for (hotkey in data.hot_keys.vals()){
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