# Issuer Canister

This is the standalone issuer rust canister for the verifier project. It is responsible for issuing verifiable credentials based on the wallet score. 

See the issuer documentation for more details: [Become an issuer](https://internetcomputer.org/docs/current/developer-docs/identity/verifiable-credentials/issuer)

Create a new issuer canister:

```bash
dfx canister create issuer
```

Add the following to your `dfx.json` file:

```json
"issuer": {
    "type": "rust",
    "package": "issuer",
    "candid": "src/rust/issuer/issuer.did"
},
```

Generate the candid interface:

```bash
./scripts/did.sh
```

Build the issuer canister:

```bash
dfx build issuer
```

Deploy the issuer canister:

```bash
dfx deploy issuer
```

## Initialize

The issuer canister needs to be initialized with the following arguments, initial admin also set to the principal of the person configuring the canister:

```bash
./scripts/deploy-issuer-canister.sh
```
