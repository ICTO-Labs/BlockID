import { Actor } from "@dfinity/agent"

export async function createBaseActor({
    canisterId,
    idlFactory,
    actorOptions,
    agent,
    fetchRootKey = true
}) {
    // Fetch root key for certificate validation during development
    if (fetchRootKey) {
        await agent?.fetchRootKey().catch(err => {
            console.warn(
                "Unable to fetch root key. Check to ensure that your local replica is running"
            )
            console.error(err)
        })
    }

    return Actor.createActor(idlFactory, {
        agent: agent,
        canisterId,
        ...(actorOptions ?? {})
    })
}