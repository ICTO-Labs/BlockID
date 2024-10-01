use candid::{candid_method, CandidType, Deserialize, Principal};
use ic_cdk::api::time;
use ic_cdk_macros::{init, query, update, export_candid};
use std::cell::RefCell;
use std::collections::BTreeMap;
use url::Url;

use canister_sig_util::extract_raw_root_pk_from_der;
use vc_util::issuer_api::CredentialSpec;
use vc_util::{validate_ii_presentation_and_claims, VcFlowSigners};

#[derive(CandidType, Deserialize)]
struct RpConfig {
    ic_root_key_raw: Vec<u8>,
    ii_origin: String,
    ii_canister_id: Principal,
    issuers: BTreeMap<Principal, String>, // issuer_canister_id -> issuer_origin
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
    pub issuers: Vec<IssuerData>,
}

#[derive(CandidType, Deserialize)]
pub struct IssuerData {
    pub vc_url: String,
    pub canister_id: Principal,
}

fn normalize_url(url: &str) -> Result<String, url::ParseError> {
    let mut parsed_url = Url::parse(url)?;
    parsed_url.set_path("/");
    Ok(parsed_url.to_string().trim_end_matches('/').to_string())
}

#[update]
#[candid_method(update)]
fn config(init_arg: RpInit) -> Result<(), String> {
    let config = RpConfig {
        ic_root_key_raw: extract_raw_root_pk_from_der(&init_arg.ic_root_key_der)
            .expect("failed to extract raw root pk from der"),
        ii_origin: normalize_url(&init_arg.ii_vc_url)
            .map_err(|e| format!("Invalid II URL: {}", e))?,
        ii_canister_id: init_arg.ii_canister_id,
        issuers: init_arg
            .issuers
            .into_iter()
            .map(|data| {
                let normalized_url = normalize_url(&data.vc_url)
                    .map_err(|e| format!("Invalid issuer URL: {}", e))?;
                Ok((data.canister_id, normalized_url))
            })
            .collect::<Result<_, String>>()?,
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
        let Some(stored_issuer_origin) = config.issuers.get(&req.issuer_canister_id) else {
            return Err(ContentError::NotAuthorized(format!(
                "issuer not supported: {}",
                req.issuer_canister_id
            )));
        };
        
        if *stored_issuer_origin != req.issuer_origin {
            return Err(ContentError::NotAuthorized(format!(
                "mismatched issuer origin: expected {}, got {}",
                stored_issuer_origin, req.issuer_origin
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
fn get_issuers() -> BTreeMap<Principal, String> {
    CONFIG.with(|config| config.borrow().issuers.clone())
}

// Add issuer
#[update]
#[candid_method(update)]
fn add_issuer(canister_id: Principal, vc_url: String) -> Result<(), String> {
    let normalized_url = normalize_url(&vc_url)
        .map_err(|e| format!("Invalid issuer URL: {}", e))?;
    
    CONFIG.with(|cfg| {
        let mut config = cfg.borrow_mut();
        config.issuers.insert(canister_id, normalized_url);
    });
    Ok(())
}

// Remove issuer
#[update]
#[candid_method(update)]
fn remove_issuer(canister_id: Principal) -> Result<(), String> {
    CONFIG.with(|cfg| {
        let mut config = cfg.borrow_mut();

        config.issuers.remove(&canister_id);
    });
    Ok(())
}
export_candid!();