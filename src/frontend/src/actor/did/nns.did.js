export const idlFactory = ({ IDL }) => {
    const Proposal = IDL.Rec();
    const NeuronId = IDL.Record({ id: IDL.Nat64 });
    const Followees = IDL.Record({ followees: IDL.Vec(NeuronId) });
    const AccountIdentifier = IDL.Record({ hash: IDL.Vec(IDL.Nat8) });
    const NodeProvider = IDL.Record({
        id: IDL.Opt(IDL.Principal),
        reward_account: IDL.Opt(AccountIdentifier),
    });
    const RewardToNeuron = IDL.Record({ dissolve_delay_seconds: IDL.Nat64 });
    const RewardToAccount = IDL.Record({
        to_account: IDL.Opt(AccountIdentifier),
    });
    const RewardMode = IDL.Variant({
        RewardToNeuron: RewardToNeuron,
        RewardToAccount: RewardToAccount,
    });
    const RewardNodeProvider = IDL.Record({
        node_provider: IDL.Opt(NodeProvider),
        reward_mode: IDL.Opt(RewardMode),
        amount_e8s: IDL.Nat64,
    });
    const MostRecentMonthlyNodeProviderRewards = IDL.Record({
        timestamp: IDL.Nat64,
        rewards: IDL.Vec(RewardNodeProvider),
    });
    const GovernanceCachedMetrics = IDL.Record({
        not_dissolving_neurons_e8s_buckets: IDL.Vec(
            IDL.Tuple(IDL.Nat64, IDL.Float64)
        ),
        garbage_collectable_neurons_count: IDL.Nat64,
        neurons_with_invalid_stake_count: IDL.Nat64,
        not_dissolving_neurons_count_buckets: IDL.Vec(
            IDL.Tuple(IDL.Nat64, IDL.Nat64)
        ),
        total_supply_icp: IDL.Nat64,
        neurons_with_less_than_6_months_dissolve_delay_count: IDL.Nat64,
        dissolved_neurons_count: IDL.Nat64,
        total_staked_e8s: IDL.Nat64,
        not_dissolving_neurons_count: IDL.Nat64,
        dissolved_neurons_e8s: IDL.Nat64,
        neurons_with_less_than_6_months_dissolve_delay_e8s: IDL.Nat64,
        dissolving_neurons_count_buckets: IDL.Vec(IDL.Tuple(IDL.Nat64, IDL.Nat64)),
        dissolving_neurons_count: IDL.Nat64,
        dissolving_neurons_e8s_buckets: IDL.Vec(IDL.Tuple(IDL.Nat64, IDL.Float64)),
        community_fund_total_staked_e8s: IDL.Nat64,
        timestamp_seconds: IDL.Nat64,
    });
    const NetworkEconomics = IDL.Record({
        neuron_minimum_stake_e8s: IDL.Nat64,
        max_proposals_to_keep_per_topic: IDL.Nat32,
        neuron_management_fee_per_proposal_e8s: IDL.Nat64,
        reject_cost_e8s: IDL.Nat64,
        transaction_fee_e8s: IDL.Nat64,
        neuron_spawn_dissolve_delay_seconds: IDL.Nat64,
        minimum_icp_xdr_rate: IDL.Nat64,
        maximum_node_provider_rewards_e8s: IDL.Nat64,
    });
    const RewardEvent = IDL.Record({
        day_after_genesis: IDL.Nat64,
        actual_timestamp_seconds: IDL.Nat64,
        distributed_e8s_equivalent: IDL.Nat64,
        settled_proposals: IDL.Vec(NeuronId),
    });
    const NeuronStakeTransfer = IDL.Record({
        to_subaccount: IDL.Vec(IDL.Nat8),
        neuron_stake_e8s: IDL.Nat64,
        from: IDL.Opt(IDL.Principal),
        memo: IDL.Nat64,
        from_subaccount: IDL.Vec(IDL.Nat8),
        transfer_timestamp: IDL.Nat64,
        block_height: IDL.Nat64,
    });
    const GovernanceError = IDL.Record({
        error_message: IDL.Text,
        error_type: IDL.Int32,
    });
    const CfNeuron = IDL.Record({
        nns_neuron_id: IDL.Nat64,
        amount_icp_e8s: IDL.Nat64,
    });
    const CfParticipant = IDL.Record({
        hotkey_principal: IDL.Text,
        cf_neurons: IDL.Vec(CfNeuron),
    });
    const Ballot = IDL.Record({ vote: IDL.Int32, voting_power: IDL.Nat64 });
    const Tally = IDL.Record({
        no: IDL.Nat64,
        yes: IDL.Nat64,
        total: IDL.Nat64,
        timestamp_seconds: IDL.Nat64,
    });
    const KnownNeuronData = IDL.Record({
        name: IDL.Text,
        description: IDL.Opt(IDL.Text),
    });
    const KnownNeuron = IDL.Record({
        id: IDL.Opt(NeuronId),
        known_neuron_data: IDL.Opt(KnownNeuronData),
    });
    const Spawn = IDL.Record({
        percentage_to_spawn: IDL.Opt(IDL.Nat32),
        new_controller: IDL.Opt(IDL.Principal),
        nonce: IDL.Opt(IDL.Nat64),
    });
    const Split = IDL.Record({ amount_e8s: IDL.Nat64 });
    const Follow = IDL.Record({
        topic: IDL.Int32,
        followees: IDL.Vec(NeuronId),
    });
    const ClaimOrRefreshNeuronFromAccount = IDL.Record({
        controller: IDL.Opt(IDL.Principal),
        memo: IDL.Nat64,
    });
    const By = IDL.Variant({
        NeuronIdOrSubaccount: IDL.Record({}),
        MemoAndController: ClaimOrRefreshNeuronFromAccount,
        Memo: IDL.Nat64,
    });
    const ClaimOrRefresh = IDL.Record({ by: IDL.Opt(By) });
    const RemoveHotKey = IDL.Record({
        hot_key_to_remove: IDL.Opt(IDL.Principal),
    });
    const AddHotKey = IDL.Record({ new_hot_key: IDL.Opt(IDL.Principal) });
    const ChangeAutoStakeMaturity = IDL.Record({
        requested_setting_for_auto_stake_maturity: IDL.Bool,
    });
    const IncreaseDissolveDelay = IDL.Record({
        additional_dissolve_delay_seconds: IDL.Nat32,
    });
    const SetDissolveTimestamp = IDL.Record({
        dissolve_timestamp_seconds: IDL.Nat64,
    });
    const Operation = IDL.Variant({
        RemoveHotKey: RemoveHotKey,
        AddHotKey: AddHotKey,
        ChangeAutoStakeMaturity: ChangeAutoStakeMaturity,
        StopDissolving: IDL.Record({}),
        StartDissolving: IDL.Record({}),
        IncreaseDissolveDelay: IncreaseDissolveDelay,
        JoinCommunityFund: IDL.Record({}),
        LeaveCommunityFund: IDL.Record({}),
        SetDissolveTimestamp: SetDissolveTimestamp,
    });
    const Configure = IDL.Record({ operation: IDL.Opt(Operation) });
    const RegisterVote = IDL.Record({
        vote: IDL.Int32,
        proposal: IDL.Opt(NeuronId),
    });
    const Merge = IDL.Record({ source_neuron_id: IDL.Opt(NeuronId) });
    const DisburseToNeuron = IDL.Record({
        dissolve_delay_seconds: IDL.Nat64,
        kyc_verified: IDL.Bool,
        amount_e8s: IDL.Nat64,
        new_controller: IDL.Opt(IDL.Principal),
        nonce: IDL.Nat64,
    });
    const StakeMaturity = IDL.Record({
        percentage_to_stake: IDL.Opt(IDL.Nat32),
    });
    const MergeMaturity = IDL.Record({ percentage_to_merge: IDL.Nat32 });
    const Amount = IDL.Record({ e8s: IDL.Nat64 });
    const Disburse = IDL.Record({
        to_account: IDL.Opt(AccountIdentifier),
        amount: IDL.Opt(Amount),
    });
    const Command = IDL.Variant({
        Spawn: Spawn,
        Split: Split,
        Follow: Follow,
        ClaimOrRefresh: ClaimOrRefresh,
        Configure: Configure,
        RegisterVote: RegisterVote,
        Merge: Merge,
        DisburseToNeuron: DisburseToNeuron,
        MakeProposal: Proposal,
        StakeMaturity: StakeMaturity,
        MergeMaturity: MergeMaturity,
        Disburse: Disburse,
    });
    const NeuronIdOrSubaccount = IDL.Variant({
        Subaccount: IDL.Vec(IDL.Nat8),
        NeuronId: NeuronId,
    });
    const ManageNeuron = IDL.Record({
        id: IDL.Opt(NeuronId),
        command: IDL.Opt(Command),
        neuron_id_or_subaccount: IDL.Opt(NeuronIdOrSubaccount),
    });
    const ExecuteNnsFunction = IDL.Record({
        nns_function: IDL.Int32,
        payload: IDL.Vec(IDL.Nat8),
    });
    const Params = IDL.Record({
        min_participant_icp_e8s: IDL.Nat64,
        max_icp_e8s: IDL.Nat64,
        swap_due_timestamp_seconds: IDL.Nat64,
        min_participants: IDL.Nat32,
        sns_token_e8s: IDL.Nat64,
        max_participant_icp_e8s: IDL.Nat64,
        min_icp_e8s: IDL.Nat64,
    });
    const OpenSnsTokenSwap = IDL.Record({
        community_fund_investment_e8s: IDL.Opt(IDL.Nat64),
        target_swap_canister_id: IDL.Opt(IDL.Principal),
        params: IDL.Opt(Params),
    });
    const TimeWindow = IDL.Record({
        start_timestamp_seconds: IDL.Nat64,
        end_timestamp_seconds: IDL.Nat64,
    });
    const SetOpenTimeWindowRequest = IDL.Record({
        open_time_window: IDL.Opt(TimeWindow),
    });
    const SetSnsTokenSwapOpenTimeWindow = IDL.Record({
        request: IDL.Opt(SetOpenTimeWindowRequest),
        swap_canister_id: IDL.Opt(IDL.Principal),
    });
    const SetDefaultFollowees = IDL.Record({
        default_followees: IDL.Vec(IDL.Tuple(IDL.Int32, Followees)),
    });
    const RewardNodeProviders = IDL.Record({
        use_registry_derived_rewards: IDL.Opt(IDL.Bool),
        rewards: IDL.Vec(RewardNodeProvider),
    });
    const ApproveGenesisKyc = IDL.Record({
        principals: IDL.Vec(IDL.Principal),
    });
    const Change = IDL.Variant({
        ToRemove: NodeProvider,
        ToAdd: NodeProvider,
    });
    const AddOrRemoveNodeProvider = IDL.Record({ change: IDL.Opt(Change) });
    const Motion = IDL.Record({ motion_text: IDL.Text });
    const Action = IDL.Variant({
        RegisterKnownNeuron: KnownNeuron,
        ManageNeuron: ManageNeuron,
        ExecuteNnsFunction: ExecuteNnsFunction,
        RewardNodeProvider: RewardNodeProvider,
        OpenSnsTokenSwap: OpenSnsTokenSwap,
        SetSnsTokenSwapOpenTimeWindow: SetSnsTokenSwapOpenTimeWindow,
        SetDefaultFollowees: SetDefaultFollowees,
        RewardNodeProviders: RewardNodeProviders,
        ManageNetworkEconomics: NetworkEconomics,
        ApproveGenesisKyc: ApproveGenesisKyc,
        AddOrRemoveNodeProvider: AddOrRemoveNodeProvider,
        Motion: Motion,
    });
    Proposal.fill(
        IDL.Record({
            url: IDL.Text,
            title: IDL.Opt(IDL.Text),
            action: IDL.Opt(Action),
            summary: IDL.Text,
        })
    );
    const WaitForQuietState = IDL.Record({
        current_deadline_timestamp_seconds: IDL.Nat64,
    });
    const ProposalData = IDL.Record({
        id: IDL.Opt(NeuronId),
        failure_reason: IDL.Opt(GovernanceError),
        cf_participants: IDL.Vec(CfParticipant),
        ballots: IDL.Vec(IDL.Tuple(IDL.Nat64, Ballot)),
        proposal_timestamp_seconds: IDL.Nat64,
        reward_event_round: IDL.Nat64,
        failed_timestamp_seconds: IDL.Nat64,
        reject_cost_e8s: IDL.Nat64,
        latest_tally: IDL.Opt(Tally),
        sns_token_swap_lifecycle: IDL.Opt(IDL.Int32),
        decided_timestamp_seconds: IDL.Nat64,
        proposal: IDL.Opt(Proposal),
        proposer: IDL.Opt(NeuronId),
        wait_for_quiet_state: IDL.Opt(WaitForQuietState),
        executed_timestamp_seconds: IDL.Nat64,
        original_total_community_fund_maturity_e8s_equivalent: IDL.Opt(IDL.Nat64),
    });
    const Command_2 = IDL.Variant({
        Spawn: NeuronId,
        Split: Split,
        Configure: Configure,
        Merge: Merge,
        DisburseToNeuron: DisburseToNeuron,
        SyncCommand: IDL.Record({}),
        ClaimOrRefreshNeuron: ClaimOrRefresh,
        MergeMaturity: MergeMaturity,
        Disburse: Disburse,
    });
    const NeuronInFlightCommand = IDL.Record({
        command: IDL.Opt(Command_2),
        timestamp: IDL.Nat64,
    });
    const BallotInfo = IDL.Record({
        vote: IDL.Int32,
        proposal_id: IDL.Opt(NeuronId),
    });
    const DissolveState = IDL.Variant({
        DissolveDelaySeconds: IDL.Nat64,
        WhenDissolvedTimestampSeconds: IDL.Nat64,
    });
    const Neuron = IDL.Record({
        id: IDL.Opt(NeuronId),
        staked_maturity_e8s_equivalent: IDL.Opt(IDL.Nat64),
        controller: IDL.Opt(IDL.Principal),
        recent_ballots: IDL.Vec(BallotInfo),
        kyc_verified: IDL.Bool,
        not_for_profit: IDL.Bool,
        maturity_e8s_equivalent: IDL.Nat64,
        cached_neuron_stake_e8s: IDL.Nat64,
        created_timestamp_seconds: IDL.Nat64,
        auto_stake_maturity: IDL.Opt(IDL.Bool),
        aging_since_timestamp_seconds: IDL.Nat64,
        hot_keys: IDL.Vec(IDL.Principal),
        account: IDL.Vec(IDL.Nat8),
        joined_community_fund_timestamp_seconds: IDL.Opt(IDL.Nat64),
        dissolve_state: IDL.Opt(DissolveState),
        followees: IDL.Vec(IDL.Tuple(IDL.Int32, Followees)),
        neuron_fees_e8s: IDL.Nat64,
        transfer: IDL.Opt(NeuronStakeTransfer),
        known_neuron_data: IDL.Opt(KnownNeuronData),
        spawn_at_timestamp_seconds: IDL.Opt(IDL.Nat64),
    });
    const Governance = IDL.Record({
        default_followees: IDL.Vec(IDL.Tuple(IDL.Int32, Followees)),
        most_recent_monthly_node_provider_rewards: IDL.Opt(
            MostRecentMonthlyNodeProviderRewards
        ),
        maturity_modulation_last_updated_at_timestamp_seconds: IDL.Opt(IDL.Nat64),
        wait_for_quiet_threshold_seconds: IDL.Nat64,
        metrics: IDL.Opt(GovernanceCachedMetrics),
        node_providers: IDL.Vec(NodeProvider),
        cached_daily_maturity_modulation_basis_points: IDL.Opt(IDL.Int32),
        economics: IDL.Opt(NetworkEconomics),
        spawning_neurons: IDL.Opt(IDL.Bool),
        latest_reward_event: IDL.Opt(RewardEvent),
        to_claim_transfers: IDL.Vec(NeuronStakeTransfer),
        short_voting_period_seconds: IDL.Nat64,
        proposals: IDL.Vec(IDL.Tuple(IDL.Nat64, ProposalData)),
        in_flight_commands: IDL.Vec(IDL.Tuple(IDL.Nat64, NeuronInFlightCommand)),
        neurons: IDL.Vec(IDL.Tuple(IDL.Nat64, Neuron)),
        genesis_timestamp_seconds: IDL.Nat64,
    });
    const Result = IDL.Variant({ Ok: IDL.Null, Err: GovernanceError });
    const Result_1 = IDL.Variant({
        Error: GovernanceError,
        NeuronId: NeuronId,
    });
    const ClaimOrRefreshNeuronFromAccountResponse = IDL.Record({
        result: IDL.Opt(Result_1),
    });
    const Result_2 = IDL.Variant({ Ok: Neuron, Err: GovernanceError });
    const Result_3 = IDL.Variant({
        Ok: RewardNodeProviders,
        Err: GovernanceError,
    });
    const NeuronInfo = IDL.Record({
        dissolve_delay_seconds: IDL.Nat64,
        recent_ballots: IDL.Vec(BallotInfo),
        created_timestamp_seconds: IDL.Nat64,
        state: IDL.Int32,
        stake_e8s: IDL.Nat64,
        joined_community_fund_timestamp_seconds: IDL.Opt(IDL.Nat64),
        retrieved_at_timestamp_seconds: IDL.Nat64,
        known_neuron_data: IDL.Opt(KnownNeuronData),
        voting_power: IDL.Nat64,
        age_seconds: IDL.Nat64,
    });
    const Result_4 = IDL.Variant({ Ok: NeuronInfo, Err: GovernanceError });
    const Result_5 = IDL.Variant({
        Ok: NodeProvider,
        Err: GovernanceError,
    });
    const ProposalInfo = IDL.Record({
        id: IDL.Opt(NeuronId),
        status: IDL.Int32,
        topic: IDL.Int32,
        failure_reason: IDL.Opt(GovernanceError),
        ballots: IDL.Vec(IDL.Tuple(IDL.Nat64, Ballot)),
        proposal_timestamp_seconds: IDL.Nat64,
        reward_event_round: IDL.Nat64,
        deadline_timestamp_seconds: IDL.Opt(IDL.Nat64),
        failed_timestamp_seconds: IDL.Nat64,
        reject_cost_e8s: IDL.Nat64,
        latest_tally: IDL.Opt(Tally),
        reward_status: IDL.Int32,
        decided_timestamp_seconds: IDL.Nat64,
        proposal: IDL.Opt(Proposal),
        proposer: IDL.Opt(NeuronId),
        executed_timestamp_seconds: IDL.Nat64,
    });
    const ListKnownNeuronsResponse = IDL.Record({
        known_neurons: IDL.Vec(KnownNeuron),
    });
    const ListNeurons = IDL.Record({
        neuron_ids: IDL.Vec(IDL.Nat64),
        include_neurons_readable_by_caller: IDL.Bool,
    });
    const ListNeuronsResponse = IDL.Record({
        neuron_infos: IDL.Vec(IDL.Tuple(IDL.Nat64, NeuronInfo)),
        full_neurons: IDL.Vec(Neuron),
    });
    const ListNodeProvidersResponse = IDL.Record({
        node_providers: IDL.Vec(NodeProvider),
    });
    const ListProposalInfo = IDL.Record({
        include_reward_status: IDL.Vec(IDL.Int32),
        before_proposal: IDL.Opt(NeuronId),
        limit: IDL.Nat32,
        exclude_topic: IDL.Vec(IDL.Int32),
        include_status: IDL.Vec(IDL.Int32),
    });
    const ListProposalInfoResponse = IDL.Record({
        proposal_info: IDL.Vec(ProposalInfo),
    });
    const SpawnResponse = IDL.Record({ created_neuron_id: IDL.Opt(NeuronId) });
    const ClaimOrRefreshResponse = IDL.Record({
        refreshed_neuron_id: IDL.Opt(NeuronId),
    });
    const MakeProposalResponse = IDL.Record({
        proposal_id: IDL.Opt(NeuronId),
    });
    const StakeMaturityResponse = IDL.Record({
        maturity_e8s: IDL.Nat64,
        staked_maturity_e8s: IDL.Nat64,
    });
    const MergeMaturityResponse = IDL.Record({
        merged_maturity_e8s: IDL.Nat64,
        new_stake_e8s: IDL.Nat64,
    });
    const DisburseResponse = IDL.Record({ transfer_block_height: IDL.Nat64 });
    const Command_1 = IDL.Variant({
        Error: GovernanceError,
        Spawn: SpawnResponse,
        Split: SpawnResponse,
        Follow: IDL.Record({}),
        ClaimOrRefresh: ClaimOrRefreshResponse,
        Configure: IDL.Record({}),
        RegisterVote: IDL.Record({}),
        Merge: IDL.Record({}),
        DisburseToNeuron: SpawnResponse,
        MakeProposal: MakeProposalResponse,
        StakeMaturity: StakeMaturityResponse,
        MergeMaturity: MergeMaturityResponse,
        Disburse: DisburseResponse,
    });
    const ManageNeuronResponse = IDL.Record({ command: IDL.Opt(Command_1) });
    const Committed = IDL.Record({
        sns_governance_canister_id: IDL.Opt(IDL.Principal),
    });
    const Result_6 = IDL.Variant({
        Committed: Committed,
        Aborted: IDL.Record({}),
    });
    const SettleCommunityFundParticipation = IDL.Record({
        result: IDL.Opt(Result_6),
        open_sns_token_swap_proposal_id: IDL.Opt(IDL.Nat64),
    });
    const UpdateNodeProvider = IDL.Record({
        reward_account: IDL.Opt(AccountIdentifier),
    });
    return IDL.Service({
        claim_gtc_neurons: IDL.Func(
            [IDL.Principal, IDL.Vec(NeuronId)],
            [Result],
            []
        ),
        claim_or_refresh_neuron_from_account: IDL.Func(
            [ClaimOrRefreshNeuronFromAccount],
            [ClaimOrRefreshNeuronFromAccountResponse],
            []
        ),
        get_build_metadata: IDL.Func([], [IDL.Text], ["query"]),
        get_full_neuron: IDL.Func([IDL.Nat64], [Result_2], ["query"]),
        get_full_neuron_by_id_or_subaccount: IDL.Func(
            [NeuronIdOrSubaccount],
            [Result_2],
            ["query"]
        ),
        get_monthly_node_provider_rewards: IDL.Func([], [Result_3], []),
        get_most_recent_monthly_node_provider_rewards: IDL.Func(
            [],
            [IDL.Opt(MostRecentMonthlyNodeProviderRewards)],
            ["query"]
        ),
        get_network_economics_parameters: IDL.Func(
            [],
            [NetworkEconomics],
            ["query"]
        ),
        get_neuron_ids: IDL.Func([], [IDL.Vec(IDL.Nat64)], ["query"]),
        get_neuron_info: IDL.Func([IDL.Nat64], [Result_4], ["query"]),
        get_neuron_info_by_id_or_subaccount: IDL.Func(
            [NeuronIdOrSubaccount],
            [Result_4],
            ["query"]
        ),
        get_node_provider_by_caller: IDL.Func([IDL.Null], [Result_5], ["query"]),
        get_pending_proposals: IDL.Func([], [IDL.Vec(ProposalInfo)], ["query"]),
        get_proposal_info: IDL.Func(
            [IDL.Nat64],
            [IDL.Opt(ProposalInfo)],
            ["query"]
        ),
        list_known_neurons: IDL.Func([], [ListKnownNeuronsResponse], ["query"]),
        list_neurons: IDL.Func([ListNeurons], [ListNeuronsResponse], ["query"]),
        list_node_providers: IDL.Func([], [ListNodeProvidersResponse], ["query"]),
        list_proposals: IDL.Func(
            [ListProposalInfo],
            [ListProposalInfoResponse],
            ["query"]
        ),
        manage_neuron: IDL.Func([ManageNeuron], [ManageNeuronResponse], []),
        settle_community_fund_participation: IDL.Func(
            [SettleCommunityFundParticipation],
            [Result],
            []
        ),
        transfer_gtc_neuron: IDL.Func([NeuronId, NeuronId], [Result], []),
        update_node_provider: IDL.Func([UpdateNodeProvider], [Result], []),
    });
};
export const init = ({ IDL }) => {
    const Proposal = IDL.Rec();
    const NeuronId = IDL.Record({ id: IDL.Nat64 });
    const Followees = IDL.Record({ followees: IDL.Vec(NeuronId) });
    const AccountIdentifier = IDL.Record({ hash: IDL.Vec(IDL.Nat8) });
    const NodeProvider = IDL.Record({
        id: IDL.Opt(IDL.Principal),
        reward_account: IDL.Opt(AccountIdentifier),
    });
    const RewardToNeuron = IDL.Record({ dissolve_delay_seconds: IDL.Nat64 });
    const RewardToAccount = IDL.Record({
        to_account: IDL.Opt(AccountIdentifier),
    });
    const RewardMode = IDL.Variant({
        RewardToNeuron: RewardToNeuron,
        RewardToAccount: RewardToAccount,
    });
    const RewardNodeProvider = IDL.Record({
        node_provider: IDL.Opt(NodeProvider),
        reward_mode: IDL.Opt(RewardMode),
        amount_e8s: IDL.Nat64,
    });
    const MostRecentMonthlyNodeProviderRewards = IDL.Record({
        timestamp: IDL.Nat64,
        rewards: IDL.Vec(RewardNodeProvider),
    });
    const GovernanceCachedMetrics = IDL.Record({
        not_dissolving_neurons_e8s_buckets: IDL.Vec(
            IDL.Tuple(IDL.Nat64, IDL.Float64)
        ),
        garbage_collectable_neurons_count: IDL.Nat64,
        neurons_with_invalid_stake_count: IDL.Nat64,
        not_dissolving_neurons_count_buckets: IDL.Vec(
            IDL.Tuple(IDL.Nat64, IDL.Nat64)
        ),
        total_supply_icp: IDL.Nat64,
        neurons_with_less_than_6_months_dissolve_delay_count: IDL.Nat64,
        dissolved_neurons_count: IDL.Nat64,
        total_staked_e8s: IDL.Nat64,
        not_dissolving_neurons_count: IDL.Nat64,
        dissolved_neurons_e8s: IDL.Nat64,
        neurons_with_less_than_6_months_dissolve_delay_e8s: IDL.Nat64,
        dissolving_neurons_count_buckets: IDL.Vec(IDL.Tuple(IDL.Nat64, IDL.Nat64)),
        dissolving_neurons_count: IDL.Nat64,
        dissolving_neurons_e8s_buckets: IDL.Vec(IDL.Tuple(IDL.Nat64, IDL.Float64)),
        community_fund_total_staked_e8s: IDL.Nat64,
        timestamp_seconds: IDL.Nat64,
    });
    const NetworkEconomics = IDL.Record({
        neuron_minimum_stake_e8s: IDL.Nat64,
        max_proposals_to_keep_per_topic: IDL.Nat32,
        neuron_management_fee_per_proposal_e8s: IDL.Nat64,
        reject_cost_e8s: IDL.Nat64,
        transaction_fee_e8s: IDL.Nat64,
        neuron_spawn_dissolve_delay_seconds: IDL.Nat64,
        minimum_icp_xdr_rate: IDL.Nat64,
        maximum_node_provider_rewards_e8s: IDL.Nat64,
    });
    const RewardEvent = IDL.Record({
        day_after_genesis: IDL.Nat64,
        actual_timestamp_seconds: IDL.Nat64,
        distributed_e8s_equivalent: IDL.Nat64,
        settled_proposals: IDL.Vec(NeuronId),
    });
    const NeuronStakeTransfer = IDL.Record({
        to_subaccount: IDL.Vec(IDL.Nat8),
        neuron_stake_e8s: IDL.Nat64,
        from: IDL.Opt(IDL.Principal),
        memo: IDL.Nat64,
        from_subaccount: IDL.Vec(IDL.Nat8),
        transfer_timestamp: IDL.Nat64,
        block_height: IDL.Nat64,
    });
    const GovernanceError = IDL.Record({
        error_message: IDL.Text,
        error_type: IDL.Int32,
    });
    const CfNeuron = IDL.Record({
        nns_neuron_id: IDL.Nat64,
        amount_icp_e8s: IDL.Nat64,
    });
    const CfParticipant = IDL.Record({
        hotkey_principal: IDL.Text,
        cf_neurons: IDL.Vec(CfNeuron),
    });
    const Ballot = IDL.Record({ vote: IDL.Int32, voting_power: IDL.Nat64 });
    const Tally = IDL.Record({
        no: IDL.Nat64,
        yes: IDL.Nat64,
        total: IDL.Nat64,
        timestamp_seconds: IDL.Nat64,
    });
    const KnownNeuronData = IDL.Record({
        name: IDL.Text,
        description: IDL.Opt(IDL.Text),
    });
    const KnownNeuron = IDL.Record({
        id: IDL.Opt(NeuronId),
        known_neuron_data: IDL.Opt(KnownNeuronData),
    });
    const Spawn = IDL.Record({
        percentage_to_spawn: IDL.Opt(IDL.Nat32),
        new_controller: IDL.Opt(IDL.Principal),
        nonce: IDL.Opt(IDL.Nat64),
    });
    const Split = IDL.Record({ amount_e8s: IDL.Nat64 });
    const Follow = IDL.Record({
        topic: IDL.Int32,
        followees: IDL.Vec(NeuronId),
    });
    const ClaimOrRefreshNeuronFromAccount = IDL.Record({
        controller: IDL.Opt(IDL.Principal),
        memo: IDL.Nat64,
    });
    const By = IDL.Variant({
        NeuronIdOrSubaccount: IDL.Record({}),
        MemoAndController: ClaimOrRefreshNeuronFromAccount,
        Memo: IDL.Nat64,
    });
    const ClaimOrRefresh = IDL.Record({ by: IDL.Opt(By) });
    const RemoveHotKey = IDL.Record({
        hot_key_to_remove: IDL.Opt(IDL.Principal),
    });
    const AddHotKey = IDL.Record({ new_hot_key: IDL.Opt(IDL.Principal) });
    const ChangeAutoStakeMaturity = IDL.Record({
        requested_setting_for_auto_stake_maturity: IDL.Bool,
    });
    const IncreaseDissolveDelay = IDL.Record({
        additional_dissolve_delay_seconds: IDL.Nat32,
    });
    const SetDissolveTimestamp = IDL.Record({
        dissolve_timestamp_seconds: IDL.Nat64,
    });
    const Operation = IDL.Variant({
        RemoveHotKey: RemoveHotKey,
        AddHotKey: AddHotKey,
        ChangeAutoStakeMaturity: ChangeAutoStakeMaturity,
        StopDissolving: IDL.Record({}),
        StartDissolving: IDL.Record({}),
        IncreaseDissolveDelay: IncreaseDissolveDelay,
        JoinCommunityFund: IDL.Record({}),
        LeaveCommunityFund: IDL.Record({}),
        SetDissolveTimestamp: SetDissolveTimestamp,
    });
    const Configure = IDL.Record({ operation: IDL.Opt(Operation) });
    const RegisterVote = IDL.Record({
        vote: IDL.Int32,
        proposal: IDL.Opt(NeuronId),
    });
    const Merge = IDL.Record({ source_neuron_id: IDL.Opt(NeuronId) });
    const DisburseToNeuron = IDL.Record({
        dissolve_delay_seconds: IDL.Nat64,
        kyc_verified: IDL.Bool,
        amount_e8s: IDL.Nat64,
        new_controller: IDL.Opt(IDL.Principal),
        nonce: IDL.Nat64,
    });
    const StakeMaturity = IDL.Record({
        percentage_to_stake: IDL.Opt(IDL.Nat32),
    });
    const MergeMaturity = IDL.Record({ percentage_to_merge: IDL.Nat32 });
    const Amount = IDL.Record({ e8s: IDL.Nat64 });
    const Disburse = IDL.Record({
        to_account: IDL.Opt(AccountIdentifier),
        amount: IDL.Opt(Amount),
    });
    const Command = IDL.Variant({
        Spawn: Spawn,
        Split: Split,
        Follow: Follow,
        ClaimOrRefresh: ClaimOrRefresh,
        Configure: Configure,
        RegisterVote: RegisterVote,
        Merge: Merge,
        DisburseToNeuron: DisburseToNeuron,
        MakeProposal: Proposal,
        StakeMaturity: StakeMaturity,
        MergeMaturity: MergeMaturity,
        Disburse: Disburse,
    });
    const NeuronIdOrSubaccount = IDL.Variant({
        Subaccount: IDL.Vec(IDL.Nat8),
        NeuronId: NeuronId,
    });
    const ManageNeuron = IDL.Record({
        id: IDL.Opt(NeuronId),
        command: IDL.Opt(Command),
        neuron_id_or_subaccount: IDL.Opt(NeuronIdOrSubaccount),
    });
    const ExecuteNnsFunction = IDL.Record({
        nns_function: IDL.Int32,
        payload: IDL.Vec(IDL.Nat8),
    });
    const Params = IDL.Record({
        min_participant_icp_e8s: IDL.Nat64,
        max_icp_e8s: IDL.Nat64,
        swap_due_timestamp_seconds: IDL.Nat64,
        min_participants: IDL.Nat32,
        sns_token_e8s: IDL.Nat64,
        max_participant_icp_e8s: IDL.Nat64,
        min_icp_e8s: IDL.Nat64,
    });
    const OpenSnsTokenSwap = IDL.Record({
        community_fund_investment_e8s: IDL.Opt(IDL.Nat64),
        target_swap_canister_id: IDL.Opt(IDL.Principal),
        params: IDL.Opt(Params),
    });
    const TimeWindow = IDL.Record({
        start_timestamp_seconds: IDL.Nat64,
        end_timestamp_seconds: IDL.Nat64,
    });
    const SetOpenTimeWindowRequest = IDL.Record({
        open_time_window: IDL.Opt(TimeWindow),
    });
    const SetSnsTokenSwapOpenTimeWindow = IDL.Record({
        request: IDL.Opt(SetOpenTimeWindowRequest),
        swap_canister_id: IDL.Opt(IDL.Principal),
    });
    const SetDefaultFollowees = IDL.Record({
        default_followees: IDL.Vec(IDL.Tuple(IDL.Int32, Followees)),
    });
    const RewardNodeProviders = IDL.Record({
        use_registry_derived_rewards: IDL.Opt(IDL.Bool),
        rewards: IDL.Vec(RewardNodeProvider),
    });
    const ApproveGenesisKyc = IDL.Record({
        principals: IDL.Vec(IDL.Principal),
    });
    const Change = IDL.Variant({
        ToRemove: NodeProvider,
        ToAdd: NodeProvider,
    });
    const AddOrRemoveNodeProvider = IDL.Record({ change: IDL.Opt(Change) });
    const Motion = IDL.Record({ motion_text: IDL.Text });
    const Action = IDL.Variant({
        RegisterKnownNeuron: KnownNeuron,
        ManageNeuron: ManageNeuron,
        ExecuteNnsFunction: ExecuteNnsFunction,
        RewardNodeProvider: RewardNodeProvider,
        OpenSnsTokenSwap: OpenSnsTokenSwap,
        SetSnsTokenSwapOpenTimeWindow: SetSnsTokenSwapOpenTimeWindow,
        SetDefaultFollowees: SetDefaultFollowees,
        RewardNodeProviders: RewardNodeProviders,
        ManageNetworkEconomics: NetworkEconomics,
        ApproveGenesisKyc: ApproveGenesisKyc,
        AddOrRemoveNodeProvider: AddOrRemoveNodeProvider,
        Motion: Motion,
    });
    Proposal.fill(
        IDL.Record({
            url: IDL.Text,
            title: IDL.Opt(IDL.Text),
            action: IDL.Opt(Action),
            summary: IDL.Text,
        })
    );
    const WaitForQuietState = IDL.Record({
        current_deadline_timestamp_seconds: IDL.Nat64,
    });
    const ProposalData = IDL.Record({
        id: IDL.Opt(NeuronId),
        failure_reason: IDL.Opt(GovernanceError),
        cf_participants: IDL.Vec(CfParticipant),
        ballots: IDL.Vec(IDL.Tuple(IDL.Nat64, Ballot)),
        proposal_timestamp_seconds: IDL.Nat64,
        reward_event_round: IDL.Nat64,
        failed_timestamp_seconds: IDL.Nat64,
        reject_cost_e8s: IDL.Nat64,
        latest_tally: IDL.Opt(Tally),
        sns_token_swap_lifecycle: IDL.Opt(IDL.Int32),
        decided_timestamp_seconds: IDL.Nat64,
        proposal: IDL.Opt(Proposal),
        proposer: IDL.Opt(NeuronId),
        wait_for_quiet_state: IDL.Opt(WaitForQuietState),
        executed_timestamp_seconds: IDL.Nat64,
        original_total_community_fund_maturity_e8s_equivalent: IDL.Opt(IDL.Nat64),
    });
    const Command_2 = IDL.Variant({
        Spawn: NeuronId,
        Split: Split,
        Configure: Configure,
        Merge: Merge,
        DisburseToNeuron: DisburseToNeuron,
        SyncCommand: IDL.Record({}),
        ClaimOrRefreshNeuron: ClaimOrRefresh,
        MergeMaturity: MergeMaturity,
        Disburse: Disburse,
    });
    const NeuronInFlightCommand = IDL.Record({
        command: IDL.Opt(Command_2),
        timestamp: IDL.Nat64,
    });
    const BallotInfo = IDL.Record({
        vote: IDL.Int32,
        proposal_id: IDL.Opt(NeuronId),
    });
    const DissolveState = IDL.Variant({
        DissolveDelaySeconds: IDL.Nat64,
        WhenDissolvedTimestampSeconds: IDL.Nat64,
    });
    const Neuron = IDL.Record({
        id: IDL.Opt(NeuronId),
        staked_maturity_e8s_equivalent: IDL.Opt(IDL.Nat64),
        controller: IDL.Opt(IDL.Principal),
        recent_ballots: IDL.Vec(BallotInfo),
        kyc_verified: IDL.Bool,
        not_for_profit: IDL.Bool,
        maturity_e8s_equivalent: IDL.Nat64,
        cached_neuron_stake_e8s: IDL.Nat64,
        created_timestamp_seconds: IDL.Nat64,
        auto_stake_maturity: IDL.Opt(IDL.Bool),
        aging_since_timestamp_seconds: IDL.Nat64,
        hot_keys: IDL.Vec(IDL.Principal),
        account: IDL.Vec(IDL.Nat8),
        joined_community_fund_timestamp_seconds: IDL.Opt(IDL.Nat64),
        dissolve_state: IDL.Opt(DissolveState),
        followees: IDL.Vec(IDL.Tuple(IDL.Int32, Followees)),
        neuron_fees_e8s: IDL.Nat64,
        transfer: IDL.Opt(NeuronStakeTransfer),
        known_neuron_data: IDL.Opt(KnownNeuronData),
        spawn_at_timestamp_seconds: IDL.Opt(IDL.Nat64),
    });
    const Governance = IDL.Record({
        default_followees: IDL.Vec(IDL.Tuple(IDL.Int32, Followees)),
        most_recent_monthly_node_provider_rewards: IDL.Opt(
            MostRecentMonthlyNodeProviderRewards
        ),
        maturity_modulation_last_updated_at_timestamp_seconds: IDL.Opt(IDL.Nat64),
        wait_for_quiet_threshold_seconds: IDL.Nat64,
        metrics: IDL.Opt(GovernanceCachedMetrics),
        node_providers: IDL.Vec(NodeProvider),
        cached_daily_maturity_modulation_basis_points: IDL.Opt(IDL.Int32),
        economics: IDL.Opt(NetworkEconomics),
        spawning_neurons: IDL.Opt(IDL.Bool),
        latest_reward_event: IDL.Opt(RewardEvent),
        to_claim_transfers: IDL.Vec(NeuronStakeTransfer),
        short_voting_period_seconds: IDL.Nat64,
        proposals: IDL.Vec(IDL.Tuple(IDL.Nat64, ProposalData)),
        in_flight_commands: IDL.Vec(IDL.Tuple(IDL.Nat64, NeuronInFlightCommand)),
        neurons: IDL.Vec(IDL.Tuple(IDL.Nat64, Neuron)),
        genesis_timestamp_seconds: IDL.Nat64,
    });
    return [Governance];
};