import Nat "mo:base/Nat";
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

    public type ProviderParams = {
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

    public type Criteria = {
        id: CriteriaId;
        name: Text;
        description: Text;
        providerId: Text;
        params: ProviderParams;
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
        verifyMethod: VerifyMethod;
    };
    public type Validator = {
        id: ValidatorId;
        applicationId: ApplicationId;
        name: Text;
        logo: Text;
        description: Text;
        criterias: [Criteria];
        verifyMethod: VerifyMethod;
        owner: Principal;
        totalScore: Nat;//Will be calculated by the module
    };

    public type UpdateValidator = {
        name: Text;
        logo: Text;
        description: Text;
        verifyMethod: VerifyMethod;
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

    public type Provider = {
        id: Text;
        name: Text;
        description: Text;
        moduleId: Text;
    };

    public type Application = {
        id: ApplicationId;
        name: Text;
        description: Text;
        owner: Principal;
        validators: [ValidatorId];
    };
}