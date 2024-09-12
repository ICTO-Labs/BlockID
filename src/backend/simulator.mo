import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Bool "mo:base/Bool";
actor Simulator = {
    // This is a mock implementation of the NFT holding validator
    public shared func tokens(account: Text): async Result.Result<[Nat32], Text>{
        return #ok([5046]);
    };
};
