// Validator.mo
import Types "Types";
import Result "mo:base/Result";
import Int "mo:base/Int";
import Principal "mo:base/Principal";

//Import validator module
import NFT_EXT_V1 "providers/nft-ext-v1";

module {

    public func verifyCriteria(walletId: Types.WalletId, criteria: Types.Criteria) : async Types.VerificationResult {
        let value = await getValue(walletId, criteria);
        let isValid = compare(value, criteria.params);
        {
            isValid = isValid;
            score = if (isValid) criteria.score else 0;
        }
    };

    private func compare(value: Int, params: Types.ProviderParams) : Bool {
        switch (params.comparisonType) {
            case (#GreaterThan) value > params.minValue;
            case (#LessThan) value < params.minValue;
            case (#GreaterThanOrEqual) value >= params.minValue;
            case (#LessThanOrEqual) value <= params.minValue;
            case (#Equal) value == params.minValue;
            case (#Between) {
                switch (params.maxValue) {
                    case (?maxValue) value >= params.minValue and value <= maxValue;
                    case (null) false;
                };
            };
        }
    };

    private func getValue(walletId: Types.WalletId, criteria: Types.Criteria) : async Int {
        switch(criteria.providerId) {
            case ("canic-nft") await NFT_EXT_V1.verify(walletId, criteria.params);
            // case ("canic-token") await getTokenBalance(walletId);
            case (_) 0;  // Default value, you might want to handle this differently
        }
    };
}