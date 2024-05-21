set -e

dfx canister call predic setRemaing "(vec{10;0;0})"
dfx canister call predic setPrices "(vec { 1_000_000_000 : nat64; 0 : nat64; 0 : nat64 })"
dfx canister call predic setName "Predi Product License"
dfx canister call predic setSymbol "PPL"