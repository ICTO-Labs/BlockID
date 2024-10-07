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
    private var wallets = HashMap.HashMap<Types.WalletId, Types.Wallet>(0, Principal.equal, Principal.hash);
    private stable var _wallets: [(Types.WalletId, Types.Wallet)] = [];
    private var applications = HashMap.HashMap<Text, Types.Application>(0, Text.equal, Text.hash);
    private stable var _applications: [(Text, Types.Application)] = [];
    private var providers = HashMap.HashMap<Text, Types.Provider>(0, Text.equal, Text.hash);
    private stable var _providers: [(Text, Types.Provider)] = [];
    private stable var _admins : [Text] = ["lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"];
    private stable var _vcCanisterId : [Text] = ["cpmcr-yeaaa-aaaaa-qaala-cai"];//Remote canister for VC validation

    //ID generator
    private var nextValidatorId : Nat = 0;
    private var nextCriteriaId : Nat = 0;

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

    //Create custom provider template
    public shared(msg) func createProvider(provider: Types.Provider) : async Result.Result<(), Text> {
        assert(_isAdmin(Principal.toText(msg.caller)));//Only admin can create provider template
        switch (providers.get(provider.id)) {
            case null {
                providers.put(provider.id, { provider with owner = ?msg.caller });
                #ok(())
            };
            case (?_) { #err("Provider ID already exists") };
        };
    };

    public shared(msg) func updateProvider(providerId: Text, updatedProvider: Types.Provider) : async Result.Result<(), Text> {
        assert(_isAdmin(Principal.toText(msg.caller)));//Only admin can update provider template
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
        //TODO: Implement VC verification
        let walletId = Principal.fromText(wallet_id);
        var _totalScore = 0;
        switch (applications.get(application_id)) {
            case null { return #err("Application not found") };
            case (?_) {
                switch (validators.get(validator_id)) {
                    case null { return #err("Validator not found") };
                    case (?validator) {
                        var newScore : ?Types.WalletScore = null;
                        let now = Time.now();
                        for (criteria in validator.criterias.vals()) {
                            if(criterial_id == criteria.id and criteria.isVC == true){//Only verify VC criterias
                                //Set score as criteria.score
                                _totalScore += criteria.score;
                                newScore := ?{
                                    applicationId = application_id;
                                    validatorId = validator_id;
                                    score = criteria.score;
                                    verified = true;
                                    verificationTime = now;
                                    expirationTime = now + 12 * 30 * 24 * 60 * 60 * 1000000000; // 12 months in nanoseconds
                                };
                                // Update wallet scores
                                switch (wallets.get(walletId)) {
                                    case null {
                                        switch (newScore) { 
                                            case null { };
                                            case (?score) {
                                                wallets.put(walletId, { id = walletId; applicationId = application_id; scores = [score] });
                                            };
                                        };
                                    };
                                    case (?wallet) {
                                        let updatedScores = Array.append(
                                            Array.filter(wallet.scores, func (score: Types.WalletScore) : Bool {
                                                score.applicationId != application_id and score.validatorId != validator_id
                                            }),
                                            switch (newScore) {
                                                case null { [] };
                                                case (?score) { [score] };
                                            }
                                        );
                                        wallets.put(walletId, { id = walletId; applicationId = application_id; scores = updatedScores });
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
        if(_totalScore > 0){
            return #ok(true);
        }else{
            return #err("No VC criterias found");
        };
    };

    public shared(msg) func verifyWallet(applicationId: Text, validatorId: Types.ValidatorId, walletId: Types.WalletId) : async Result.Result<Nat, Text> {
        var totalScore = 0;
        switch (applications.get(applicationId)) {
            case null { return #err("Application not found") };
            case (?_) {
                switch (validators.get(validatorId)) {
                    case null { return #err("Validator not found") };
                    case (?validator) {
                        var newScore : ?Types.WalletScore = null;
                        let now = Time.now();
                        for (criteria in validator.criterias.vals()) {
                            if(criteria.isVC == false){//Only verify non-VC criterias
                                let provider = switch (providers.get(Option.get(criteria.providerId, ""))) {
                                    case (?t) t;
                                    case null return #err("Provider not found")
                                };
                                let result = await Provider.verifyCriteria(walletId, criteria, provider);
                                if (result.isValid) {
                                    totalScore += result.score;
                                };
                            };
                        };

                        if (totalScore > 0) {
                            newScore := ?{
                                applicationId = applicationId;
                                validatorId = validatorId;
                                score = totalScore;
                                verified = true;
                                verificationTime = now;
                                expirationTime = now + 12 * 30 * 24 * 60 * 60 * 1000000000; // 12 months in nanoseconds
                            };
                        };

                        // Update wallet scores
                        switch (wallets.get(walletId)) {
                            case null {
                                switch (newScore) {
                                    case null { };
                                    case (?score) {
                                        wallets.put(walletId, { id = walletId; applicationId = applicationId; scores = [score] });
                                    };
                                };
                            };
                            case (?wallet) {
                                let updatedScores = Array.append(
                                    Array.filter(wallet.scores, func (score: Types.WalletScore) : Bool { 
                                        score.applicationId != applicationId and score.validatorId != validatorId
                                    }),
                                    switch (newScore) {
                                        case null { [] };
                                        case (?score) { [score] };
                                    }
                                );
                                wallets.put(walletId, { id = walletId; applicationId = applicationId; scores = updatedScores });
                            };
                        };
                    };
                };
            };
        };
        #ok(totalScore)
    };

    public query func getCurrentWalletScore(walletId: Types.WalletId, applicationId: Text) : async Nat {
        var totalScore = 0;
        let now = Time.now();

        switch (wallets.get(walletId)) {
            case null { return 0 };
            case (?wallet) {
                for (score in wallet.scores.vals()) {
                    if (score.applicationId == applicationId and score.expirationTime > now) {
                        totalScore += score.score;
                    };
                };
            };
        };

        totalScore
    };

    public query func getWalletScore(walletId: Types.WalletId, applicationId: ?Text) : async {
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
                    if (applicationId == null or score.applicationId == Option.get(applicationId, "")) {
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

    public shared(msg) func createApplication(app: Types.Application) : async Result.Result<(), Text> {
        //Check exist application
        switch (applications.get(app.id)) {
            case null {
                applications.put(app.id, { app with owner = msg.caller });
                return #ok(());
            };
            case (?a) { return #err("Application ID already exists") };
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

    func _isVcCanisterId(canisterId: Text) : Bool {
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
            case (?v) { return #err("Validator ID already exists") };
        };
    };
    public shared(msg) func createValidator(appId: Text, validator: Types.CreateValidator) : async Result.Result<Types.Validator, Text> {
        //Create new validator and add to application
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