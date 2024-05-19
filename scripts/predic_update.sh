#!/usr/bin/env bash
set -e
root="${pwd}/src/dip721/"
did_file="${root}predic.did"
dfx build predic
dfx generate predic
candid-extractor "target/wasm32-unknown-unknown/release/predic.wasm" > $did_file
ledger_id="$(dfx canister id ledger)"
dfx canister install predic --mode=upgrade --argument "record{
    name=\"Prediction NFT\";
    symbol=\"PREDIC\";
    buy_prices=vec { 100000000;200000000;300000000};
    remaing=vec { 3;2;1};
    custodians=null;
    logo=null;
    ledger=principal\"$ledger_id\"
}"