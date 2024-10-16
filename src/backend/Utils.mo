import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
import Float "mo:base/Float";
module Utils {
    public func convertSecondsToNanoseconds(seconds: Nat) : Int {
        seconds * 1_000_000_000
    };
    public func intToNat(value: Int) : Nat { Nat64.toNat(Int64.toNat64(Int64.fromInt(value))) };
    public func intToNat64(value: Int) : Nat64 { Nat64.fromIntWrap(value) };
    public func natToInt(value: Nat) : Int { Int64.toInt(Int64.fromNat64(Nat64.fromNat(value))) };
}