export const idlFactory = ({ IDL }) => {
    const WalletId = IDL.Principal;
    const Result_1 = IDL.Variant({ 'ok': IDL.Null, 'err': IDL.Text });
    const ApplicationId = IDL.Text;
    const ValidatorId = IDL.Text;
    const Application = IDL.Record({
        'id': ApplicationId,
        'owner': IDL.Principal,
        'name': IDL.Text,
        'description': IDL.Text,
        'validators': IDL.Vec(ValidatorId),
    });
    const CriteriaId = IDL.Text;
    const ComparisonType = IDL.Variant({
        'Equal': IDL.Null,
        'Between': IDL.Null,
        'LessThanOrEqual': IDL.Null,
        'GreaterThan': IDL.Null,
        'LessThan': IDL.Null,
        'GreaterThanOrEqual': IDL.Null,
    });
    const AdditionalParams = IDL.Record({
        'value': IDL.Int,
        'comparisonType': ComparisonType,
        'maxValue': IDL.Opt(IDL.Int),
    });
    const ProviderParams = IDL.Record({
        'key': IDL.Text,
        'value': IDL.Opt(IDL.Text),
        'dataType': IDL.Variant({
            'Int': IDL.Null,
            'Bool': IDL.Null,
            'Text': IDL.Null,
            'Principal': IDL.Null,
        }),
    });
    const Criteria = IDL.Record({
        'id': CriteriaId,
        'autoVerify': IDL.Bool,
        'isVC': IDL.Bool,
        'name': IDL.Text,
        'additionalParams': IDL.Opt(AdditionalParams),
        'description': IDL.Text,
        'score': IDL.Nat,
        'expirationTime': IDL.Int,
        'providerParams': IDL.Opt(IDL.Vec(ProviderParams)),
        'providerArgs': IDL.Opt(IDL.Vec(ProviderParams)),
        'providerId': IDL.Opt(IDL.Text),
    });
    const Provider = IDL.Record({
        'id': IDL.Text,
        'owner': IDL.Opt(IDL.Principal),
        'moduleType': IDL.Variant({
            'VC': IDL.Null,
            'Local': IDL.Text,
            'Remote': IDL.Text,
            'Custom': IDL.Null,
        }),
        'name': IDL.Text,
        'description': IDL.Text,
        'params': IDL.Vec(ProviderParams),
    });
    const CreateValidator = IDL.Record({
        'applicationId': ApplicationId,
        'logo': IDL.Text,
        'name': IDL.Text,
        'description': IDL.Text,
    });
    const Validator = IDL.Record({
        'id': ValidatorId,
        'applicationId': ApplicationId,
        'owner': IDL.Principal,
        'logo': IDL.Text,
        'name': IDL.Text,
        'description': IDL.Text,
        'totalScore': IDL.Nat,
        'criterias': IDL.Vec(Criteria),
    });
    const Result_3 = IDL.Variant({ 'ok': Validator, 'err': IDL.Text });
    const WalletLink = IDL.Record({
        'primaryWallet': WalletId,
        'creationTime': IDL.Int,
        'secondaryWallet': WalletId,
    });
    const VerificationParams = IDL.Record({
        'verificationTime': IDL.Int,
        'expirationTime': IDL.Int,
        'criteriaId': CriteriaId,
        'params': IDL.Vec(ProviderParams),
        'walletId': WalletId,
    });
    const Result_4 = IDL.Variant({ 'ok': Application, 'err': IDL.Text });
    const CriteriaScore = IDL.Record({
        'verified': IDL.Bool,
        'verificationTime': IDL.Opt(IDL.Int),
        'score': IDL.Nat,
        'expirationTime': IDL.Opt(IDL.Int),
        'criteriaId': CriteriaId,
    });
    const WalletScore = IDL.Record({
        'criteriaScores': IDL.Vec(CriteriaScore),
        'totalScore': IDL.Nat,
        'expirationTime': IDL.Int,
        'validatorId': ValidatorId,
        'lastVerificationTime': IDL.Int,
    });
    const ApplicationScore = IDL.Record({
        'applicationId': ApplicationId,
        'validatorScores': IDL.Vec(WalletScore),
    });
    const Wallet = IDL.Record({
        'id': WalletId,
        'applicationScores': IDL.Vec(ApplicationScore),
    });
    const Result_2 = IDL.Variant({ 'ok': Wallet, 'err': IDL.Text });
    const UpdateValidator = IDL.Record({
        'applicationId': ApplicationId,
        'logo': IDL.Text,
        'name': IDL.Text,
        'description': IDL.Text,
    });
    const ValidateResponse = IDL.Variant({ 'Ok': IDL.Bool, 'Err': IDL.Text });
    const Result = IDL.Variant({ 'ok': IDL.Nat, 'err': IDL.Text });
    return IDL.Service({
        'acceptLinkWallet': IDL.Func([WalletId], [Result_1], []),
        'addAdmin': IDL.Func([IDL.Text], [Result_1], []),
        'addVcCanisterId': IDL.Func([IDL.Text], [Result_1], []),
        'createApplication': IDL.Func([Application], [Result_1], []),
        'createCriteria': IDL.Func([ValidatorId, Criteria], [Result_1], []),
        'createProvider': IDL.Func([Provider], [Result_1], []),
        'createValidator': IDL.Func([IDL.Text, CreateValidator], [Result_3], []),
        'getAdmins': IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
        'getAllLinkedWallets': IDL.Func(
            [],
            [IDL.Vec(IDL.Tuple(WalletId, WalletLink))],
            [],
        ),
        'getAllVerificationParams': IDL.Func(
            [],
            [IDL.Vec(IDL.Tuple(IDL.Text, VerificationParams))],
            [],
        ),
        'getApplication': IDL.Func([IDL.Text], [Result_4], ['query']),
        'getApplications': IDL.Func(
            [],
            [IDL.Vec(IDL.Tuple(IDL.Text, Application))],
            ['query'],
        ),
        'getMyLinkedWallets': IDL.Func(
            [],
            [
                IDL.Vec(
                    IDL.Record({
                        'linkedWallet': WalletId,
                        'creationTime': IDL.Int,
                        'isPrimary': IDL.Bool,
                    })
                ),
            ],
            [],
        ),
        'getNeuronIds': IDL.Func([], [IDL.Vec(IDL.Nat64)], []),
        'getPendingLinkRequests': IDL.Func([], [IDL.Vec(WalletId)], ['query']),
        'getProviders': IDL.Func(
            [],
            [IDL.Vec(IDL.Tuple(IDL.Text, Provider))],
            ['query'],
        ),
        'getScoreDistribution': IDL.Func(
            [],
            [IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat))],
            ['query'],
        ),
        'getTotalVerifiedWallets': IDL.Func([], [IDL.Nat], ['query']),
        'getValidator': IDL.Func([ValidatorId], [Result_3], ['query']),
        'getValidators': IDL.Func(
            [IDL.Text],
            [IDL.Vec(IDL.Tuple(ValidatorId, Validator))],
            ['query'],
        ),
        'getVcCanisterId': IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
        'getVerifiedCriteria': IDL.Func(
            [ApplicationId, ValidatorId, WalletId],
            [IDL.Vec(IDL.Tuple(CriteriaId, IDL.Nat))],
            ['query'],
        ),
        'getWalletDetail': IDL.Func([WalletId], [Result_2], ['query']),
        'getWalletScore': IDL.Func(
            [WalletId, IDL.Text],
            [
                IDL.Record({
                    'linkedWallet': IDL.Opt(IDL.Tuple(WalletId, IDL.Nat)),
                    'linkedScore': IDL.Nat,
                    'primaryScore': IDL.Nat,
                    'totalScore': IDL.Nat,
                    'percentileAbove': IDL.Float64,
                }),
            ],
            ['query'],
        ),
        'getWallets': IDL.Func([], [IDL.Vec(IDL.Tuple(WalletId, Wallet))], []),
        'recountDistribution': IDL.Func([IDL.Text], [IDL.Text], []),
        'rejectLinkWallet': IDL.Func([WalletId], [Result_1], []),
        'removeAdmin': IDL.Func([IDL.Text], [Result_1], []),
        'removeApplication': IDL.Func([IDL.Text], [Result_1], []),
        'removeCriteria': IDL.Func([ValidatorId, CriteriaId], [Result_1], []),
        'removeProvider': IDL.Func([IDL.Text], [Result_1], []),
        'removeValidator': IDL.Func([ValidatorId], [Result_1], []),
        'removeVcCanisterId': IDL.Func([IDL.Text], [Result_1], []),
        'requestLinkWallet': IDL.Func([WalletId], [Result_1], []),
        'setTotalVerifiedWallets': IDL.Func([IDL.Nat], [], []),
        'unlinkWallet': IDL.Func([WalletId], [Result_1], []),
        'updateApplication': IDL.Func([Application], [Result_1], []),
        'updateCriteria': IDL.Func(
            [ValidatorId, CriteriaId, Criteria],
            [Result_1],
            [],
        ),
        'updateProvider': IDL.Func([IDL.Text, Provider], [Result_1], []),
        'updateValidator': IDL.Func(
            [ValidatorId, UpdateValidator],
            [Result_1],
            [],
        ),
        'validateVC': IDL.Func(
            [IDL.Text, IDL.Text, IDL.Text, IDL.Text],
            [ValidateResponse],
            [],
        ),
        'verifyWalletByCriteria': IDL.Func(
            [
                IDL.Text,
                ValidatorId,
                IDL.Vec(CriteriaId),
                IDL.Opt(IDL.Vec(ProviderParams)),
            ],
            [Result],
            [],
        ),
        'verifyWalletByValidator': IDL.Func([IDL.Text, ValidatorId], [Result], []),
    });
};
export const init = ({ IDL }) => { return []; };
