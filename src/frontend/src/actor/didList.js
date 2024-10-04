import icIDL from '@/actor/did/ic.did';
import icrc1IDL from '@/actor/did/icrc1.did';

import {idlFactory as backendIDL} from '@/../../declarations/backend';

export const preloadIdls = {
    'IC': icIDL,
    'icrc1' : icrc1IDL,
    'backend': backendIDL,
}
export const mapIdls = {
    'aaaaa-aa' : icIDL,
    '2ouva-viaaa-aaaaq-aaamq-cai': icrc1IDL,
};
export default preloadIdls;