set -e

dfx canister call predic --ic setRemaing "(vec{10;0;0})"
dfx canister call predic --ic setPrices "(vec { 1_000_000_000 : nat64; 0 : nat64; 0 : nat64 })"
dfx canister call predic --ic setName "Predi Product License"
dfx canister call predic --ic setSymbol "PPL"