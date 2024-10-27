import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
import Types "Types";
import SHA224 "./Utils/SHA224";
import CRC32 "./Utils/CRC32";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Char "mo:base/Char";
import Nat8 "mo:base/Nat8";
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
    public type AccountIdentifier = {
        hash: [Nat8];
    };
    public func principalToAccount(p : Principal) : AccountIdentifier {
        let digest = SHA224.Digest();
        digest.write([10, 97, 99, 99, 111, 117, 110, 116, 45, 105, 100]:[Nat8]); // b"\x0Aaccount-id"
        let blob = Principal.toBlob(p);
        digest.write(Blob.toArray(blob));
        digest.write(Array.freeze<Nat8>(Array.init<Nat8>(32, 0 : Nat8))); // sub account
        let hash_bytes = digest.sum();

        return {hash=hash_bytes;}: AccountIdentifier;
    };
    private let symbols = [
        '0', '1', '2', '3', '4', '5', '6', '7',
        '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
    ];
    private let base : Nat8 = 0x10;
    func nat8ToText(u8: Nat8) : Text {
        let c1 = symbols[Nat8.toNat((u8/base))];
        let c2 = symbols[Nat8.toNat((u8%base))];
        return Char.toText(c1) # Char.toText(c2);
    };
    public func encode(array : [Nat8]) : Text {
            Array.foldLeft<Nat8, Text>(array, "", func (accum, u8) {
                accum # nat8ToText(u8);
            });
        };
    /// Return the Text of the account identifier.
    public func accountToText(p : AccountIdentifier) : Text {
        let crc = CRC32.crc32(p.hash);
        let aid_bytes = Array.append<Nat8>(crc, p.hash);

        return encode(aid_bytes);
    };
}