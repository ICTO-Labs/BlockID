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

import Types "Types";
import Provider "Provider";

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

    //ID generator
    private stable var nextValidatorId : Nat = 0;
    private stable var nextCriteriaId : Nat = 0;

    //********************** System function **********************//
    system func preupgrade() {
        _validators := Iter.toArray(validators.entries());
        _wallets := Iter.toArray(wallets.entries());
        _applications := Iter.toArray(applications.entries());
        _providers := Iter.toArray(providers.entries());
    };
    system func postupgrade() {
        validators := HashMap.fromIter<Text, Types.Validator>(_validators.vals(), 0, Text.equal, Text.hash);
        wallets := HashMap.fromIter<Types.WalletId, Types.Wallet>(_wallets.vals(), 0, Principal.equal, Principal.hash);
        applications := HashMap.fromIter<Text, Types.Application>(_applications.vals(), 0, Text.equal, Text.hash);
        providers := HashMap.fromIter<Text, Types.Provider>(_providers.vals(), 0, Text.equal, Text.hash);
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
                        };
                        
                        // Update wallet score
                        updateWalletScore(walletId, application_id, validator_id, [criteriaScore]);
                        
                        return #ok(true);
                    };
                };
            };
        };
    };

    //Verify single criteria
    private func _verifySingleCriteria(walletId: Types.WalletId, criteria: Types.Criteria, provider: Types.Provider) : async Types.CriteriaScore {
        let now = Time.now();
        if (criteria.isVC == false and provider.id != "") {
            let result = await Provider.verifyCriteria(walletId, criteria, provider);
            {
                criteriaId = criteria.id;
                score = if (result.isValid) criteria.score else 0;
                verified = result.isValid;
                verificationTime = ?now;
            }
        } else {
            {
                criteriaId = criteria.id;
                score = 0;
                verified = false;
                verificationTime = null;
            }
        }
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

        let totalScore = Array.foldLeft<Types.CriteriaScore, Nat>(newCriteriaScores, 0, func (acc, cs) { acc + cs.score });
        
        let newWalletScore : Types.WalletScore = {
            validatorId = validatorId;
            criteriaScores = newCriteriaScores;
            totalScore = totalScore;
            lastVerificationTime = Time.now();
            expirationTime = Time.now() + 365 * 24 * 60 * 60 * 1000000000; // 1 year in nanoseconds
        };

        let updatedApplicationScores = switch (Array.find(wallet.applicationScores, func (as: Types.ApplicationScore) : Bool { as.applicationId == applicationId })) {
            case null {
                Array.append(wallet.applicationScores, [{
                    applicationId = applicationId;
                    validatorScores = [newWalletScore];
                }])
            };
            case (?_appScore) {
                Array.map(wallet.applicationScores, func (as: Types.ApplicationScore) : Types.ApplicationScore {
                    if (as.applicationId == applicationId) {
                        {
                            applicationId = as.applicationId;
                            validatorScores = Array.append(
                                Array.filter(as.validatorScores, func (vs: Types.WalletScore) : Bool { vs.validatorId != validatorId }),
                                [newWalletScore]
                            )
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
    private func _verifyWalletByCriteria(applicationId: Text, validatorId: Types.ValidatorId, criteriaIds: [Types.CriteriaId], walletId: Types.WalletId) : async Result.Result<Nat, Text> {
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
                            let provider = switch (providers.get(Option.get(criteria.providerId, ""))) {
                                case null { {
                                    id = "";
                                    name = "";
                                    description = "";
                                    moduleType = #Custom;
                                    owner = null;
                                    params = [];
                                } };
                                case (?p) { p };
                            };
                            let criteriaScore = await _verifySingleCriteria(walletId, criteria, provider);
                            criteriaScores := Array.append(criteriaScores, [criteriaScore]);
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
    public shared({caller}) func verifyWalletByCriteria(applicationId: Text, validatorId: Types.ValidatorId, criteriaIds: [Types.CriteriaId]) : async Result.Result<Nat, Text> {
        await _verifyWalletByCriteria(applicationId, validatorId, criteriaIds, caller)
    };

    // Verify all criteria of a validator
    public shared({caller}) func verifyWalletByValidator(applicationId: Text, validatorId: Types.ValidatorId) : async Result.Result<Nat, Text> {
        switch (applications.get(applicationId), validators.get(validatorId)) {
            case (null, _) { #err("Application not found") };
            case (_, null) { #err("Validator not found") };
            case (?_, ?validator) {
                let criteriaIds = Array.map<Types.Criteria, Types.CriteriaId>(validator.criterias, func (c) { c.id });
                await _verifyWalletByCriteria(applicationId, validatorId, criteriaIds, caller)
            };
        }
    };

    //Get current wallet score
    public query func getCurrentWalletScore(walletId: Types.WalletId, applicationId: Text) : async Nat {
        var totalScore = 0;
        let now = Time.now();

        switch (wallets.get(walletId)) {
            case null { return 0 };
            case (?wallet) {
                for (score in wallet.applicationScores.vals()) {
                    if(score.applicationId == applicationId){
                        for (validatorScore in score.validatorScores.vals()) {
                            if (validatorScore.expirationTime > now) {
                                totalScore += validatorScore.totalScore;
                            };
                        };
                    };
                };
            };
        };

        totalScore
    };

    public query func getWalletScore(walletId: Types.WalletId, applicationId: Text) : async {
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
                //Check application
                for (score in wallet.applicationScores.vals()) {
                    if (score.applicationId == applicationId) {
                        for (validatorScore in score.validatorScores.vals()) {
                            if (validatorScore.expirationTime > now) {
                                totalScore += validatorScore.totalScore;
                                validScores := Array.append(validScores, [validatorScore]);
                            } else {
                                expiredScores := Array.append(expiredScores, [validatorScore]);
                            };
                        };
                    };
                };
                { totalScore = totalScore; validScores = validScores; expiredScores = expiredScores }
            };
        }
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
}