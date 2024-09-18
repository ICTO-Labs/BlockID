import Nat "mo:base/Nat";
// Types.mo
module {
    public type WalletId = Principal;
    public type ValidatorId = Text;
    public type GroupId = Text;
    public type CriteriaId = Text;

    public type ComparisonType = {
        #GreaterThan;
        #LessThan;
        #GreaterThanOrEqual;
        #LessThanOrEqual;
        #Equal;
        #Between;  // New comparison type for range
    };

    public type VerificationResult = {
        isValid: Bool;
        score: Nat;
    };

    public type ProviderParams = {
        minValue: Int;
        maxValue: ?Int;
        comparisonType: ComparisonType;
        canisterId: ?Text;//Interact with canisterId
        additionalParams: ?[(Text, Text)];
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

    public type Group = {
        id: GroupId;
        name: Text;
        description: Text;
        criterias: [CriteriaId];
    };
    public type VerifyMethod = {
        #VcFlow;
        #Module;
    };

    public type Validator = {
        id: ValidatorId;
        name: Text;
        logo: Text;
        description: Text;
        groups: [GroupId];
        verifyMethod: VerifyMethod;
    };

    public type ValidatorInfo = {
        id: ValidatorId;
        name: Text;
        logo: Text;
        description: Text;
        verifyMethod: VerifyMethod;
        totalScore: Nat;
    };

    public type WalletScore = {
        validatorId: ValidatorId;
        groupId: GroupId;
        criteriaId: CriteriaId;
        score: Nat;
        verified: Bool;
        verificationTime: Int;
        expirationTime: Int;
    };

    public type Wallet = {
        id: WalletId;
        scores: [WalletScore];
    };

    public type Provider = {
        walletId: WalletId;
        params: ProviderParams;
    };

}