#!/usr/bin/env bash

./scripts/did.sh
dfx deploy validate
./scripts/set-validate-config.sh
dfx canister call validate  set_remote_canister_id '(principal "cbopz-duaaa-aaaaa-qaaka-cai")'
echo "Done!"