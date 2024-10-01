# Validate Canister

This is the standalone validate rust canister for the verifier project. It is responsible for validating the credentials and presentations.

Create a new validate canister:

```bash
dfx canister create validate
```

Add the following to your `dfx.json` file:

```json
"validate": {
            "type": "rust",
            "package": "validate",
            "candid": "src/rust/validate/validate.did"
        },
```

Generate the candid interface:

```bash
./scripts/did.sh
```

Build the validate canister:

```bash
dfx build validate
```

Deploy the validate canister:

```bash
dfx deploy validate
```

## Initialize the Canister (and Admin)

The validate canister needs to be initialized with the following arguments, initial admin also set to the principal of the person configuring the canister:

```bash
./scripts/set-validate-config.sh
```

## Issuer


Then you can call to add issuers (support multiple issuers):

```bash
DFX_NETWORK="local"
ISSUER_CANISTER_ID="rdmx6-jaaaa-aaaaa-aaadq-cai"

dfx canister call validate add_issuer '(record { issuer = principal "'"$ISSUER_CANISTER_ID"'"; credential_spec = vec {} })' --network "$DFX_NETWORK"
```
