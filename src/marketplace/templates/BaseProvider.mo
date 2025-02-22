import Types "../Types";

module {
    public type VerificationResult = Types.VerificationResult;
    public type ProviderParam = Types.ProviderParam;
    
    public type BaseProvider = actor {
        verify : shared (Principal, ?[ProviderParam]) -> async VerificationResult;
        metadata : shared query () -> async Types.ProviderMetadata;
    };

    // Helper functions
    public func validateParams(params: ?[ProviderParam], required: [Text]) : Bool {
        switch(params) {
            case null { required.size() == 0 };
            case (?p) {
                for (req in required.vals()) {
                    if (not hasParam(p, req)) return false;
                };
                true
            };
        };
    };

    public func hasParam(params: [ProviderParam], key: Text) : Bool {
        for (p in params.vals()) {
            if (p.key == key) return true;
        };
        false;
    };
}