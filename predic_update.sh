#!/usr/bin/env bash
set -e
root="$(dirname "$0")/src/dip721/"
did_file="${root}predic.did"
dfx build predic
dfx generate predic
candid-extractor "target/wasm32-unknown-unknown/release/predic.wasm" > $did_file
icp_ledger_canister_id="$(dfx canister id icp_ledger_canister)"
dfx canister install predic --mode=upgrade --argument "record{
    name=\"Prediction NFT2\";
    symbol=\"PREDIC2\";
    buy_prices=vec { 100000000;200000000;300000000};
    remaing=vec { 10;20;30};
    custodians=null;
    logo=null;
    ledger=principal\"$icp_ledger_canister_id\"
}"