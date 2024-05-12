#!/usr/bin/env bash
set -e
root="$(dirname "$0")/src/dip721/"
did_file="${root}predic.did"
dfx canister create predic
dfx build predic
dfx generate predic
candid-extractor "target/wasm32-unknown-unknown/release/predic.wasm" > $did_file
icp_ledger_canister_id="$(dfx canister id ledger)"
dfx canister install predic --argument "record{
    name=\"Prediction NFT2\";
    symbol=\"PREDIC2\";
    buy_prices=vec { 100000000;200000000;300000000};
    remaing=vec { 100000000;200000000;300000000};
    custodians=null;
    logo=null;
    ledger=principal\"$icp_ledger_canister_id\"
}"