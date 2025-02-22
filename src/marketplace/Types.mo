module {
    public type ProviderInfo = {
        id: Text;
        name: Text;
        description: Text;
        sourceUrl: Text;
        status: {#Pending; #Approved; #Rejected};
        moduleName: Text;
        canisterId: ?Principal;
        submittedAt: Int;
        reviewNote: ?Text;
        owner: Principal;
    };
    public type ProviderMetadata = {
        name: Text;
        description: Text;
        version: Text;
        author: Principal;
        parameters: [ParameterDefinition];
    };

    public type ParameterDefinition = {
        name: Text;
        description: Text;
        required: Bool;
        paramType: ParameterType;
    };

    public type ParameterType = {
        #Text;
        #Number;
        #Principal;
        #Boolean;
    };

    public type VerificationResult = {
        isValid: Bool;
        score: Nat;
        message: Text;
    };

    public type ProviderParam = {
        key: Text;
        value: Text;
    };

    public type BaseProvider = actor {
        verify : shared (Principal, ?[ProviderParam]) -> async VerificationResult;
        metadata : shared query () -> async ProviderMetadata;
    };
}