import icIDL from '@/actor/did/ic.did';
import icrc1IDL from '@/actor/did/icrc1.did';

import {idlFactory as backendIDL} from '@/../../declarations/backend';
import {idlFactory as validateIDL} from '@/../../declarations/validate';
import {idlFactory as issuerIDL} from '@/../../declarations/issuer';
import {idlFactory as marketplaceIDL} from '@/../../declarations/marketplace';
export const preloadIdls = {
    'IC': icIDL,
    'icrc1' : icrc1IDL,
    'backend': backendIDL,
    'validate': validateIDL,
    'issuer': issuerIDL,
    'marketplace': marketplaceIDL,
}
export const mapIdls = {
    'aaaaa-aa' : icIDL,
    '2ouva-viaaa-aaaaq-aaamq-cai': icrc1IDL,
    'issuer': issuerIDL,
};
export default preloadIdls;