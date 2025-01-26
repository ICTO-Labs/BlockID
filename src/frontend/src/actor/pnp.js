
import { createPNP, walletsList } from "@windoge98/plug-n-play";
import { IS_DEV, WHITELIST, END_POINT, DERIVATION_ORIGIN } from "@/config";
import { Principal } from "@dfinity/principal";

let globalPnp = null;

export function initializePNP() {
    try {
        if (globalPnp) {
            return globalPnp;
        }

        // Convert all canister IDs to Principal, but only if they are defined
        const delegationTargets = WHITELIST.map(canisterId => Principal.fromText(canisterId));

        globalPnp = createPNP({
            hostUrl: END_POINT,
            isDev: IS_DEV,
            whitelist: WHITELIST,
            fetchRootKeys: IS_DEV,
            timeout: 1000 * 60 * 60 * 4, // 4 hours
            verifyQuerySignatures: !IS_DEV,
            identityProvider:
                !IS_DEV
                    ? "https://identity.ic0.app"
                    : "http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:4943",
            persistSession: true,
            derivationOrigin: DERIVATION_ORIGIN,
            delegationTimeout: BigInt(7 * 24 * 60 * 60 * 1000_000_000), // 7 days
            delegationTargets: [],
        });

        return globalPnp;
    } catch (error) {
        console.error("Error initializing PNP:", error);
        throw error;
    }
}

export function getPnpInstance() {
    if (!globalPnp) {
        return initializePNP();
    }
    return globalPnp;
}

export const pnp = getPnpInstance();