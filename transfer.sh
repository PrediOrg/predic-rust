#!/usr/bin/env bash
set -e
ACCOUNT_ID="C7E429D5170621741B801CA513B7667C1B31B6534B7C9D55018D0B5C8DE2A809"
# ACCOUNT_ID="$(dfx --ident ledger account-id)"
# dfx  canister call icp_ledger_canister transfer "(record { to=$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$ACCOUNT_ID'")]) + "}")'); amount=record { e8s=100_000 }; fee=record { e8s=10_000 }; memo=0:nat64; }, )"
dfx canister call ledger account_balance '(record { account = '$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$ACCOUNT_ID'")]) + "}")')'})'