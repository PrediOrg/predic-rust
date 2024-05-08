#!/usr/bin/env bash
set -e

dfx deploy icp_transfer_backend

TOKENS_TRANSFER_ACCOUNT_ID="$(dfx ledger account-id --of-canister icp_transfer_backend)"
TOKENS_TRANSFER_ACCOUNT_ID_BYTES="$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$TOKENS_TRANSFER_ACCOUNT_ID'")]) + "}")')"
dfx canister call icp_ledger_canister transfer "(record { to=${TOKENS_TRANSFER_ACCOUNT_ID_BYTES}; amount=record { e8s=100_000 }; fee=record { e8s=10_000 }; memo=0:nat64; }, )"

dfx canister call icp_transfer_backend transfer "(record { amount=record { e8s=5 }; to_principal=principal \"$(dfx identity get-principal)\" },)"

echo "DONE"