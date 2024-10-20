import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
import Types "Types";
module Utils {
    public func convertSecondsToNanoseconds(seconds: Nat) : Int {
        seconds * 1_000_000_000
    };
    public func intToNat(value: Int) : Nat { Nat64.toNat(Int64.toNat64(Int64.fromInt(value))) };
    public func intToNat64(value: Int) : Nat64 { Nat64.fromIntWrap(value) };
    public func natToInt(value: Nat) : Int { Int64.toInt(Int64.fromNat64(Nat64.fromNat(value))) };
    public func compareValues(value: Int, threshold: Int, comparisonType: Types.ComparisonType, maxValue: ?Int) : Bool {
        switch (comparisonType) {
            case (#GreaterThan) { value > threshold };
            case (#LessThan) { value < threshold };
            case (#GreaterThanOrEqual) { value >= threshold };
            case (#LessThanOrEqual) { value <= threshold };
            case (#Equal) { value == threshold };
            case (#Between) {
                switch (maxValue) {
                    case (?max) { value >= threshold and value <= max };
                    case (null) { false }; // if no maxValue, consider it invalid
                };
            };
        };
    };
}