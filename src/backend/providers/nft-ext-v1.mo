import Types "../Types";
import Principal "mo:base/Principal";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Int "mo:base/Int";
import Option "mo:base/Option";
module {
    // Verify the criteria of the NFT holding validator, by EXT standard v1 (implemented by Toniqlab - Entrepot)
    public func verify(walletId: Types.WalletId, params: Types.ProviderParams): async Nat {
        var nftCount = 0;
        let _canisterId = Option.get(params.canisterId, "_");
        if (_canisterId == "_") {
            return 0;
        };
        let Canister = actor(_canisterId: Text) : actor {
            tokens : shared (Text) -> async Result.Result<[Nat32], Text>;
        };
        let accountId = Principal.toText(walletId);
        switch(await Canister.tokens(accountId)) {
            case (#ok(nfts)){
                nftCount := nfts.size();
            };
            case (#err(err)) nftCount := 0;
        };
        nftCount;
    };
    // public func create() : Types.ValidatorModule {
    //     {
    //         id = "canic-nft";
    //         name = "NFT Holding Validator";
    //         verify = func (walletId: Types.WalletId, params: Types.ValidatorParams) : async Types.VerificationResult {
    //             let canisterId = "be2us-64aaa-aaaaa-qaabq-cai";
    //             var nftCount = 0;
    //             let Canister = actor(canisterId) : actor {
    //                 tokens : shared (Text) -> async Result.Result<[Nat32], Text>;
    //             };
    //             let accountId = Principal.toText(walletId);
    //             switch(await Canister.tokens(accountId)) {
    //                 case (#ok(nfts)){
    //                     nftCount := nfts.size();
                        
    //                 };
    //                 case (#err(err)) nftCount := 0;
    //             };
    //             let isValid = Validator.compare(nftCount, params);
    //             {
    //                 isValid = isValid;
    //                 score = if (isValid) params.score else 0;
    //             }
    //         };
    //     }
    // };
}