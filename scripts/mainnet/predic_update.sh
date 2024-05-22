#!/usr/bin/env bash
set -e
root="$(pwd)/src/dip721/"
did_file="${root}predic.did"
dfx build predic --network ic
dfx generate predic --network ic
candid-extractor "target/wasm32-unknown-unknown/release/predic.wasm" > $did_file
ledger_id="$(dfx canister id ledger --ic)"
dfx canister install predic --network ic --mode=upgrade --argument "record{
    name=\"Predi Product License\";
    symbol=\"PPL\";
    buy_prices=vec { 1_000_000_000 : nat64; 0 : nat64; 0 : nat64 };
    remaing=vec{10;0;0};
    custodians=null;
    logo=null;
    ledger=principal\"$ledger_id\"
}"