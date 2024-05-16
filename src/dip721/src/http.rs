use std::borrow::Cow;
use std::cell::RefCell;
use std::iter::FromIterator;

use crate::{MetadataPurpose, MetadataVal, STATE};
use candid::CandidType;
use ic_cdk::api;
use ic_certified_map::{AsHashTree, Hash, RbTree};
use serde::Deserialize;
use serde_bytes::{ByteBuf, Bytes};
use sha2::{Digest, Sha256};
pub type HeaderField = (String, String);

#[derive(Clone, Debug, CandidType, Deserialize)]
pub struct HttpRequest {
    pub method: String,
    pub url: String,
    pub headers: Vec<(String, String)>,
    pub body: ByteBuf,
}

#[derive(Clone, Debug, CandidType, Deserialize)]
pub struct HttpResponse {
    pub status_code: u16,
    pub headers: Vec<HeaderField>,
    pub body: Cow<'static, Bytes>,
}

#[query]
pub fn http_request(req: HttpRequest) -> HttpResponse {
    let parts: Vec<&str> = req.url.split('?').collect();
    let path = parts[0];
    let mut headers = vec![];
    headers.push(("Access-Control-Allow-Origin".to_string(), "*".to_string()));
    if path == "/" {
        let length = STATE.with(|state| state.borrow().nfts.len());
        return HttpResponse {
            status_code: 200,
            headers,
            body: Cow::Owned(ByteBuf::from(format!("Total NFTs: {}", length))),
        };
    }
    let parts: Vec<&str> = path.split("/").collect();
    let result = parts[1].parse::<usize>();
    if let Err(_) = result {
        return HttpResponse {
            status_code: 404,
            headers,
            body: Cow::Owned(ByteBuf::from(format!("Invalid token ID {}", parts[1]))),
        };
    }
    let nft_id = result.unwrap();
    STATE.with(|state| {
        let state = state.borrow();
        let result = state.nfts.get(nft_id);
        if result.is_none() {
            return HttpResponse {
                status_code: 404,
                headers,
                body: Cow::Owned(ByteBuf::from(format!("No Such NFT {}", nft_id))),
            };
        }
        let nft = result.unwrap();
        if parts.len() == 2 {
            let part = nft
                .metadata
                .iter()
                .find(|x| x.purpose == MetadataPurpose::Rendered)
                .or_else(|| nft.metadata.get(0));
            if let Some(part) = part {
                // default metadata: first non-preview metadata, or if there is none, first metadata
                if let Some(MetadataVal::TextContent(mime)) = part.key_val_data.get("contentType") {
                    headers.push(("Content-Type".to_string(), mime.to_string()));
                }
                return HttpResponse {
                    status_code: 404,
                    headers,
                    body: Cow::Owned(ByteBuf::from(part.data.clone())),
                };
            } else {
                return HttpResponse {
                    status_code: 404,
                    headers,
                    body: Cow::Owned(ByteBuf::from("No metadata for this NFT")),
                };
            }
        } else {
            if let Ok(num) = parts[2].parse::<usize>() {
                // /:nft/:number
                if let Some(part) = nft.metadata.get(num) {
                    // /:nft/:id
                    if let Some(MetadataVal::TextContent(mime)) =
                        part.key_val_data.get("contentType")
                    {
                        headers.push(("Content-Type".to_string(), mime.to_string()));
                    }
                    return HttpResponse {
                        status_code: 404,
                        headers,
                        body: Cow::Owned(ByteBuf::from(part.data.clone())),
                    };
                } else {
                    return HttpResponse {
                        status_code: 404,
                        headers,
                        body: Cow::Owned(ByteBuf::from("No such metadata part")),
                    };
                }
            } else {
                return HttpResponse {
                    status_code: 404,
                    headers,
                    body: Cow::Owned(ByteBuf::from(format!("Invalid metadata ID {}", parts[1]))),
                };
            }
        }
    })
}

thread_local! {
    // sha256("Total NFTs: 0") = 83d0f670865c367ce95f595959abec46ed7b64033ecee9ed772e78793f3bc10f
    pub static HASHES: RefCell<RbTree<String, Hash>> = RefCell::new(RbTree::from_iter([("/".to_string(), *b"\x83\xd0\xf6\x70\x86\x5c\x36\x7c\xe9\x5f\x59\x59\x59\xab\xec\x46\xed\x7b\x64\x03\x3e\xce\xe9\xed\x77\x2e\x78\x79\x3f\x3b\xc1\x0f")]));
}

pub fn add_hash(tkid: u64) {
    crate::STATE.with(|state| {
        HASHES.with(|hashes| {
            let state = state.borrow();
            let mut hashes = hashes.borrow_mut();
            let nft = state.nfts.get(tkid as usize)?;
            let mut default = false;
            for (i, metadata) in nft.metadata.iter().enumerate() {
                let hash = Sha256::digest(&metadata.data);
                hashes.insert(format!("/{}/{}", tkid, i), hash.into());
                if !default && matches!(metadata.purpose, MetadataPurpose::Rendered) {
                    default = true;
                    hashes.insert(format!("/{}", tkid), hash.into());
                }
            }
            hashes.insert(
                "/".to_string(),
                Sha256::digest(format!("Total NFTs: {}", state.nfts.len())).into(),
            );
            let cert = ic_certified_map::labeled_hash(b"http_assets", &hashes.root_hash());
            api::set_certified_data(&cert);
            Some(())
        })
    });
}
