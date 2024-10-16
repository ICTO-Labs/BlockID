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
import Blob "mo:base/Blob";
import Char "mo:base/Char";
import Int "mo:base/Int";
import Hash "mo:base/Hash";
import Float "mo:base/Float";
import Types "Types";
import Provider "Provider";
import Utils "Utils";

actor BlockID {

    //Store data
    private var validators = HashMap.HashMap<Text, Types.Validator>(0, Text.equal, Text.hash);
    private stable var _validators: [(Text, Types.Validator)] = [];
    private var wallets = HashMap.HashMap<Types.WalletId, Types.Wallet>(0, Principal.equal, Principal.hash);
    private stable var _wallets: [(Types.WalletId, Types.Wallet)] = [];
    private var applications = HashMap.HashMap<Text, Types.Application>(0, Text.equal, Text.hash);
    private stable var _applications: [(Text, Types.Application)] = [];
    private var providers = HashMap.HashMap<Text, Types.Provider>(0, Text.equal, Text.hash);
    private stable var _providers: [(Text, Types.Provider)] = [];
    private stable var _admins : [Text] = ["lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"];
    private stable var _vcCanisterId : [Text] = ["cpmcr-yeaaa-aaaaa-qaala-cai"];//Remote canister for VC validation

    //Params config
    private stable var LIMIT_APPLICATION_PER_USER : Nat = 10;
    private stable var LIMIT_VALIDATOR_PER_APPLICATION : Nat = 10;
    private var LAST_CLEANUP_PARAMS: Int = 0;
    private stable var CLEANUP_EXPIRED_PARAMS_INTERVAL : Int = 1000 * 60 * 60 * 24; // 1 day


    //Wallet link config
    private stable var MAX_LINKED_WALLETS : Nat = 1;
    private stable var REQUIRE_LINK_CONFIRMATION : Bool = true;

    private var walletLinks = HashMap.HashMap<Types.WalletId, Types.WalletLink>(0, Principal.equal, Principal.hash);
    private stable var _walletLinks : [(Types.WalletId, Types.WalletLink)] = [];
    private var pendingLinks = HashMap.HashMap<Types.WalletId, [Types.WalletId]>(0, Principal.equal, Principal.hash);
    private stable var _pendingLinks : [(Types.WalletId, [Types.WalletId])] = [];
    private var verificationParamsMap = HashMap.HashMap<Text, Types.VerificationParams>(0, Text.equal, Text.hash);
    private stable var _verificationParamsMap: [(Text, Types.VerificationParams)] = [];
    //ID generator
    private stable var nextValidatorId : Nat = 0;
    private stable var nextCriteriaId : Nat = 0;

    //Statistic
    private stable var TOTAL_VERIFIED_WALLETS : Nat = 0;
    private var scoreDistribution = HashMap.HashMap<Nat, Nat>(0, Nat.equal, Hash.hash);
    private stable var _scoreDistribution : [(Nat, Nat)] = [];

    //********************** System function **********************//
    system func preupgrade() {
        _validators := Iter.toArray(validators.entries());
        _wallets := Iter.toArray(wallets.entries());
        _applications := Iter.toArray(applications.entries());
        _providers := Iter.toArray(providers.entries());
        _walletLinks := Iter.toArray(walletLinks.entries());
        _pendingLinks := Iter.toArray(pendingLinks.entries());
        _verificationParamsMap := Iter.toArray(verificationParamsMap.entries());
        _scoreDistribution := Iter.toArray(scoreDistribution.entries());
    };
    system func postupgrade() {
        validators := HashMap.fromIter<Text, Types.Validator>(_validators.vals(), 0, Text.equal, Text.hash);
        wallets := HashMap.fromIter<Types.WalletId, Types.Wallet>(_wallets.vals(), 0, Principal.equal, Principal.hash);
        applications := HashMap.fromIter<Text, Types.Application>(_applications.vals(), 0, Text.equal, Text.hash);
        providers := HashMap.fromIter<Text, Types.Provider>(_providers.vals(), 0, Text.equal, Text.hash);
        walletLinks := HashMap.fromIter<Types.WalletId, Types.WalletLink>(_walletLinks.vals(), 0, Principal.equal, Principal.hash);
        pendingLinks := HashMap.fromIter<Types.WalletId, [Types.WalletId]>(_pendingLinks.vals(), 0, Principal.equal, Principal.hash);
        verificationParamsMap := HashMap.fromIter<Text, Types.VerificationParams>(_verificationParamsMap.vals(), 0, Text.equal, Text.hash);
        scoreDistribution := HashMap.fromIter(_scoreDistribution.vals(), 0, Nat.equal, Hash.hash);
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

    private func createParamsKey(criteriaId: Types.CriteriaId, params: ?[Types.ProviderParams]) : Text {
        let paramsString = switch (params) {
            case (null) { "NO_PARAMS" };
            case (?p) {
                if (Array.size(p) == 0) {
                    "NO_PARAMS"
                } else {
                    Array.foldLeft<Types.ProviderParams, Text>(p, "", func (acc, param) {
                        acc # param.key # ":" # Option.get(param.value, "") # ";"
                    })
                };
            };
        };
        criteriaId # "|" # paramsString
    };
    private func cleanupExpiredParams() {
        let now = Time.now();
        verificationParamsMap := HashMap.mapFilter<Text, Types.VerificationParams, Types.VerificationParams>(
            verificationParamsMap,
            Text.equal,
            Text.hash,
            func (_, params) {
                if (params.expirationTime > now) {
                    ?params
                } else {
                    null
                }
            }
        );
    };
    //Helper function
    private func _generateId(prefix : Text) : Text {
        switch (prefix) {
            case "validator" {
                let id = prefix # Nat.toText(nextValidatorId);
                nextValidatorId += 1;
                id
            };
            case "criteria" {
                let id = prefix # Nat.toText(nextCriteriaId);
                nextCriteriaId += 1;
                id
            };
            case _ {
                prefix
            };
        };
    };

    private func _getProvider(providerId: Text) : ?Types.Provider {
        switch (providers.get(providerId)) {
            case null { null };
            case (?template) { ?template };
        };
    };

    //Check if id is valid
    private func _isValidId(id: Text) : Bool {
        if (id.size() > 32) {
            return false;
        };
        if(id.size() < 3) {
            return false;
        };
        for (char in id.chars()) {
            if (not (Char.isAlphabetic(char) or Char.isDigit(char) or char == '-' or char == '_')) {
                return false;
            };
        };
        return true;
    };

    //Create custom provider template
    public shared(msg) func createProvider(provider: Types.Provider) : async Result.Result<(), Text> {
        if (not _isAdmin(Principal.toText(msg.caller))) {
            return #err("Not authorized");
        };
        switch (providers.get(provider.id)) {
            case null {
                providers.put(provider.id, { provider with owner = ?msg.caller });
                #ok(())
            };
            case (?_) { #err("Provider ID already exists") };
        };
    };

    public shared(msg) func updateProvider(providerId: Text, updatedProvider: Types.Provider) : async Result.Result<(), Text> {
        if (not _isAdmin(Principal.toText(msg.caller))) {
            return #err("Not authorized");
        };
        switch (providers.get(providerId)) {
            case null { #err("Provider not found") };
            case (?_provider) {
                if (not _isAdmin(Principal.toText(msg.caller))) {
                    return #err("Not authorized");
                };
                providers.put(providerId, updatedProvider);
                #ok(())
            };
        }
    };
    //Remove provider
    public shared(msg) func removeProvider(providerId: Text) : async Result.Result<(), Text> {
        if (not _isAdmin(Principal.toText(msg.caller))) {
            return #err("Not authorized");
        };
        switch (providers.get(providerId)) {
            case null { #err("Provider not found") };
            case (?_) {
                providers.delete(providerId);
                #ok(())
            };
        }
    };

    public query func getProviders() : async [(Text, Types.Provider)] {
        Iter.toArray(providers.entries())
    };

    //Count total score from all criterias by Validator
    private func _updateTotalValidatorScore(validatorId: Types.ValidatorId) : () {
        switch (validators.get(validatorId)) {
            case null { () };
            case (?validator) {
                var totalScore = 0;
                for (criteria in validator.criterias.vals()) {
                    totalScore += criteria.score;
                };
                validators.put(validatorId, { validator with totalScore = totalScore });
            };
        };
    };

    public shared(msg) func createCriteria(validatorId: Types.ValidatorId, criteria: Types.Criteria) : async Result.Result<(), Text> {
        switch (validators.get(validatorId)) {
            case null { #err("Validator not found") };
            case (?validator) {
                if (validator.owner != msg.caller and not _isAdmin(Principal.toText(msg.caller))) {
                    return #err("Not authorized");
                };
                let _newCriteria: Types.Criteria = { 
                    criteria with 
                    id = _generateId("criteria");
                };
                // criterias.put(_newCriteria.id, _newCriteria);
                let updatedCriterias: [Types.Criteria] = Array.append(validator.criterias, [_newCriteria]);
                validators.put(validatorId, { 
                    validator with  criterias = updatedCriterias;
                });
                _updateTotalValidatorScore(validatorId);
                #ok(())
            };
        }
    };

    public shared(msg) func updateCriteria(validatorId: Types.ValidatorId, criteriaId: Types.CriteriaId, updatedCriteria: Types.Criteria) : async Result.Result<(), Text> {
        switch (validators.get(validatorId)) {
            case null { #err("Validator not found") };
            case (?validator) {
                if (validator.owner != msg.caller and not _isAdmin(Principal.toText(msg.caller))) {
                    return #err("Not authorized");
                };
                let updatedCriterias = Array.map(validator.criterias, func (c: Types.Criteria) : Types.Criteria {
                    if (c.id == criteriaId) { updatedCriteria } else { c }
                });
                validators.put(validatorId, { validator with criterias = updatedCriterias });
                _updateTotalValidatorScore(validatorId);
                #ok(())
            };
        }
    };

    public shared(msg) func removeCriteria(validatorId: Types.ValidatorId, criteriaId: Types.CriteriaId) : async Result.Result<(), Text> {
        switch (validators.get(validatorId)) {
            case null { #err("Validator not found") };
            case (?validator) {
                if (validator.owner != msg.caller and not _isAdmin(Principal.toText(msg.caller))) {
                    return #err("Not authorized");
                };
                let updatedCriterias = Array.filter(validator.criterias, func (c: Types.Criteria) : Bool { c.id != criteriaId });
                validators.put(validatorId, { validator with criterias = updatedCriterias });
                _updateTotalValidatorScore(validatorId);
                #ok(())
            };
        }
    };

    //Remove validator from application
    private func _removeValidatorFromApplication(applicationId: Text, validatorId: Types.ValidatorId) : () {
        switch (applications.get(applicationId)) {
            case null { () };
            case (?app) {
                let updatedValidators = Array.filter(app.validators, func (id: Types.ValidatorId) : Bool { id != validatorId });
                applications.put(applicationId, { app with validators = updatedValidators });
            };
        };
    };

    //Update validator
    public shared(msg) func updateValidator(validatorId: Types.ValidatorId, updatedValidator: Types.UpdateValidator) : async Result.Result<(), Text> {
        switch (validators.get(validatorId)) {
            case null { #err("Validator not found") };
            case (?validator) {
                if (validator.owner != msg.caller and not _isAdmin(Principal.toText(msg.caller))) {
                    return #err("Not authorized");
                };
                validators.put(validatorId, { 
                    validator with 
                    applicationId = updatedValidator.applicationId;
                    name = updatedValidator.name;
                    logo = updatedValidator.logo;
                    description = updatedValidator.description;
                });
                #ok(())
            };
        }
    };

    //Remove validator
    public shared(msg) func removeValidator(validatorId: Types.ValidatorId) : async Result.Result<(), Text> {
        switch (validators.get(validatorId)) {
            case null { #err("Validator not found") };
            case (?validator) {
                if (validator.owner != msg.caller and not _isAdmin(Principal.toText(msg.caller))) {
                    return #err("Not authorized");
                };
                validators.delete(validatorId);
                _removeValidatorFromApplication(validator.applicationId, validatorId);//Remove id from application
                #ok(())
            };
        }
    };

    //Remove application
    public shared(msg) func removeApplication(applicationId: Text) : async Result.Result<(), Text> {
        switch (applications.get(applicationId)) {
            case null { #err("Application not found") };
            case (?app) {
                if (app.owner != msg.caller and not _isAdmin(Principal.toText(msg.caller))) {
                    return #err("Not authorized");
                };
                applications.delete(applicationId);
                //Remove all validators of this application
                for (validator in app.validators.vals()) {
                    validators.delete(validator);
                };
                #ok(())
            };
        };
    };

    //Verify wallet scrore from remote canister
    private func _verifyFromVC({
        application_id: Text;
        validator_id: Text;
        criterial_id: Text;
        wallet_id: Text;
    }) : async Result.Result<Bool, Text> {
        let walletId = Principal.fromText(wallet_id);
        
        switch (applications.get(application_id), validators.get(validator_id)) {
            case (null, _) { return #err("Application not found") };
            case (_, null) { return #err("Validator not found") };
            case (?_, ?validator) {
                let criteria = Array.find(validator.criterias, func (c: Types.Criteria) : Bool { 
                    c.id == criterial_id and c.isVC == true 
                });
                
                switch (criteria) {
                    case null { return #err("Criteria not found") };
                    case (?vcCriteria) {
                        let now = Time.now();
                        let criteriaScore = {
                            criteriaId = vcCriteria.id;
                            score = vcCriteria.score;
                            verified = true;
                            verificationTime = ?now;
                            expirationTime = ?calculateExpirationTime(vcCriteria.expirationTime);
                        };
                        
                        // Update wallet score
                        updateWalletScore(walletId, application_id, validator_id, [criteriaScore]);
                        
                        return #ok(true);
                    };
                };
            };
        };
    };

    // Calculate expiration time
    private func calculateExpirationTime(expirationTimeInSeconds: Int) : Int {
        let now = Time.now();
        if (expirationTimeInSeconds == 0) {
            // Set expiration time to 30 years from now
            now + 30 * 365 * 24 * 60 * 60 * 1_000_000_000
        } else {
            now + expirationTimeInSeconds * 1_000_000_000 // Convert seconds to nanoseconds
        }
    };
    //Verify single criteria
    private func _verifySingleCriteria(walletId: Types.WalletId, criteria: Types.Criteria, provider: Types.Provider, params: ?[Types.ProviderParams]) : async Types.CriteriaScore {
        let now = Time.now();
        let _defaultScore = {
            criteriaId = criteria.id;
            score = 0;
            verified = false;
            verificationTime = null;
            expirationTime = null;
        };

        // Cleanup expired params
        if(now > LAST_CLEANUP_PARAMS + CLEANUP_EXPIRED_PARAMS_INTERVAL){
            cleanupExpiredParams();
            LAST_CLEANUP_PARAMS := now;
        };
        // Check if we need to process params
        let shouldProcessParams = switch (params) {
            case (null) { false };
            case (?p) { Array.size(p) > 0 };
        };

        // Process params if needed
        if (shouldProcessParams) {
            let paramsKey = createParamsKey(criteria.id, params);
            if (paramsKey != criteria.id # "|NO_PARAMS") {
                switch (verificationParamsMap.get(paramsKey)) {
                    case (?existingParams) {
                    if (existingParams.walletId != walletId and existingParams.expirationTime > now) {
                        return _defaultScore; // Params already used for another wallet and not expired
                    };
                };
                    case (null) { };
                };
            }
        };
        // Verify criteria
        if (criteria.isVC == false and provider.id != "-") {
            let result = await Provider.verifyCriteria(walletId, criteria, provider, params);
            if (result.isValid) {
                let score = {
                    criteriaId = criteria.id;
                    score = result.score;
                    verified = result.isValid;
                    verificationTime = ?now;
                    expirationTime = ?calculateExpirationTime(criteria.expirationTime);
                };

                // Save params info if needed
                if (shouldProcessParams) {
                    let paramsKey = createParamsKey(criteria.id, params);
                    if (paramsKey != criteria.id # "|NO_PARAMS") {
                        let expirationTime = calculateExpirationTime(criteria.expirationTime);
                        let newParams : Types.VerificationParams = {
                            walletId = walletId;
                            criteriaId = criteria.id;
                            params = Option.get(params, []);
                            verificationTime = now;
                            expirationTime = expirationTime;
                        };
                        verificationParamsMap.put(paramsKey, newParams);
                    };
                };

                return score;
            };
        };

        return _defaultScore;
    };

    //Update wallet score
    private func updateWalletScore(walletId: Types.WalletId, applicationId: Text, validatorId: Types.ValidatorId, newCriteriaScores: [Types.CriteriaScore]) : () {
    let wallet = switch (wallets.get(walletId)) {
        case null {
            {
                id = walletId;
                applicationScores = [];
            }
        };
        case (?w) { w };
    };

    let updatedApplicationScores = switch (Array.find(wallet.applicationScores, func (as: Types.ApplicationScore) : Bool { as.applicationId == applicationId })) {
        case null {
            Array.append(wallet.applicationScores, [{
                applicationId = applicationId;
                validatorScores = [{
                    validatorId = validatorId;
                    criteriaScores = newCriteriaScores;
                    totalScore = Array.foldLeft<Types.CriteriaScore, Nat>(newCriteriaScores, 0, func (acc, cs) { acc + cs.score });
                    lastVerificationTime = Time.now();
                    expirationTime = Time.now() + 365 * 24 * 60 * 60 * 1000000000; // 1 year in nanoseconds
                }];
            }])
        };
        case (?appScore) {
            Array.map(wallet.applicationScores, func (as: Types.ApplicationScore) : Types.ApplicationScore {
                if (as.applicationId == applicationId) {
                    let updatedValidatorScores = switch (Array.find(as.validatorScores, func (vs: Types.WalletScore) : Bool { vs.validatorId == validatorId })) {
                        case null {
                            Array.append(as.validatorScores, [{
                                validatorId = validatorId;
                                criteriaScores = newCriteriaScores;
                                totalScore = Array.foldLeft<Types.CriteriaScore, Nat>(newCriteriaScores, 0, func (acc, cs) { acc + cs.score });
                                lastVerificationTime = Time.now();
                                expirationTime = Time.now() + 365 * 24 * 60 * 60 * 1000000000; // 1 year in nanoseconds
                            }])
                        };
                        case (?existingValidatorScore) {
                            Array.map(as.validatorScores, func (vs: Types.WalletScore) : Types.WalletScore {
                                if (vs.validatorId == validatorId) {
                                    let updatedCriteriaScores = Array.map(vs.criteriaScores, func (cs: Types.CriteriaScore) : Types.CriteriaScore {
                                        switch (Array.find(newCriteriaScores, func (ncs: Types.CriteriaScore) : Bool { ncs.criteriaId == cs.criteriaId })) {
                                            case null { cs };
                                            case (?newScore) { newScore };
                                        }
                                    });
                                    let mergedCriteriaScores = Array.append(
                                        updatedCriteriaScores,
                                        Array.filter(newCriteriaScores, func (ncs: Types.CriteriaScore) : Bool {
                                            Option.isNull(Array.find(vs.criteriaScores, func (cs: Types.CriteriaScore) : Bool { cs.criteriaId == ncs.criteriaId }))
                                        })
                                    );
                                    {
                                        validatorId = vs.validatorId;
                                        criteriaScores = mergedCriteriaScores;
                                        totalScore = Array.foldLeft<Types.CriteriaScore, Nat>(mergedCriteriaScores, 0, func (acc, cs) { acc + cs.score });
                                        lastVerificationTime = Time.now();
                                        expirationTime = Time.now() + 365 * 24 * 60 * 60 * 1000000000; // 1 year in nanoseconds
                                    }
                                } else {
                                    vs
                                }
                            })
                        };
                    };
                    {
                        applicationId = as.applicationId;
                        validatorScores = updatedValidatorScores;
                    }
                } else {
                    as
                }
            })
        };
    };
    wallets.put(walletId, { wallet with applicationScores = updatedApplicationScores });
};

    //Verify wallet with criteria
    private func _verifyWalletByCriteria(applicationId: Text, validatorId: Types.ValidatorId, criteriaIds: [Types.CriteriaId], walletId: Types.WalletId, params: ?[Types.ProviderParams]) : async Result.Result<Nat, Text> {
        switch (applications.get(applicationId), validators.get(validatorId)) {
            case (null, _) { #err("Application not found") };
            case (_, null) { #err("Validator not found") };
            case (?_, ?validator) {
                var criteriaScores : [Types.CriteriaScore] = [];
                for (criteriaId in criteriaIds.vals()) {
                    switch (Array.find(validator.criterias, func (c: Types.Criteria) : Bool { c.id == criteriaId })) {
                        case null { /* Skip if criteria not found */ };
                        case (?criteria) {
                            //Check provider, skip if not exist
                            let provider = switch (providers.get(Option.get(criteria.providerId, "-"))) {
                                case null { {
                                    id = "-";
                                    name = "";
                                    description = "";
                                    moduleType = #Custom;
                                    owner = null;
                                    params = [];
                                } };
                                case (?p) { p };
                            };
                            let criteriaScore = await _verifySingleCriteria(walletId, criteria, provider, params);
                            //Only add verified criteria
                            if(criteriaScore.verified == true and criteriaScore.score > 0){
                                criteriaScores := Array.append(criteriaScores, [criteriaScore]);
                                await* updateVerificationStats(walletId, applicationId, criteriaScore.score);
                            };
                        };
                    };
                };

                updateWalletScore(walletId, applicationId, validatorId, criteriaScores);
                let totalScore = Array.foldLeft<Types.CriteriaScore, Nat>(criteriaScores, 0, func (acc, cs) { acc + cs.score });
                #ok(totalScore)
            };
        }
    };

    //Public verify by criterial
    public shared({caller}) func verifyWalletByCriteria(applicationId: Text, validatorId: Types.ValidatorId, criteriaIds: [Types.CriteriaId], params: ?[Types.ProviderParams]) : async Result.Result<Nat, Text> {
        await _verifyWalletByCriteria(applicationId, validatorId, criteriaIds, caller, params)
    };

    // Verify all criteria of a validator
    public shared({caller}) func verifyWalletByValidator(applicationId: Text, validatorId: Types.ValidatorId) : async Result.Result<Nat, Text> {
        switch (applications.get(applicationId), validators.get(validatorId)) {
            case (null, _) { #err("Application not found") };
            case (_, null) { #err("Validator not found") };
            case (?_, ?validator) {
                let criteriaIds = Array.map<Types.Criteria, Types.CriteriaId>(validator.criterias, func (c) { c.id });
                await _verifyWalletByCriteria(applicationId, validatorId, criteriaIds, caller, null)
            };
        }
    };


    //Get verified criteria by validator, return list criteria id with score
    public query func getVerifiedCriteria(applicationId: Types.ApplicationId, validatorId: Types.ValidatorId, walletId: Types.WalletId) : async [(Types.CriteriaId, Nat)] {
        switch (wallets.get(walletId)) {
            case null { return [] };
            case (?wallet) {
                var verifiedCriteria : [(Types.CriteriaId, Nat)] = [];
                for (score in wallet.applicationScores.vals()) {
                    if (score.applicationId == applicationId) {
                        for (validatorScore in score.validatorScores.vals()) {
                            if (validatorScore.validatorId == validatorId) {    
                                for (criteriaScore in validatorScore.criteriaScores.vals()) {
                                    if (criteriaScore.verified == true) {
                                        verifiedCriteria := Array.append(verifiedCriteria, [(criteriaScore.criteriaId, criteriaScore.score)]);
                                    };
                                };
                            };
                        };
                    };
                };
                verifiedCriteria;
            };
        };
    };

    //Get wallet score
    private func _getWalletScore(walletId: Types.WalletId, applicationId: Text) : Nat {
        var walletScore = 0;
        let now = Time.now();
        switch (wallets.get(walletId)) {
            case null { };
            case (?wallet) {
                for (score in wallet.applicationScores.vals()) {
                    if (score.applicationId == applicationId) {
                        for (validatorScore in score.validatorScores.vals()) {
                            if (validatorScore.expirationTime > now) {
                                walletScore += validatorScore.totalScore;
                            };
                        };
                    };
                };
            };
        };
        walletScore
    };

    //Get wallet score
    public query func getWalletScore(walletId: Types.WalletId, applicationId: Text) : async {
        primaryScore: Nat;
        linkedScore: Nat;
        totalScore: Nat;
        percentileAbove: Float;
        linkedWallet: ?(Types.WalletId, Nat);
    } {
        var primaryScore = 0;
        var linkedScore = 0;
        var linkedWallet : ?(Types.WalletId, Nat) = null;
        var totalScore = 0;
        // Get the wallet score
        primaryScore := _getWalletScore(walletId, applicationId);
        totalScore := primaryScore;

        // Check if this wallet is linked to any wallet
        switch (walletLinks.get(walletId)) {
            case null { };
            case (?link) {
                if (link.primaryWallet == walletId) {
                    // This wallet is a primary wallet, calculate score from secondary
                    let secondaryScore = _getWalletScore(link.secondaryWallet, applicationId);
                    linkedWallet := ?(link.secondaryWallet, secondaryScore);
                    totalScore += secondaryScore;
                    linkedScore := secondaryScore;
                } else {
                    // This wallet is a secondary wallet, just show the primary wallet info
                    linkedWallet := ?(link.primaryWallet, _getWalletScore(link.primaryWallet, applicationId));
                };
            };
        };
        let percentileAbove = _getPercentileAbove(totalScore);
        { primaryScore = primaryScore; linkedScore = linkedScore; totalScore = totalScore; linkedWallet = linkedWallet; percentileAbove = percentileAbove }
    };

    //Check limit application per user
    private func _checkLimitApplication(caller: Principal) : Bool {
        let myApplications = Array.filter(Iter.toArray(applications.entries()), func (entry: (Text, Types.Application)) : Bool {
            let (_, app) = entry;
            app.owner == caller
        });
        Nat.lessOrEqual(Array.size(myApplications), LIMIT_APPLICATION_PER_USER)
    };

    //Create new application
    public shared(msg) func createApplication(app: Types.Application) : async Result.Result<(), Text> {
        let _validId = _isValidId(app.id);
        if(app.id == "" or _validId == false){
            return #err("Invalid application ID: Min 3 chars, Max: 32 chars and only alphanumeric characters, include - and _ characters");
        };
        if (not _checkLimitApplication(msg.caller)) {
            return #err("Limit application per user is reached, current limit: " # Nat.toText(LIMIT_APPLICATION_PER_USER));
        };
        switch (applications.get(app.id)) {
            case null {
                applications.put(app.id, { app with owner = msg.caller });
                return #ok(());
            };
            case (?_) { return #err("Application ID already exists") };
        };
    };

    public shared(msg) func updateApplication(app: Types.Application) : async Result.Result<(), Text> {
        switch (applications.get(app.id)) {
            case null { #err("Application not found") };
            case (?a) {
                if (a.owner != msg.caller and not _isAdmin(Principal.toText(msg.caller))) {
                    return #err("Not authorized");
                };
                applications.put(app.id, app);
                return #ok(());
            };
        };
    };

    //Check if canisterId is a vcCanisterId
    private func _isVcCanisterId(canisterId: Text) : Bool {
        for (id in _vcCanisterId.vals()) {
            if (id == canisterId) {
                return true;
            };
        };
        return false;
    };

    //Validate VC: Caller must be a vcCanisterId
    public shared(msg) func validateVC(
        criterial_id: Text,
        validator_id: Text,
        application_id: Text,
        wallet_id: Text
        ) : async Types.ValidateResponse {
        let canisterId = Principal.toText(msg.caller);
        if (not _isVcCanisterId(canisterId)) {
            return #Err("Not authorized");
        };
        //TODO: Implement VC validation
        let result = await _verifyFromVC({
            criterial_id = criterial_id;
            validator_id = validator_id;
            application_id = application_id;
            wallet_id = wallet_id;
        });
        switch (result) {
            case (#ok(true)) { #Ok(true) };
            case (#ok(false)) { #Ok(false) };
            case (#err(err)) { #Err(err) };
        };
    };

    //Add/remove vcCanisterId
    public shared(msg) func addVcCanisterId(canisterId: Text) : async Result.Result<(), Text> {
        if (not _isAdmin(Principal.toText(msg.caller))) {
            return #err("Not authorized");
        };
        if (Array.indexOf(canisterId, _vcCanisterId, Text.equal) != null) {
            return #err("Canister ID already exists");
        };
        //Check if principal valid
        try{
            let _p = Principal.fromText(canisterId);
            _vcCanisterId := Array.append(_vcCanisterId, [canisterId]);
            return #ok(());
        }catch(_e){
            return #err("Input canister ID is not a principal");
        };
    };

    public shared(msg) func removeVcCanisterId(canisterId: Text) : async Result.Result<(), Text> {
        if (not _isAdmin(Principal.toText(msg.caller))) {
            return #err("Not authorized");
        };
        _vcCanisterId := Array.filter(_vcCanisterId, func (id: Text) : Bool { id != canisterId });
        return #ok(());
    };

    //Get all vcCanisterId
    public query func getVcCanisterId() : async [Text] {
        _vcCanisterId
    };

    private func _createValidator(validator: Types.CreateValidator, owner: Principal) : async Result.Result<Types.Validator, Text> {
        //Check exist validator
        let _validatorId = _generateId("validator");
        switch (validators.get(_validatorId)) {
            case null {
                let _newValidator = { 
                    id = _validatorId; 
                    applicationId = validator.applicationId; 
                    name = validator.name; 
                    logo = validator.logo; 
                    description = validator.description; 
                    criterias = []; 
                    owner = owner; 
                    totalScore=0
                };
                validators.put(_newValidator.id, _newValidator);
                return #ok(_newValidator);
            };
            case (?v) { return #err("Validator ID already exists: " # _validatorId) };
        };
    };

    //Check limit validator per application
    private func _checkLimitValidator(caller: Principal) : Bool {
        let myValidators = Array.filter(Iter.toArray(validators.entries()), func (entry: (Types.ValidatorId, Types.Validator)) : Bool {
            let (_, validator) = entry;
            validator.owner == caller
        });
        Nat.lessOrEqual(Array.size(myValidators), LIMIT_VALIDATOR_PER_APPLICATION)
    };
    
    public shared(msg) func createValidator(appId: Text, validator: Types.CreateValidator) : async Result.Result<Types.Validator, Text> {
        //Create new validator and add to application
        if (not _checkLimitValidator(msg.caller)) {
            return #err("Limit validator per application is reached, current limit: " # Nat.toText(LIMIT_VALIDATOR_PER_APPLICATION));
        };
        let result = await _createValidator(validator, msg.caller);
        switch (result) {
            case (#err(err)) { return #err(err) };
            case (#ok(validator)) {
                switch (applications.get(appId)) {
                    case null { #err("Application not found") };
                    case (?app) {
                        if (app.owner != msg.caller and not _isAdmin(Principal.toText(msg.caller))) {
                            return #err("Not authorized");
                        };
                        //Check exist validator
                        let existValidator = Array.find(app.validators, func (id: Types.ValidatorId) : Bool { id == validator.id });
                        if (existValidator != null) {
                            return #err("Validator ID already exists");
                        }else{
                            let updatedValidators = Array.append(app.validators, [validator.id]);
                            applications.put(appId, { app with validators = updatedValidators });
                            return #ok(validator);
                        };
                    };
                };
            };
        };
    };

    //Get only my applications
    public query ({caller}) func getApplications() : async [(Text, Types.Application)] {
        if(_isAdmin(Principal.toText(caller))){
            return Iter.toArray(applications.entries());
        }else{
            let myApplications = Array.filter(Iter.toArray(applications.entries()), func (entry: (Text, Types.Application)) : Bool {
                let (_, app) = entry;
                app.owner == caller
            });
            return myApplications;
        };
    };

    //Get application info
    public query func getApplication(appId: Text) : async Result.Result<Types.Application, Text> {
        switch (applications.get(appId)) {
            case null { #err("Application not found") };
            case (?app) { #ok(app) };
        };
    };

    //Get validators by application
    public query func getValidators(appId: Text) : async [(Types.ValidatorId, Types.Validator)] {
        let validatorsArray = Iter.toArray(validators.entries());
        let appValidators = Array.filter(validatorsArray, func (entry: (Types.ValidatorId, Types.Validator)) : Bool {
            let (_, validator) = entry;
            Text.equal(appId, validator.applicationId)
        });
        appValidators;
    };

    //Get validator detail
    public query func getValidator(validatorId: Types.ValidatorId) : async Result.Result<Types.Validator, Text> {
        switch (validators.get(validatorId)) {
            case null { #err("Validator not found") };
            case (?validator) {
                #ok(validator)
            };
        };
    };

    public query func getWallets() : async [(Types.WalletId, Types.Wallet)] {
        Iter.toArray(wallets.entries())
    };
    public query func getAdmins() : async [Text] {
        _admins
    };
    //Add admin
    public shared(msg) func addAdmin(admin: Text) : async Result.Result<(), Text> {
        if (not _isAdmin(Principal.toText(msg.caller))) {
            return #err("Not authorized");
        };
        _admins := Array.append(_admins, [admin]);
        return #ok(());
    };
    //Remove admin
    public shared(msg) func removeAdmin(admin: Text) : async Result.Result<(), Text> {
        if (not _isAdmin(Principal.toText(msg.caller))) {
            return #err("Not authorized");
        };
        _admins := Array.filter(_admins, func (a: Text) : Bool { a != admin });
        return #ok(());
    };

    //################### Wallet link ###########################################################
    private func countActiveLinks(walletId: Types.WalletId) : Nat {
        switch (walletLinks.get(walletId)) {
            case null { 0 };
            case (?_) { 1 }; // If there is one link in walletLinks, it is an active link
        };
    };
    //Request link wallet from primary wallet
    public shared({caller}) func requestLinkWallet(secondaryWalletId: Types.WalletId) : async Result.Result<(), Text> {
        //Prevent anonymous user
        if(Principal.isAnonymous(caller) == true){
            return #err("Please login to your wallet");
        };
        let primaryWalletId = caller;

        if (Principal.equal(primaryWalletId, secondaryWalletId)) {
            return #err("Cannot link a wallet to itself");
        };

        if (countActiveLinks(primaryWalletId) >= MAX_LINKED_WALLETS) {
            return #err("Maximum number of linked wallets reached for the primary wallet");
        };

        switch (walletLinks.get(primaryWalletId), walletLinks.get(secondaryWalletId)) {
            case (?_, _) { return #err("Primary wallet is already linked") };
            case (_, ?_) { return #err("Secondary wallet is already linked") };
            case (null, null) {
                // Add new request to pendingLinks
                switch (pendingLinks.get(secondaryWalletId)) {
                    case null { pendingLinks.put(secondaryWalletId, [primaryWalletId]) };
                    case (?existingRequests) {
                        pendingLinks.put(secondaryWalletId, Array.append(existingRequests, [primaryWalletId]));
                    };
                };
                #ok()
            };
        };
    };

    //Accept link wallet from secondary wallet
    public shared({caller}) func acceptLinkWallet(primaryWalletId: Types.WalletId) : async Result.Result<(), Text> {
        let secondaryWalletId = caller;
        
        switch (pendingLinks.get(secondaryWalletId)) {
            case null { return #err("No pending link request") };
            case (?requests) {
                switch (Array.find(requests, func (id: Types.WalletId) : Bool { id == primaryWalletId })) {
                    case null { return #err("No link request from this wallet") };
                    case (?_) {
                        if (countActiveLinks(primaryWalletId) >= MAX_LINKED_WALLETS or 
                            countActiveLinks(secondaryWalletId) >= MAX_LINKED_WALLETS) {
                            pendingLinks.delete(secondaryWalletId);
                            return #err("Maximum number of linked wallets reached for one of the wallets");
                        };
                        
                        let now = Time.now();
                        let newLink : Types.WalletLink = {
                            primaryWallet = primaryWalletId;
                            secondaryWallet = secondaryWalletId;
                            creationTime = now;
                        };
                        walletLinks.put(primaryWalletId, newLink);
                        
                        // Remove the accepted link request
                        let updatedRequests = Array.filter(requests, func (id: Types.WalletId) : Bool { id != primaryWalletId });
                        if (Array.size(updatedRequests) == 0) {
                            pendingLinks.delete(secondaryWalletId);
                        } else {
                            pendingLinks.put(secondaryWalletId, updatedRequests);
                        };
                        #ok()
                    };
                };
            };
        };
    };

    //Reject link wallet
    public shared({caller}) func rejectLinkWallet(primaryWalletId: Types.WalletId) : async Result.Result<(), Text> {
        let secondaryWalletId = caller;

        switch (pendingLinks.get(secondaryWalletId)) {
            case null { return #err("There is no pending link request") };
            case (?requests) {
                let updatedRequests = Array.filter(requests, func (id: Types.WalletId) : Bool { id != primaryWalletId });
                if (Array.size(updatedRequests) == 0) {
                    pendingLinks.delete(secondaryWalletId);
                } else {
                    pendingLinks.put(secondaryWalletId, updatedRequests);
                };
                #ok()
            };
        };
    };

    //Unlink wallet
    public shared(msg) func unlinkWallet(linkedWalletId: Types.WalletId) : async Result.Result<(), Text> {
        let callerWalletId = msg.caller;

        switch (walletLinks.get(callerWalletId)) {
            case null {
                // Check if the caller is a secondary wallet
                switch (walletLinks.get(linkedWalletId)) {
                    case null { return #err("No link found between the wallets") };
                    case (?link) {
                        if (link.secondaryWallet == callerWalletId) {
                            walletLinks.delete(linkedWalletId);
                            return #ok();
                        } else {
                            return #err("Caller is not authorized to unlink this wallet");
                        };
                    };
                };
            };
            case (?link) {
                // Caller is a primary wallet
                if (link.secondaryWallet == linkedWalletId) {
                    walletLinks.delete(callerWalletId);
                    return #ok();
                } else {
                    return #err("The specified wallet is not linked to the caller");
                };
            };
        };
    };

    //Get pending link requests
    public query({caller}) func getPendingLinkRequests() : async [Types.WalletId] {
        switch (pendingLinks.get(caller)) {
            case null { [] };
            case (?requests) { requests };
        };
    };

    //Get my linked wallets
    public shared({caller}) func getMyLinkedWallets() : async [{
        linkedWallet: Types.WalletId;
        isPrimary: Bool;
        creationTime: Int;
    }] {
        var result : [{
            linkedWallet: Types.WalletId;
            isPrimary: Bool;
            creationTime: Int;
        }] = [];

        for ((walletId, link) in walletLinks.entries()) {
            if (link.primaryWallet == caller) {
                result := Array.append(result, [{
                    linkedWallet = link.secondaryWallet;
                    isPrimary = true;
                    creationTime = link.creationTime;
                }]);
            } else if (link.secondaryWallet == caller) {
                result := Array.append(result, [{
                    linkedWallet = link.primaryWallet;
                    isPrimary = false;
                    creationTime = link.creationTime;
                }]);
            };
        };

        result
    };

    //Show all linked wallets
    public query func getAllLinkedWallets() : async [(Types.WalletId, Types.WalletLink)] {
        Iter.toArray(walletLinks.entries())
    };

    //Test: Get neuron ids
    public shared func getNeuronIds() : async [Nat64] {
        return await Provider.getNeuronIds();
    };

    //Show all verification params
    public query func getAllVerificationParams() : async [(Text, Types.VerificationParams)] {
        Iter.toArray(verificationParamsMap.entries())
    };

    private func updateVerificationStats(walletId: Types.WalletId, applicationId: Text, newScore: Nat): async* (){
        let walletScore = await getWalletScore(walletId, applicationId); // Get old score
        let oldScore = walletScore.totalScore;//include linked wallet
        if (oldScore != newScore) {
            // Update total verified wallets if this is a new wallet
            if (oldScore == 0) {
                TOTAL_VERIFIED_WALLETS += 1;
            };
            // Update score distribution
            if (oldScore > 0) {
                let oldCount = Option.get(scoreDistribution.get(oldScore), 0);
                if (oldCount > 1) {
                    scoreDistribution.put(oldScore, oldCount - 1);
                } else {
                    scoreDistribution.delete(oldScore);
                };
            };
            
            let newCount = Option.get(scoreDistribution.get(newScore), 0);
            scoreDistribution.put(newScore, newCount + 1);
        }
    };

    //Get percentile above
    private func _getPercentileAbove(score: Nat) : Float {
        var walletsWithLowerScore = 0;
        var totalWallets = 0;

        for ((s, count) in scoreDistribution.entries()) {
            if (s < score) {
                walletsWithLowerScore += count;
            };
            totalWallets += count;
        };

        if (totalWallets == 0) {
            return 100.0; // If not have any wallets, return 100%
        };

        // Calculate percentage
        let percentageLower = Float.fromInt(walletsWithLowerScore) / Float.fromInt(totalWallets) * 100.0;

        // Round to 2 decimal places
        Float.nearest(percentageLower * 100) / 100
    };

    // //get scoreDistribution
    // public query func getScoreDistribution() : async [(Nat, Nat)] {
    //     Iter.toArray(scoreDistribution.entries())
    // };
    public query func getTotalVerifiedWallets() : async Nat {
        TOTAL_VERIFIED_WALLETS
    };
    //set totalVerifiedWallets
    public shared(msg) func setTotalVerifiedWallets(total: Nat) : async () {
        if (_isAdmin(Principal.toText(msg.caller))) {
            TOTAL_VERIFIED_WALLETS := total;
        };
    };
}