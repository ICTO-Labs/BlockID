#!/usr/bin/env bash
> .env
if [[ "${VITE_ENV}" == "production" ]]; then
    echo "VITE_FRONTEND_CANISTER_ID=$(dfx canister id frontend --network ic)" >> .env
    echo "VITE_BACKEND_CANISTER_ID=$(dfx canister id backend --network ic)" >> .env
    echo "VITE_VALIDATE_CANISTER_ID=$(dfx canister id validate --network ic)" >> .env
    echo "VITE_MARKETPLACE_CANISTER_ID=$(dfx canister id marketplace --network ic)" >> .env
    # echo "VITE_INTERNET_IDENTITY_CANISTER_ID=$(dfx canister id internet_identity --network ic)" >> .env
    echo "VITE_HOST=icp0.io" >> .env
    echo "VITE_DERIVATION_ORIGIN=https://$(dfx canister id frontend --network ic).icp0.io" >> .env
    echo "VITE_ALTERNATIVE_ORIGINS=https://blockid.cc" >> .env
else
    echo "VITE_FRONTEND_CANISTER_ID=$(dfx canister id frontend)" >> .env
    echo "VITE_BACKEND_CANISTER_ID=$(dfx canister id backend)" >> .env
    echo "VITE_VALIDATE_CANISTER_ID=$(dfx canister id validate)" >> .env
    echo "VITE_MARKETPLACE_CANISTER_ID=$(dfx canister id marketplace)" >> .env
    # echo "VITE_INTERNET_IDENTITY_CANISTER_ID=$(dfx canister id internet_identity)" >> .env
    echo "VITE_HOST=localhost:4943" >> .env
    echo "VITE_DERIVATION_ORIGIN=http://$(dfx canister id frontend).localhost:4943" >> .env
    echo "VITE_ALTERNATIVE_ORIGINS=http://$(dfx canister id frontend).localhost:4943" >> .env
fi