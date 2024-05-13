#!/usr/bin/env bash
set -e
II_ACCOUNT_ID="7C60C6E30CFC8865BFF874F07911D2446389C1116047B8314734814190B4EAB4"
# II_ACCOUNT_ID_HEX=$(python3 ./scripts/principal_to_default_account_id.py $1)
II_ACCOUNT_ID_VEC=$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$II_ACCOUNT_ID'")]) + "}")')
# ACCOUNT_ID="$(dfx --ident ledger account-id)"
dfx canister call ledger transfer "(record { amount = record { e8s = 10000000 }; to = $II_ACCOUNT_ID_VEC; fee = record { e8s = 10000}; memo = 1;})"
dfx canister call ledger account_balance '(record { account = '$II_ACCOUNT_ID_VEC'})'