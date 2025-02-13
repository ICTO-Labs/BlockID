#!/usr/bin/env bash

set -euo pipefail

#########
# USAGE #
#########

function title() {
    echo "Deploying issuer canister" >&2
}

function usage() {
    cat >&2 << EOF

Usage:
  $0 [--ii-canister-id CANISTER_ID] [--dfx-network NETWORK]

Options:
  --ii-canister-id CANISTER_ID  The canister ID to use as IDP, defaults to the local internet_identity canister
  --dfx-network NETWORK         The network to use (typically "local" or "ic"), defaults to "local"
  --issuer-canister-id CANISTER The canister ID to deploy, gets it from "dfx canister id early_adopter" if not provided"
EOF
}

function help() {
    cat >&2 << EOF

The issuer canister needs some information to operate correctly. This reads data
from the replica to ensure the issuer is provisioned correctly.
EOF
}

II_CANISTER_ID=
DFX_NETWORK=

while [[ $# -gt 0  ]]
do
    case "$1" in
        -h|--help)
            title
            usage
            help
            exit 0
            ;;
        --ii-canister-id)
            II_CANISTER_ID="${2:?missing value for '--ii-canister-id'}"
            shift; # shift past --ii-canister-id & value
            shift;
            ;;
        --dfx-network)
            DFX_NETWORK="${2:?missing value for '--dfx-network'}"
            shift; # shift past --dfx-network & value
            shift;
            ;;
        --issuer-canister)
            ISSUER_CANISTER_ID="${2:?missing value for '--issuer-canister-id'}"
            shift; # shift past --issuer-canister & value
            shift;
            ;;
        *)
            echo "ERROR: unknown argument $1"
            usage
            echo
            echo "Use '$0 --help' for more information"
            exit 1
            ;;
    esac
done

DFX_NETWORK="${DFX_NETWORK:-local}"
II_CANISTER_ID="${II_CANISTER_ID:-$(dfx canister id internet_identity --network "$DFX_NETWORK")}"
ISSUER_CANISTER_ID="${ISSUER_CANISTER_ID:-$(dfx canister id issuer --network "$DFX_NETWORK")}"
if [ "$DFX_NETWORK" = "local" ]; then
  REPLICA_SERVER_PORT=$(dfx info webserver-port)
  ISSUER_DERIVATION_ORIGIN="http://${ISSUER_CANISTER_ID}.localhost:${REPLICA_SERVER_PORT}"
  ISSUER_FRONTEND_HOSTNAME="http://${ISSUER_CANISTER_ID}.localhost:${REPLICA_SERVER_PORT}"
fi
if [ "$DFX_NETWORK" = "ic" ]; then
  ISSUER_DERIVATION_ORIGIN="https://y3yam-6aaaa-aaaap-qb7aq-cai.icp0.io"
  ISSUER_FRONTEND_HOSTNAME="https://blockid.cc"
fi
if [ "$DFX_NETWORK" = "ic_test" ]; then
  ISSUER_DERIVATION_ORIGIN="https://${ISSUER_CANISTER_ID}.icp0.io"
  ISSUER_FRONTEND_HOSTNAME="https://${ISSUER_CANISTER_ID}.icp0.io"
fi

echo "Using DFX network: $DFX_NETWORK" >&2
echo "Using II canister: $II_CANISTER_ID" >&2
echo "Using issuer canister: $ISSUER_CANISTER_ID" >&2
echo "Using derivation origin: $ISSUER_DERIVATION_ORIGIN" >&2
echo "Using frontend hostname: $ISSUER_FRONTEND_HOSTNAME" >&2

# At the time of writing dfx outputs incorrect JSON with dfx ping (commas between object
# entries are missing).
# In order to read the root key we grab the array from the '"root_key": [...]' bit, the brackets
# to match what candid expects ({}), replace the commas between array entries to match
# what candid expects (semicolon) and annotate the numbers with their type (otherwise dfx assumes 'nat'
# instead of 'nat8').
rootkey_did=$(dfx ping "$DFX_NETWORK" \
    | sed -n 's/.*"root_key": \[\(.*\)\].*/{\1}/p' \
    | sed 's/\([0-9][0-9]*\)/\1:nat8/g' \
    | sed 's/,/;/g')

echo "Parsed rootkey: ${rootkey_did:0:20}..." >&2

echo "Using II canister: $II_CANISTER_ID" >&2

dfx deploy issuer --network "$DFX_NETWORK" --argument '(opt record { idp_canister_ids = vec{ principal "'"$II_CANISTER_ID"'" }; ic_root_key_der = vec '"$rootkey_did"'; derivation_origin = "'"$ISSUER_DERIVATION_ORIGIN"'"; frontend_hostname = "'"$ISSUER_FRONTEND_HOSTNAME"'"; })'

# add an event
# dfx canister call issuer add_event '(record { event_name = "TEST"; registration_code = opt "9999" })'


# register a user
# dfx canister call issuer register_early_adopter '(record {event_data: opt record {event_name = "TEST"; registration_code = opt "9999"}})'