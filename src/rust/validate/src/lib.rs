use candid::{candid_method, CandidType, Deserialize, Principal};
use ic_cdk::api::time;
use ic_cdk_macros::{init, query, update};
use std::cell::RefCell;
use std::collections::BTreeMap;

use canister_sig_util::extract_raw_root_pk_from_der;
use vc_util::issuer_api::CredentialSpec;
use vc_util::{validate_ii_presentation_and_claims, VcFlowSigners};

#[derive(CandidType, Deserialize)]
struct RpConfig {
    ic_root_key_raw: Vec<u8>,
    ii_origin: String,
    ii_canister_id: Principal,
    issuers: BTreeMap<String, Principal>,
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
    pub issuer_canister_id: Option<Principal>,
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

#[update]
#[candid_method(update)]
fn config(init_arg: RpInit) {
    let config = RpConfig {
        ic_root_key_raw: extract_raw_root_pk_from_der(&init_arg.ic_root_key_der)
            .expect("failed to extract raw root pk from der"),
        ii_origin: init_arg.ii_vc_url,
        ii_canister_id: init_arg.ii_canister_id,
        issuers: init_arg
            .issuers
            .into_iter()
            .map(|data| (data.vc_url, data.canister_id))
            .collect(),
    };
    CONFIG.with(|cfg| *cfg.borrow_mut() = config);
}

#[init]
#[candid_method(init)]
fn init(init_arg: Option<RpInit>) {
    if let Some(init) = init_arg {
        config(init);
    }
}

#[update]
#[candid_method]
fn validate_ii_vp(req: ValidateVpRequest) -> Result<(), ContentError> {
    let (ic_root_key_raw, vc_flow_signers) = CONFIG.with(|config| {
        let config = config.borrow();
        let Some(issuer_canister_id) = config.issuers.get(&req.issuer_origin) else {
            return Err(ContentError::NotAuthorized(format!(
                "issuer not supported: {}",
                req.issuer_origin
            )));
        };
        if let Some(issuer_canister_id_from_req) = req.issuer_canister_id {
            if *issuer_canister_id != issuer_canister_id_from_req {
                return Err(ContentError::NotAuthorized(format!(
                    "wrong issuer canister id: expected {}, got {}",
                    issuer_canister_id, issuer_canister_id_from_req
                )));
            }
        }
        Ok((
            config.ic_root_key_raw.clone(),
            VcFlowSigners {
                ii_origin: config.ii_origin.clone(),
                ii_canister_id: config.ii_canister_id,
                issuer_origin: req.issuer_origin,
                issuer_canister_id: *issuer_canister_id,
            },
        ))
    })?;
    match validate_ii_presentation_and_claims(
        &req.vp_jwt,
        req.effective_vc_subject,  // Đã loại bỏ Some()
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
fn get_issuers() -> BTreeMap<String, Principal> {
    CONFIG.with(|config| config.borrow().issuers.clone())
}

candid::export_service!();