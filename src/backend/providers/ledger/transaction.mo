import IndexTypes "./indexTypes";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Types "../../Types";
import Utils "../../Utils";

module {
    let INDEX : IndexTypes.Self = actor "qhbym-qaaaa-aaaaa-aaafq-cai";

    //Get transactions by principal id, only get Operation type: Transfer
    public func getTransactions(principalId: Principal) : async IndexTypes.GetAccountIdentifierTransactionsResult {
        let transaction = await INDEX.get_account_transactions({account = {owner = principalId; subaccount = null}; max_results = 100; start = null});
        return transaction;
    };

    //Count volume of transactions by principal id, only count Operation type: Transfer
    public func countTransactions(principalId: Principal, checkType: Text) : async Nat {
        let transactions = await getTransactions(principalId);
        let now = Time.now();
        let threeDaysAgo = now - 3 * 24 * 60 * 60 * 1000000000;
        switch(transactions){
            case(#Ok(transactions)){
                //Loop through transactions and count volume for operation type: Transfer
                switch (checkType) {
                    case ("volume") {
                        let transferVolume = Array.foldLeft(transactions.transactions, 0, func (acc: Nat, transaction: IndexTypes.TransactionWithId) : Nat {
                            switch(transaction.transaction.operation){
                            case(#Transfer(transfer)){
                                switch (transaction.transaction.timestamp) {
                                    case (?timestamp) {
                                        if (timestamp.timestamp_nanos < Utils.intToNat64(threeDaysAgo)) {
                                            acc + Nat64.toNat(transfer.amount.e8s)
                                        } else {
                                            acc
                                        }
                                    };
                                    case (null) { acc };
                                };
                            };
                            case(_){ acc };
                            };
                        });
                        return transferVolume;
                    };
                    case("count-tx"){
                        return transactions.transactions.size();
                    };
                    case("spent-volume"){
                        let transferVolume = Array.foldLeft(transactions.transactions, 0, func (acc: Nat, transaction: IndexTypes.TransactionWithId) : Nat {
                            switch(transaction.transaction.operation){
                            case(#Transfer(transfer)){
                                //Check if to is the account of principalId
                                let _account = Utils.accountToText(Utils.principalToAccount(principalId));
                                if (transfer.from == _account) {
                                    acc + Nat64.toNat(transfer.amount.e8s)
                                } else {
                                    acc
                                }
                            };
                            case(_){ acc };
                            };
                        });
                        return transferVolume;
                    };
                    case(_){
                        return 0;
                    };
                };
            };
            case(#Err(_err)){
                return 0;
            };
        };
    };
    
    public func verifyICPTransaction(walletId : Principal, key: Text, additionalParams : ?Types.AdditionalParams) : async Types.VerificationResult {
        let _volume = await countTransactions(walletId, key);
        switch (additionalParams) {
            case (null) return { isValid = _volume > 0; score = 1; message = "You have " # key # ": " # debug_show(_volume) # ", required: 0" }; // if no additionalParams, consider it valid!! Keep default value
            case (?params) {
                let _haveMax = if(params.maxValue != null) { " to " # debug_show(params.maxValue) } else {""};
                return { isValid = Utils.compareValues(_volume, params.value, params.comparisonType, params.maxValue); score = 1; message = "Your " # key # ": " # debug_show(_volume) # ", required: " # debug_show(params.value) # " " # _haveMax };
            };
        };
    };

}


