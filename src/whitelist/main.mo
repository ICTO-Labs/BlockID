import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Prim "mo:prim";
actor WhitelistVerifier {
    // Stable variables for upgrade
    private stable var whitelistEntries: [(Principal, Bool)] = [];
    private stable var adminEntries: [(Principal, Bool)] = [];
    private stable var blockIDCanister: Text = "";

    // Use HashMap for better performance
    private var whitelist = HashMap.HashMap<Principal, Bool>(100, Principal.equal, Principal.hash);
    private var admins = HashMap.HashMap<Principal, Bool>(10, Principal.equal, Principal.hash);

    type VerificationResult = {
        isValid: Bool;
        score: Nat;
        message: Text;
    };

    // System functions for upgrade
    system func preupgrade() {
        whitelistEntries := Iter.toArray(whitelist.entries());
        adminEntries := Iter.toArray(admins.entries());
    };

    system func postupgrade() {
        whitelist := HashMap.fromIter<Principal, Bool>(whitelistEntries.vals(), 100, Principal.equal, Principal.hash);
        admins := HashMap.fromIter<Principal, Bool>(adminEntries.vals(), 10, Principal.equal, Principal.hash);
    };

    // Check if caller is admin
    private func isAdmin(caller: Principal) : Bool {
        let isController = Prim.isController(caller);
        let is_admin = switch(admins.get(caller)) {
            case (?exists) { exists };
            case null { false };
        };
        is_admin or isController
    };

    // Check if principal is whitelisted
    private func isWhitelisted(p: Principal) : Bool {
        switch(whitelist.get(p)) {
            case (?exists) { exists };
            case null { false };
        }
    };

    // Add multiple principals to whitelist
    public shared({caller}) func batchAddToWhitelist(principals: [Principal]) : async Result.Result<(Nat, Nat), Text> {
        if (not isAdmin(caller)) {
            return #err("Not authorized");
        };

        var addedCount = 0;
        var skippedCount = 0;
        
        for (p in principals.vals()) {
            if (not isWhitelisted(p)) {
                whitelist.put(p, true);
                addedCount += 1;
            } else {
                skippedCount += 1;
            }
        };

        #ok((addedCount, skippedCount))
    };

    // Remove multiple principals from whitelist
    public shared({caller}) func batchRemoveFromWhitelist(principals: [Principal]) : async Result.Result<Nat, Text> {
        if (not isAdmin(caller)) {
            return #err("Not authorized");
        };

        var removedCount = 0;
        for (p in principals.vals()) {
            switch(whitelist.remove(p)) {
                case (?_) { removedCount += 1; };
                case (null) { /* Not in whitelist */ };
            };
        };

        #ok(removedCount)
    };

    // Add admin
    public shared({caller}) func addAdmin(newAdmin: Principal) : async Result.Result<(), Text> {
        if (not isAdmin(caller)) {
            return #err("Not authorized");
        };

        if (isAdmin(newAdmin)) {
            return #err("Already an admin");
        };

        admins.put(newAdmin, true);
        #ok()
    };

    // Remove admin
    public shared({caller}) func removeAdmin(admin: Principal) : async Result.Result<(), Text> {
        if (not isAdmin(caller)) {
            return #err("Not authorized");
        };

        switch(admins.remove(admin)) {
            case (?_) { #ok() };
            case (null) { #err("Admin not found") };
        }
    };

    // Set BlockID canister ID
    public shared({caller}) func setBlockIDCanister(canisterId: Text) : async Result.Result<(), Text> {
        if (not isAdmin(caller)) {
            return #err("Not authorized");
        };
        blockIDCanister := canisterId;
        #ok()
    };

    // Verify function that BlockID can call
    public shared({caller}) func verify(walletId: Principal) : async VerificationResult {
        // if (Principal.toText(caller) != blockIDCanister) {
        //     return {
        //         isValid = false;
        //         score = 0;
        //         message = "Unauthorized caller";
        //     };
        // };

        if (isWhitelisted(walletId)) {
            return {
                isValid = true;
                score = 100;
                message = "Wallet is whitelisted";
            };
        };

        return {
            isValid = false;
            score = 0;
            message = "Your wallet is not whitelisted!";
        };
    };

    // Query functions with pagination support
    public query func getWhitelistPaginated(offset: Nat, limit: Nat) : async {
        items: [Principal];
        total: Nat;
    } {
        let buffer = Buffer.Buffer<Principal>(0);
        var skip = offset;
        var count = 0;
        
        for ((principal, _) in whitelist.entries()) {
            if (count >= offset and buffer.size() < limit) {
                buffer.add(principal);
            };
            count += 1;
        };

        {
            items = Buffer.toArray(buffer);
            total = count;
        }
    };

    // Get total whitelisted count
    public query func getWhitelistCount() : async Nat {
        whitelist.size()
    };

    // Check multiple principals at once
    public query func batchCheckWhitelist(principals: [Principal]) : async [(Principal, Bool)] {
        Array.map<Principal, (Principal, Bool)>(principals, func(p) {
            (p, isWhitelisted(p))
        })
    };

    // Get admins
    public query func getAdmins() : async [Principal] {
        Iter.toArray(admins.keys())
    };

    // Check if principal is whitelisted
    public query func checkIsWhitelisted(p: Principal) : async Bool {
        isWhitelisted(p)
    };
}