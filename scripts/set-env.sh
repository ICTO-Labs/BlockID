#!/usr/bin/env bash
if [[ "${VITE_ENV}" == "production" ]]; then
    export VITE_FRONTEND_CANISTER_ID=$(dfx canister id frontend --network ic)
    export VITE_BACKEND_CANISTER_ID=$(dfx canister id backend --network ic)
    export VITE_VALIDATE_CANISTER_ID=$(dfx canister id validate --network ic)
    export VITE_INTERNET_IDENTITY_CANISTER_ID=$(dfx canister id internet_identity --network ic)
    export VITE_HOST=icp0.io
    export VITE_DERIVATION_ORIGIN=https://$(dfx canister id frontend --network ic).icp0.io
    export VITE_ALTERNATIVE_ORIGINS=https://blockid.cc
else
    export VITE_FRONTEND_CANISTER_ID=$(dfx canister id frontend)
    export VITE_BACKEND_CANISTER_ID=$(dfx canister id backend)
    export VITE_VALIDATE_CANISTER_ID=$(dfx canister id validate)
    export VITE_INTERNET_IDENTITY_CANISTER_ID=$(dfx canister id internet_identity)
    export VITE_HOST=localhost:4943
    export VITE_DERIVATION_ORIGIN=http://$(dfx canister id frontend).localhost:4943
    export VITE_ALTERNATIVE_ORIGINS=http://$(dfx canister id frontend).localhost:4943
fi

# Verify the variables are set
echo "VITE_FRONTEND_CANISTER_ID=$VITE_FRONTEND_CANISTER_ID"
echo "VITE_BACKEND_CANISTER_ID=$VITE_BACKEND_CANISTER_ID"
echo "VITE_VALIDATE_CANISTER_ID=$VITE_VALIDATE_CANISTER_ID"
echo "VITE_INTERNET_IDENTITY_CANISTER_ID=$VITE_INTERNET_IDENTITY_CANISTER_ID"
echo "VITE_HOST=$VITE_HOST"
echo "VITE_ENV=$VITE_ENV"
echo "VITE_DERIVATION_ORIGIN=$VITE_DERIVATION_ORIGIN"
echo "VITE_ALTERNATIVE_ORIGINS=$VITE_ALTERNATIVE_ORIGINS"