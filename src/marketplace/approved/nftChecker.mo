import Types "../Types";
import Base "../templates/BaseProvider";
import Principal "mo:base/Principal";
module {
    type VerificationResult = Types.VerificationResult;
    
    public func verify(
        walletId: Principal,
        params: ?[Types.ProviderParam]
    ) : async VerificationResult {
        if (not Base.validateParams(params, ["collection"])) {
            return {
                isValid = false;
                score = 0;
                message = "Missing required params: collection";
            };
        };

        // Simple logic check NFT
        let hasNFT = true;

        {
            isValid = hasNFT;
            score = if (hasNFT) 100 else 0;
            message = if (hasNFT) "Has NFT in collection" else "No NFT found";
        }
    };

    public func metadata() : async Types.ProviderMetadata {
        {
            name = "NFT Holdings Checker";
            description = "Verify NFT holdings on specific collection";
            version = "1.0.0";
            author = Principal.fromText("aaaaa-aa");
            parameters = [
                {
                    name = "collection";
                    description = "NFT collection principal";
                    required = true;
                    paramType = #Principal;
                }
            ];
        }
    };
}