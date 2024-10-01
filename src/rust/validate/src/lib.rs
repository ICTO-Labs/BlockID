use candid::{candid_method, CandidType, Deserialize, Principal};
use ic_cdk::api::time;
use ic_cdk::caller;
use ic_cdk_macros::{init, query, update, export_candid};
use std::cell::RefCell;
use std::collections::{BTreeMap, HashSet};
use url::Url;

use canister_sig_util::extract_raw_root_pk_from_der;
use vc_util::issuer_api::CredentialSpec;
use vc_util::{validate_ii_presentation_and_claims, VcFlowSigners};

#[derive(CandidType, Deserialize, Clone)]
struct IssuerInfo {
    issuer_origin: String,
    credential_specs: Vec<CredentialSpec>,
}

#[derive(CandidType, Deserialize)]
struct RpConfig {
    ic_root_key_raw: Vec<u8>,
    ii_origin: String,
    ii_canister_id: Principal,
    issuers: BTreeMap<Principal, IssuerInfo>,
    admins: HashSet<Principal>,
}

thread_local! {
    static CONFIG: RefCell<RpConfig> = RefCell::new(RpConfig::default());
}

impl Default for RpConfig {
    fn default() -> Self {
        Self {
            ic_root_key_raw: vec![],
            ii_origin: "".to_string(),
            ii_canister_id: Principal::anonymous(),
            issuers: BTreeMap::new(),
            admins: HashSet::new(),
        }
    }
}

#[derive(CandidType, Deserialize)]
pub struct ValidateVpRequest {
    pub vp_jwt: String,
    pub effective_vc_subject: Principal,
    pub credential_spec: CredentialSpec,
    pub issuer_origin: String,
    pub issuer_canister_id: Principal,
}

#[derive(CandidType, Deserialize)]
pub enum ContentError {
    NotAuthorized(String),
}

#[derive(CandidType, Deserialize)]
pub struct RpInit {
    pub ic_root_key_der: Vec<u8>,
    pub ii_vc_url: String,
    pub ii_canister_id: Principal,
}

fn normalize_url(url: &str) -> Result<String, url::ParseError> {
    let parsed_url = Url::parse(url)?;
    Ok(parsed_url.to_string())
}

fn is_admin(caller: &Principal) -> bool {
    CONFIG.with(|config| config.borrow().admins.contains(caller))
}

#[update]
#[candid_method(update)]
fn config(init_arg: RpInit) -> Result<(), String> {
    let caller = caller();
    let config = RpConfig {
        ic_root_key_raw: extract_raw_root_pk_from_der(&init_arg.ic_root_key_der)
            .expect("failed to extract raw root pk from der"),
        ii_origin: normalize_url(&init_arg.ii_vc_url)
            .map_err(|e| format!("Invalid II URL: {}", e))?,
        ii_canister_id: init_arg.ii_canister_id,
        issuers: BTreeMap::new(),
        admins: {
            let mut set = HashSet::new();
            set.insert(caller);
            set
        },
    };
    CONFIG.with(|cfg| *cfg.borrow_mut() = config);
    Ok(())
}

#[init]
#[candid_method(init)]
fn init(init_arg: Option<RpInit>) {
    if let Some(init) = init_arg {
        let _ = config(init);
    }
}

#[update]
#[candid_method]
fn validate(mut req: ValidateVpRequest) -> Result<(), ContentError> {
    req.issuer_origin = normalize_url(&req.issuer_origin)
        .map_err(|e| ContentError::NotAuthorized(format!("Invalid issuer origin: {}", e)))?;

    let (ic_root_key_raw, vc_flow_signers) = CONFIG.with(|config| {
        let config = config.borrow();
        let Some(issuer_info) = config.issuers.get(&req.issuer_canister_id) else {
            return Err(ContentError::NotAuthorized(format!(
                "issuer not supported: {}",
                req.issuer_canister_id
            )));
        };
        
        if issuer_info.issuer_origin != req.issuer_origin {
            return Err(ContentError::NotAuthorized(format!(
                "mismatched issuer origin: expected {}, got {}",
                issuer_info.issuer_origin, req.issuer_origin
            )));
        }
        
        if !issuer_info.credential_specs.contains(&req.credential_spec) {
            return Err(ContentError::NotAuthorized(format!(
                "unsupported credential spec for issuer: {}",
                req.issuer_origin
            )));
        }
        
        Ok((
            config.ic_root_key_raw.clone(),
            VcFlowSigners {
                ii_origin: config.ii_origin.clone(),
                ii_canister_id: config.ii_canister_id,
                issuer_origin: req.issuer_origin,
                issuer_canister_id: req.issuer_canister_id,
            },
        ))
    })?;

    match validate_ii_presentation_and_claims(
        &req.vp_jwt,
        req.effective_vc_subject,
        &vc_flow_signers,
        &req.credential_spec,
        &ic_root_key_raw,
        time() as u128,
    ) {
        Ok(()) => Ok(()),
        Err(err) => Err(ContentError::NotAuthorized(format!(
            "VP validation error: {:?}",
            err
        ))),
    }
}

#[query]
#[candid_method(query)]
fn get_issuers() -> BTreeMap<Principal, IssuerInfo> {
    CONFIG.with(|config| config.borrow().issuers.clone())
}

#[update]
#[candid_method(update)]
fn add_issuer(canister_id: Principal, vc_url: String, credential_specs: Vec<CredentialSpec>) -> Result<(), String> {
    let caller = ic_cdk::caller();
    if !is_admin(&caller) {
        return Err("Not authorized".to_string());
    }

    let normalized_url = normalize_url(&vc_url)
        .map_err(|e| format!("Invalid issuer URL: {}", e))?;
    
    let _ = CONFIG.with(|cfg| {
        let mut config = cfg.borrow_mut();
        config.issuers.insert(canister_id, IssuerInfo {
            issuer_origin: normalized_url,
            credential_specs,
        });
    });
    Ok(())
}

#[update]
#[candid_method(update)]
fn remove_issuer(canister_id: Principal) -> Result<(), String> {
    let caller = ic_cdk::caller();
    if !is_admin(&caller) {
        return Err("Not authorized".to_string());
    }

    let _ = CONFIG.with(|cfg| {
        let mut config = cfg.borrow_mut();
        if config.issuers.remove(&canister_id).is_none() {
            return Err(format!("Issuer with canister ID {} not found", canister_id));
        }else{
            return Ok(());
        }
    });
    Ok(())
}

#[update]
#[candid_method(update)]
fn add_admin(new_admin: Principal) -> Result<(), String> {
    let caller = ic_cdk::caller();
    if !is_admin(&caller) {
        return Err("Not authorized".to_string());
    }

    let _ = CONFIG.with(|cfg| {
        let mut config = cfg.borrow_mut();
        config.admins.insert(new_admin);
    });
    Ok(())
}

#[update]
#[candid_method(update)]
fn remove_admin(admin: Principal) -> Result<(), String> {
    let caller = ic_cdk::caller();
    if !is_admin(&caller) {
        return Err("Not authorized".to_string());
    }

    let _ = CONFIG.with(|cfg| {
        let mut config = cfg.borrow_mut();
        if !config.admins.remove(&admin) {
            return Err(format!("Admin {} not found", admin));
        }
        if config.admins.is_empty() {
            return Err("Cannot remove the last admin".to_string());
        }else{
            return Ok(());
        }
    });
    Ok(())
}

#[query]
#[candid_method(query)]
fn get_admins() -> HashSet<Principal> {
    CONFIG.with(|config| config.borrow().admins.clone())
}

export_candid!();