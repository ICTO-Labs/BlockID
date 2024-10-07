import Nat "mo:base/Nat";
import Bool "mo:base/Bool";
// Types.mo
module {
    public type WalletId = Principal;
    public type ValidatorId = Text;
    public type CriteriaId = Text;
    public type ApplicationId = Text;

    public type ComparisonType = {
        #GreaterThan;
        #LessThan;
        #GreaterThanOrEqual;
        #LessThanOrEqual;
        #Equal;
        #Between;
    };

    public type VerificationResult = {
        isValid: Bool;
        score: Nat;
    };

    public type ProviderParamsBK = {
        minValue: Int;
        maxValue: ?Int;
        comparisonType: ComparisonType;
        canisterId: ?Text;
        additionalParams: ?[(Text, Text)];
        issuerInfo: ?{
            issuerOrigin: Text;
            issuerCanisterId: Text;
            credentialSpec: {
                credentialType: Text;
                arguments: [Text];
            };
        }
    };

    public type ProviderParams = {
        key: Text;
        value: ?Text;
        dataType: {#Int; #Text; #Bool; #Principal};
    };

    public type Provider = {
        id: Text;
        name: Text;
        description: Text;
        moduleType: {
            #Local: Text; //Local module name
            #Remote: Text; //Remote canister id
            #VC; //Define if is verify with a VC
            #Custom; //Custom module...
        };
        params: [ProviderParams];//Key - Value
        owner: ?Principal;//for custom providers
    };

    public type Criteria = {
        id: CriteriaId;
        name: Text;
        description: Text;
        providerId: ?Text;//Map with the provider template id
        providerParams: ?[ProviderParams];
        providerArgs: ?[ProviderParams];//Split the arguments from the params
        // templateId: Text;
        isVC: Bool;
        score: Nat;
        expirationTime: Int;
        autoVerify: Bool;
    };

    //Criteria info for the frontend
    public type CriteriaInfo = {
        id: CriteriaId;
        name: Text;
        description: Text;
        providerId: Text;
        provider: Provider;
        isVC: Bool;
        score: Nat;
        expirationTime: Int;
        autoVerify: Bool;
    };

    public type VerifyMethod = {
        #VcFlow;
        #Module;
    };
    public type CreateValidator = {
        applicationId: ApplicationId;
        name: Text;
        logo: Text;
        description: Text;
        // verifyMethod: VerifyMethod;
    };
    public type Validator = {
        id: ValidatorId;
        applicationId: ApplicationId;
        name: Text;
        logo: Text;
        description: Text;
        criterias: [Criteria];
        owner: Principal;
        totalScore: Nat;//Will be calculated by the module
    };

    public type UpdateValidator = {
        applicationId: ApplicationId;
        name: Text;
        logo: Text;
        description: Text;
    };

    public type WalletScore = {
        applicationId: ApplicationId;
        validatorId: ValidatorId;
        score: Nat;
        verified: Bool;
        verificationTime: Int;
        expirationTime: Int;
    };

    public type Wallet = {
        id: WalletId;
        applicationId: ApplicationId;//Separate the wallet from the application
        scores: [WalletScore];
    };

    public type Application = {
        id: ApplicationId;
        name: Text;
        description: Text;
        owner: Principal;
        validators: [ValidatorId];
    };
    
    public type ValidateData = {
        application_id: Text;
        validator_id: Text;
        criterial_id: Text;
        wallet_id: Text;
    };

    public type ValidateResponse = {
        #Ok: Bool;
        #Err: Text;
    };
}