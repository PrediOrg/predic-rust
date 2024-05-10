#!/usr/bin/env bash
set -e
ACCOUNT_ID="7C60C6E30CFC8865BFF874F07911D2446389C1116047B8314734814190B4EAB4"
# ACCOUNT_ID="$(dfx --ident ledger account-id)"
# dfx  canister call icp_ledger_canister transfer "(record { to=$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$ACCOUNT_ID'")]) + "}")'); amount=record { e8s=100_000 }; fee=record { e8s=10_000 }; memo=0:nat64; }, )"

dfx canister call icp_ledger_canister account_balance '(record { account = '$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$ACCOUNT_ID'")]) + "}")')'})'