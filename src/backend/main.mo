import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import Bool "mo:base/Bool";

import Types "Types";
import Provider "Provider";

actor BlockID {

    //Store data
    private var validators = HashMap.HashMap<Text, Types.Validator>(0, Text.equal, Text.hash);
    private stable var _validators: [(Text, Types.Validator)] = [];
    private var groups = HashMap.HashMap<Text, Types.Group>(0, Text.equal, Text.hash);
    private stable var _groups: [(Text, Types.Group)] = [];
    private var criterias = HashMap.HashMap<Text, Types.Criteria>(0, Text.equal, Text.hash);
    private stable var _criterias: [(Text, Types.Criteria)] = [];
    private var wallets = HashMap.HashMap<Types.WalletId, Types.Wallet>(0, Principal.equal, Principal.hash);
    private stable var _wallets: [(Types.WalletId, Types.Wallet)] = [];
    private stable var _admins : [Text] = ["lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"];

    //********************** System function **********************//
    system func preupgrade() {
        _validators := Iter.toArray(validators.entries());
        _groups := Iter.toArray(groups.entries());
        _criterias := Iter.toArray(criterias.entries());
        _wallets := Iter.toArray(wallets.entries());
    };
    system func postupgrade() {
        validators := HashMap.fromIter<Text, Types.Validator>(_validators.vals(), 0, Text.equal, Text.hash);
        groups := HashMap.fromIter<Text, Types.Group>(_groups.vals(), 0, Text.equal, Text.hash);
        criterias := HashMap.fromIter<Text, Types.Criteria>(_criterias.vals(), 0, Text.equal, Text.hash);
        wallets := HashMap.fromIter<Types.WalletId, Types.Wallet>(_wallets.vals(), 0, Principal.equal, Principal.hash);
    };
    //********************** System function **********************//
    private func _isAdmin(p : Text) : (Bool) {
        for (i in _admins.vals()) {
            if (i == p) {
                return true;
            };
        };
        return false;
    };
    //Add a new Validator
    public shared ({caller}) func addValidator(validator: Types.Validator) : async () {
        assert(_isAdmin(Principal.toText(caller)));
        validators.put(validator.id, validator);
    };

    //Add a new Group to a Validator
    public shared ({caller}) func addGroupToValidator(group: {
            validatorId: Types.ValidatorId; 
            groupId: Types.GroupId;
            groupName: Text;
            groupDescription: Text
        }) : async () {
        assert(_isAdmin(Principal.toText(caller)));
        switch (validators.get(group.validatorId)) {
            case null { /* Validator not existed */ };
            case (?validator) {
                let updatedGroups = Array.append(validator.groups, [group.groupId]);
                validators.put(group.validatorId, { validator with groups = updatedGroups });
                groups.put(group.groupId, { id = group.groupId; name = group.groupName; description = group.groupDescription; criterias = [] });
            };
        };
    };

    //Remove group by group id and also remove from validators
    public shared ({caller}) func removeGroup(groupId: Types.GroupId) : async () {
        assert(_isAdmin(Principal.toText(caller)));
        //Remove from validators
        for (validator in validators.vals()) {
            let updatedGroups = Array.filter(validator.groups, func (id: Types.GroupId) : Bool { id != groupId });
            validators.put(validator.id, { validator with groups = updatedGroups });
        };
        //Remove from groups
        let _ = groups.remove(groupId);
    };
    //Remove wallet by wallet id
    public shared ({caller}) func removeWallet(walletId: Types.WalletId) : async () {
        assert(_isAdmin(Principal.toText(caller)));
        let _ = wallets.remove(walletId);
    };

    public shared ({caller}) func addGroup(group: Types.Group) : async () {
        assert(_isAdmin(Principal.toText(caller)));
        groups.put(group.id, group);
    };

    public shared ({caller}) func addCriteria(criteria: Types.Criteria) : async () {
        assert(_isAdmin(Principal.toText(caller)));
        criterias.put(criteria.id, criteria);
    };

    public shared ({caller}) func addCriteriaToGroup(
        criteria: {
            groupId: Types.GroupId;
            criteriaId: Types.CriteriaId;
            name: Text;
            description: Text;
            providerId: Text;
            params: Types.ProviderParams; 
            score: Nat;
            expirationTime: Int;
            autoVerify: Bool
        }
    ) : async () {
        assert(_isAdmin(Principal.toText(caller)));
        switch (groups.get(criteria.groupId)) {
            case null { /* Group not existed */ };
            case (?group) {
                let updatedCriterias = Array.append(group.criterias, [criteria.criteriaId]);
                groups.put(criteria.groupId, { group with criterias = updatedCriterias });
                
                let _criteria : Types.Criteria = {
                    id = criteria.criteriaId;
                    name = criteria.name;
                    description = criteria.description;
                    providerId = criteria.providerId;
                    params = criteria.params;
                    score = criteria.score;
                    expirationTime = criteria.expirationTime;
                    autoVerify = criteria.autoVerify;
                };
                
                criterias.put(criteria.criteriaId, _criteria);
            };
        };
    };

    private func getOrCreateWallet(walletId: Types.WalletId) : Types.Wallet {
        switch (wallets.get(walletId)) {
            case null {
                let newWallet : Types.Wallet = { id = walletId; scores = [] };
                wallets.put(walletId, newWallet);
                newWallet
            };
            case (?wallet) { wallet };
        }
    };

    public shared(msg) func verifyWallet(walletId: Types.WalletId, validatorId: Types.ValidatorId) : async Result.Result<Nat, Text> {
        switch (validators.get(validatorId)) {
            case null { #err("Validator not found") };
            case (?validator) {
                var totalScore = 0;
                var newScores : [Types.WalletScore] = [];
                let now = Time.now();

                for (groupId in validator.groups.vals()) {
                    switch (groups.get(groupId)) {
                        case null { /* Skip if group not found */ };
                        case (?group) {
                            for (criteriaId in group.criterias.vals()) {
                                switch (criterias.get(criteriaId)) {
                                    case null { /* Skip if criteria not found */ };
                                    case (?criteria) {
                                        if (criteria.autoVerify) {
                                            let result = await Provider.verifyCriteria(walletId, criteria);
                                            if (result.isValid) {
                                                let newScore : Types.WalletScore = {
                                                    validatorId = validatorId;
                                                    groupId = groupId;
                                                    criteriaId = criteriaId;
                                                    score = result.score;
                                                    verified = true;
                                                    verificationTime = now;
                                                    expirationTime = now + criteria.expirationTime;
                                                };
                                                newScores := Array.append(newScores, [newScore]);
                                                totalScore += result.score;
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };

                // Update wallet scores
                switch (wallets.get(walletId)) {
                    case null {
                        wallets.put(walletId, { id = walletId; scores = newScores });
                    };
                    case (?wallet) {
                        let updatedScores = Array.append(
                            Array.filter(wallet.scores, func (score: Types.WalletScore) : Bool { 
                                score.validatorId != validatorId or not score.verified
                            }),
                            newScores
                        );
                        wallets.put(walletId, { id = walletId; scores = updatedScores });
                    };
                };

                #ok(totalScore)
            };
        };
    };

    public shared(msg) func verifySpecificCriteria(walletId: Types.WalletId, criteriaId: Types.CriteriaId, groupId: Text, validatorId: Text) : async Result.Result<Nat, Text> {
        switch (criterias.get(criteriaId)) {
            case null { #err("Criteria not found") };
            case (?criteria) {
                let result = await Provider.verifyCriteria(walletId, criteria);
                if (result.isValid) {
                    let now = Time.now();
                    let newScore : Types.WalletScore = {
                        validatorId = validatorId;
                        groupId = groupId;
                        criteriaId = criteriaId;
                        score = result.score;
                        verified = true;
                        verificationTime = now;
                        expirationTime = now + criteria.expirationTime;
                    };

                    // Update wallet scores
                    switch (wallets.get(walletId)) {
                        case null {
                            wallets.put(walletId, { id = walletId; scores = [newScore] });
                        };
                        case (?wallet) {
                            let updatedScores = Array.append(
                                Array.filter(wallet.scores, func (score: Types.WalletScore) : Bool { 
                                    score.criteriaId != criteriaId
                                }),
                                [newScore]
                            );
                            wallets.put(walletId, { id = walletId; scores = updatedScores });
                        };
                    };

                    #ok(result.score)
                } else {
                    #err("Verification failed")
                }
            };
        };
    };

    // Get current score of a Wallet for a specific Validator
    public query func getCurrentWalletScore(walletId: Types.WalletId, validatorId: Types.ValidatorId) : async Nat {
        var totalScore = 0;
        let now = Time.now();

        switch (wallets.get(walletId)) {
            case null { return 0 };
            case (?wallet) {
                for (score in wallet.scores.vals()) {
                    if (score.validatorId == validatorId and score.expirationTime > now) {
                        totalScore += score.score;
                    };
                };
            };
        };

        totalScore
    };

    // Get wallet score with ?validatorId
    public query func getWalletScore(walletId: Types.WalletId, validatorId: ?Types.ValidatorId) : async {
        totalScore: Nat;
        validScores: [Types.WalletScore];
        expiredScores: [Types.WalletScore];
    } {
        var totalScore = 0;
        var validScores : [Types.WalletScore] = [];
        var expiredScores : [Types.WalletScore] = [];
        let now = Time.now();

        switch (wallets.get(walletId)) {
            case null { { totalScore = 0; validScores = []; expiredScores = [] } };
            case (?wallet) {
                for (score in wallet.scores.vals()) {
                    if (validatorId == null or score.validatorId == Option.get(validatorId, "")) {
                        if (score.expirationTime > now and score.verified) {
                            totalScore += score.score;
                            validScores := Array.append(validScores, [score]);
                        } else if (score.verified) {
                            expiredScores := Array.append(expiredScores, [score]);
                        };
                    };
                };
                { totalScore = totalScore; validScores = validScores; expiredScores = expiredScores }
            };
        }
    };
    //Count total score of criterial in validators
    private func countTotalScore(validator: Types.Validator) : Nat {
        var totalScore = 0;
        for (groupId in validator.groups.vals()) {
            switch (groups.get(groupId)) {
                case null { /* Skip if group not found */ };
                case (?group) {
                    for (criteriaId in group.criterias.vals()) {
                        switch (criterias.get(criteriaId)) {
                            case null { /* Skip if criteria not found */ };
                            case (?criteria) {
                                totalScore += criteria.score;
                            };
                        };
                    };
                };
            };
        };
        totalScore
    };
    
    //List validators
    public query func getValidators() : async [(Types.ValidatorId, Types.ValidatorInfo)] {
        //Count total score of criterial in validators
        var validatorsWithScore: [(Types.ValidatorId, Types.ValidatorInfo)] = [];
        for (validator in validators.vals()) {
            var totalScore = countTotalScore(validator);
            var validatorInfo : Types.ValidatorInfo = {
                validator with
                totalScore = totalScore;
            };
            validatorsWithScore := Array.append(validatorsWithScore, [(validator.id, validatorInfo)]);
        };
        return validatorsWithScore;
    };
    //Get validator by Id
    public query func getValidatorById(validatorId: Types.ValidatorId) : async ?Types.ValidatorInfo {
        switch (validators.get(validatorId)) {
            case null { return null };
            case (?validator) {
                var validatorInfo : Types.ValidatorInfo = {
                    validator with
                    totalScore = countTotalScore(validator)
                };
                return ?validatorInfo;
            };
        };
    };
    
    //List groups
    public query func getGroups() : async [(Types.GroupId, Types.Group)] {
        Iter.toArray(groups.entries())
    };
    //List criterias
    public query func getCriterias() : async [(Types.CriteriaId, Types.Criteria)] {
        Iter.toArray(criterias.entries())
    };
    //List wallets
    public query func getWallets() : async [(Types.WalletId, Types.Wallet)] {
        Iter.toArray(wallets.entries())
    };

    //Update criteria
    public shared ({caller}) func updateCriteria(criteriaId: Types.CriteriaId, params: Types.ProviderParams, expirationTime: Int, autoVerify: Bool) : async Result.Result<Bool, Text> {
        assert(_isAdmin(Principal.toText(caller)));
        switch (criterias.get(criteriaId)) {
            case null { #err("Criteria not existed"); };
            case (?criteria) {
                let updatedCriteria = { 
                    criteria with
                    params = params; 
                    expirationTime = expirationTime; 
                    autoVerify = autoVerify 
                };
                criterias.put(criteriaId, updatedCriteria);
                #ok(true);
            };
        };
    };
    //Remove criteria
    public shared ({caller}) func removeCriteria(criteriaId: Types.CriteriaId) : async Result.Result<Bool, Text> {
        assert(_isAdmin(Principal.toText(caller)));
        switch (criterias.get(criteriaId)) {
            case null { #err("Criteria not existed"); };
            case (?_) {
                let _ = criterias.remove(criteriaId);
                for (group in groups.vals()) {
                    let updatedCriterias = Array.filter(group.criterias, func (id: Types.CriteriaId) : Bool { id != criteriaId });
                    groups.put(group.id, { group with criterias = updatedCriterias });
                };
                #ok(true);
            };
        };
    };

    //Utility function
    public shared ({caller}) func addAdmin(admin: Text) : async Result.Result<Bool, Text> {
        assert(_isAdmin(Principal.toText(caller)));
        _admins := Array.append(_admins, [admin]);
        #ok(true);
    };
    public shared ({caller}) func removeAdmin(admin: Text) : async Result.Result<Bool, Text> {
        assert(_isAdmin(Principal.toText(caller)));
        _admins := Array.filter(_admins, func (a: Text) : Bool { a != admin });
        #ok(true);
    };
    public query func getAdmins() : async [Text] {
        _admins
    };
};