import {Principal} from "@dfinity/principal";
import {Buffer} from "buffer";
import { sha224 } from '@dfinity/principal/lib/esm/utils/sha224';
import { getCrc32 } from '@dfinity/principal/lib/esm/utils/getCrc';


const isHex = (h) => {
    var regexp = /^[0-9a-fA-F]+$/;
    return regexp.test(h);
};
export const toHexString = (byteArray)  =>{
    return Array.from(byteArray, function(byte) {
        return ('0' + (byte & 0xFF).toString(16)).slice(-2);
    }).join('')
}
export const validatePrincipal = (p) => {
    try {
        return (p === Principal.fromText(p).toText());
    } catch (e) {
        return false;
    }
}
const isPrincipal = (p)=>{
    return !!p && p._isPrincipal;
}
export const isAnonymous = (p)=>{
    return p == "2vxsx-fae";
}
export const principalToText = (p)=>{
    if(isPrincipal(p)){
        return p.toText();
    }else{
        return p;
    }
}
export const validateAddress = (a) => {
    return (isHex(a) && a.length === 64)
}
const to32bits = (num) => {
    let b = new ArrayBuffer(4)
    new DataView(b).setUint32(0, num)
    return Array.from(new Uint8Array(b))
}
export const txtToPrincipal = (p)=>{
    try {
        return Principal.fromText(p);
    } catch (e) {
        return p;
    }
}  
export const principalToAccountId = (p, s) => {
    if(!p) return p;
    let _p = principalToText(p);
    const padding = Buffer("\x0Aaccount-id");
    const array = new Uint8Array([
        ...padding,
        ...Principal.fromText(_p).toUint8Array(),
        ...getSubAccountArray(s)
    ]);
    const hash = sha224(array);
    const checksum = to32bits(getCrc32(hash));
    const array2 = new Uint8Array([
        ...checksum,
        ...hash
    ]);
    return toHexString(array2);
};
export const getSubAccountArray = (s) => {
    if (Array.isArray(s)){
        return s.concat(Array(32-s.length).fill(0));
    } else {
        //32 bit number only
        return Array(28).fill(0).concat(to32bits(s ? s : 0))
    }
};
const from32bits = ba => {
    var value;
    for (var i = 0; i < 4; i++) {
        value = (value << 8) | ba[i];
    }
    return value;
}
export const shortAccount = (accountId)=>{
   if(!accountId) return accountId;
  return `${accountId.slice(0, 8)}...${accountId.slice(-8)}`;
}
export const shortPrincipal = (principal) => {
    if(!principal) return principal;
  const parts = (
    typeof principal === "string" ? principal : principal.toText()
  ).split("-");
  return `${parts[0]}...${parts.slice(-1)[0]}`;
};