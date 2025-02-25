import Types "Types";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Nat32 "mo:base/Nat32";
import Char "mo:base/Char";

/////// IMPORT APPROVED PROVIDERS ///////////////////
import nftChecker "./approved/nftChecker";


////////////////////////////////////////////////////

actor Marketplace {
    // State
    private var providers = HashMap.HashMap<Text, Types.ProviderInfo>(0, Text.equal, Text.hash);
    private stable var _providers: [(Text, Types.ProviderInfo)] = [];
    private stable var _admins : [Principal] = [Principal.fromText("lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe")];

    //System
    system func preupgrade() {
        _providers := Iter.toArray(providers.entries());
    };
    system func postupgrade() {
        providers := HashMap.fromIter(_providers.vals(), 0, Text.equal, Text.hash);
    };
    private func removeSpecialChars(input: Text) : Text {
        let chars = Text.toIter(input);
        let filtered = Iter.map(chars, func (c : Char) : Char {
            if (Char.isAlphabetic(c) or Char.isDigit(c)) {
                c
            } else {
                '_'
            }
        });
        Text.fromIter(filtered)
    };
    //Verify
    public shared func verify(
        providerId: Text,
        walletId: Principal,
        params: ?[Types.ProviderParam]
    ) : async Types.VerificationResult {
        switch(providers.get(providerId)) {
            case null { 
                return {
                    isValid = false;
                    score = 0;
                    message = "Provider #" # providerId # " not found";
                }; 
            };
            case (?info) {
                if (info.status != #Approved) {
                    return {
                        isValid = false;
                        score = 0;
                        message = "Provider #" # providerId # " not approved";
                    };
                };

                // Call verify from corresponding module
                switch(info.moduleName) {
                    case "nftChecker" {
                        return await nftChecker.verify(walletId, params);
                    };
                    // case "token_holder" {
                    //     return await tokenHolder.verify(walletId, params);
                    // };
                    case _ {
                        return {
                            isValid = false;
                            score = 0;
                            message = "Unknown provider module #" # info.moduleName;
                        };
                    };
                };
            };
        };
    };
    // Submit provider
    public shared(msg) func submitProvider(
        name: Text,
        description: Text,
        sourceUrl: Text,
        moduleName: Text,
        canisterId: ?Principal
    ) : async Result.Result<Text, Text> {
        //Check exist
        let _moduleName = removeSpecialChars(moduleName);
        if (Text.size(_moduleName) < 3) {
            return #err("moduleName must be at least 3 characters, no special characters");
        };
        let provider = providers.get(_moduleName);
        if (provider != null) {
            return #err("moduleName already exists");
        };

        // let id = generateId(name, msg.caller);
        
        if (Text.size(name) == 0) {
            return #err("Name cannot be empty");
        };

        providers.put(_moduleName, {
            id = _moduleName;
            name;
            description;
            sourceUrl;
            status = #Pending;
            moduleName = _moduleName;
            submittedAt = Time.now();
            reviewNote = null;
            owner = msg.caller;
            canisterId = canisterId;
        });

        #ok(moduleName)
    };

    // Admin review
    public shared(msg) func reviewProvider(
        id: Text,
        status: {#Approved; #Rejected},
        canisterId: ?Principal,
        note: ?Text
    ) : async Result.Result<(), Text> {
        if (not isAdmin(msg.caller)) {
            return #err("Unauthorized");
        };

        switch(providers.get(id)) {
            case null { #err("Provider not found") };
            case (?provider) {
                providers.put(id, {
                    provider with
                    status = status;
                    canisterId = canisterId;
                    reviewNote = note;
                });
                #ok()
            };
        };
    };


    // Query functions
    public query func listProviders() : async [Types.ProviderInfo] {
        Iter.toArray(providers.vals())
    };

    public query func getProvider(id: Text) : async ?Types.ProviderInfo {
        providers.get(id)
    };

    public shared ({caller}) func getMyProviders() : async [Types.ProviderInfo] {
        Array.filter<Types.ProviderInfo>(
            Iter.toArray(providers.vals()),
            func(p) { 
                Principal.equal(p.owner, caller)
            }
        )
    };
    public query func listApprovedProviders() : async [Types.ProviderInfo] {
        Array.filter<Types.ProviderInfo>(
            Iter.toArray(providers.vals()),
            func(p) { 
                switch(p.status) {
                    case (#Approved) true;
                    case (_) false;
                }
            }
        )
    };

    // Add admin
    public shared(msg) func addAdmin(principal: Principal) : async Result.Result<(), Text> {
        if (not isAdmin(msg.caller)) {
            return #err("Unauthorized");
        };
        _admins := Array.append(_admins, [principal]);
        #ok()
    };

    // Remove admin
    public shared(msg) func removeAdmin(principal: Principal) : async Result.Result<(), Text> {
        if (not isAdmin(msg.caller)) {
            return #err("Unauthorized");
        };
        _admins := Array.filter<Principal>(_admins, func(p) { not Principal.equal(p, principal) });
        #ok()
    };

    private func isAdmin(caller: Principal) : Bool {

        for (i in _admins.vals()) {
            if (Principal.equal(i, caller)) {
                return true;
            };
        };
        false;
    };
}