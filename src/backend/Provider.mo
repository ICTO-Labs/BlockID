// Validator.mo
import Types "Types";
import Result "mo:base/Result";
import Int "mo:base/Int";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Array "mo:base/Array";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Char "mo:base/Char";
import Nat32 "mo:base/Nat32";
//Import validator module
import NFT_EXT_V1 "providers/nft-ext-v1";
import NNS "providers/nns/nns";
import Ledger "providers/ledger/transaction";
module {
    public func getNeuronIds() : async [Nat64] {
        return await NNS.get_neuron_ids();
    };
    public func verifyCriteria(walletId: Types.WalletId, criteria: Types.Criteria, provider: Types.Provider, providerParams: ?[Types.ProviderParams]) : async Types.VerificationResult {
        
        switch (provider.moduleType) {
            case (#Local(moduleName)) {
                switch (moduleName) {
                    case "nft-ext-v1" return {
                        isValid = true;
                        score = criteria.score;
                        message = "";
                    };//await NFT_EXT_V1.verify(walletId, criteria.providerParams);
                    // More modules can be added here
                    case "autoValid" return {
                        isValid = true;
                        score = criteria.score;
                        message = "";
                    };
                    case "known-neuron" {
                        switch(providerParams){
                            case (?params) {
                                var _neuronId : Nat64 = 0;
                                for (param in params.vals()) {
                                    switch (param.key) {
                                        case ("neuronId") {
                                            _neuronId := textToNat64(param.value);
                                        };
                                        case _ {};
                                    };
                                };
                                return await NNS.verifyNNS(_neuronId, "known-neuron", ?walletId, criteria.additionalParams);
                            };
                            case (null) {
                                return { isValid = false; score = 0; message = "Failed: Missing neuron ID parameter" };
                            };
                        };
                    };
                    case "hot-keys" {
                        switch(providerParams){
                            case (?params) {
                                var _neuronId : Nat64 = 0;
                                for (param in params.vals()) {
                                    switch (param.key) {
                                        case ("neuronId") {
                                            _neuronId := textToNat64(param.value);
                                        };
                                        case _ {};
                                    };
                                };
                                return await NNS.verifyNNS(_neuronId, "hot-keys", ?walletId, criteria.additionalParams);
                            };
                            case (null) {
                                return { isValid = false; score = 0; message = "Failed: Missing neuron ID parameter" };
                            };
                        };
                    };
                    case "neuron-age" {
                        switch(providerParams){
                            case (?params) {
                                var _neuronId : Nat64 = 0;
                                for (param in params.vals()) {
                                    switch (param.key) {
                                        case ("neuronId") {
                                            _neuronId := textToNat64(param.value);
                                        };
                                        case _ {};
                                    };
                                };
                                return await NNS.verifyNNS(_neuronId, "neuron-age", ?walletId, criteria.additionalParams);
                            };
                            case (null) {
                                return { isValid = false; score = 0; message = "Failed: Missing neuron ID parameter" };
                            };
                        };
                    };
                    case "8-years-gang" {
                        switch(providerParams){
                            case (?params) {
                                var _neuronId : Nat64 = 0;
                                for (param in params.vals()) {
                                    switch (param.key) {
                                        case ("neuronId") {
                                            _neuronId := textToNat64(param.value);
                                        };
                                        case _ {};
                                    };
                                };
                                return await NNS.verifyNNS(_neuronId, "8-years-gang", ?walletId, criteria.additionalParams);
                            };
                            case (null) {
                                return { isValid = false; score = 0; message = "Failed: Missing neuron ID parameter" };
                            };
                        };
                    };
                    case "spent-volume" {
                        return await Ledger.verifyICPTransaction(walletId, "spent-volume", criteria.additionalParams);
                    };
                    case "count-tx" {
                        return await Ledger.verifyICPTransaction(walletId, "count-tx", criteria.additionalParams);
                    };
                    case "volume" {
                        return await Ledger.verifyICPTransaction(walletId, "volume", criteria.additionalParams);
                    };
                    case _ return { isValid = false; score = 0; message = "Unknown module" };
                };
            };
            case (#Remote(canisterId)) {
                let remoteCanister = actor(canisterId) : actor {
                    verify : (Types.WalletId) -> async Types.VerificationResult;
                };
                return await remoteCanister.verify(walletId);
            };
            case (#Custom(_moduleName)) {
                switch (_moduleName) {
                    case _ return { isValid = false; score = 0; message = "Unknown module" };
                };
            };
            case _ {
                return { isValid = false; score = 0; message = "Unknown module" };
            };
        };
        // let value = await getValue(walletId, criteria);
        // let isValid = compare(value, criteria.params);
        // {
        //     isValid = isValid;
        //     score = if (isValid) criteria.score else 0;
        // }
    };

    // private func compare(value: Int, params: Types.ProviderParams) : Bool {
    //     switch (params.comparisonType) {
    //         case (#GreaterThan) value > params.minValue;
    //         case (#LessThan) value < params.minValue;
    //         case (#GreaterThanOrEqual) value >= params.minValue;
    //         case (#LessThanOrEqual) value <= params.minValue;
    //         case (#Equal) value == params.minValue;
    //         case (#Between) {
    //             switch (params.maxValue) {
    //                 case (?maxValue) value >= params.minValue and value <= maxValue;
    //                 case (null) false;
    //             };
    //         };
    //     }
    // };

    // private func getValue(walletId: Types.WalletId, criteria: Types.Criteria) : async Int {
    //     switch(criteria.providerId) {
    //         case ("canic-nft") await NFT_EXT_V1.verify(walletId, criteria.params);
    //         // case ("canic-token") await getTokenBalance(walletId);
    //         case (_) 0;  // Default value, you might want to handle this differently
    //     }
    // };
    func textToNat64(value: ?Text) : Nat64 {
        switch (value) {
            case (null) { 0 };
            case (?v) {
            let natValue = textToNat(v);
            Nat64.fromNat(natValue);
            };
        };
    };
    func textToNat(txt : Text) : Nat {
        assert(txt.size() > 0);
        let chars = txt.chars();
        var num : Nat = 0;
        for (v in chars){
            let charToNum = Nat32.toNat(Char.toNat32(v)-48);
            assert(charToNum >= 0 and charToNum <= 9);
            num := num * 10 +  charToNum;          
        };
        num;
    };
}