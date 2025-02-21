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
        message: Text;
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
        additionalParams: ?AdditionalParams;//Additional params for the criteria
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

    public type CriteriaScore = {
        criteriaId: CriteriaId;
        score: Nat;
        verified: Bool;
        verificationTime: ?Int;
        expirationTime: ?Int;
    };

    //new CriteriaScore with message
    public type CriteriaScoreWithMessage = {
        criteriaId: CriteriaId;
        score: Nat;
        verified: Bool;
        message: Text;
        verificationTime: ?Int;
        expirationTime: ?Int;
    };

    public type ApplicationScore = {
        applicationId: ApplicationId;
        validatorScores: [WalletScore];
    };

    // Update WalletScore
    public type WalletScore = {
        validatorId: ValidatorId;
        criteriaScores: [CriteriaScore];
        totalScore: Nat;
        lastVerificationTime: Int;
        expirationTime: Int;
    };

    public type Wallet = {
        id: WalletId;
        applicationScores: [ApplicationScore];
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
    public type WalletLink = {
        primaryWallet: WalletId;
        secondaryWallet: WalletId;
        creationTime: Int;
    };
    public type VerificationParams = {
        walletId: WalletId;
        criteriaId: CriteriaId;
        params: [ProviderParams];
        verificationTime: Int;
        expirationTime: Int;
    };
    public type AdditionalParams = {
        comparisonType: ComparisonType;
        value: Int;
        maxValue: ?Int;
    };

    //Analytics
    public type DailyStats = {
        date: Int; // Unix timestamp 
        newVerifications: Nat;
        activeWallets: Nat;
        totalVerifications: Nat;
        avgScore: Float;
    };

    public type ValidatorStats = {
        validatorId: Text;
        validatorName: ?Text;
        totalVerifications: Nat;
        successRate: Float;
        avgScore: Float;
        lastUpdated: Int;
    };

    public type VerificationTrend = {
        timestamp: Int;
        validatorId: Text;
        success: Bool;
        score: Nat;
    };

}