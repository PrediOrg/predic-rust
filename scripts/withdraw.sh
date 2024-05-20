#!/usr/bin/env bash
set -e
PRINCIPAL=$(dfx --identity taro identity get-principal)
AMOUNT=1_098_899_600
dfx canister call predic withdraw "(record { amount=record { e8s=${AMOUNT} }; to_principal=principal \"$(dfx identity get-principal)\"; } )"
echo "account balance:"
II_ACCOUNT_ID=$(dfx ledger account-id --of-canister predic)
II_ACCOUNT_ID=$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$II_ACCOUNT_ID'")]) + "}")')
dfx canister call ledger account_balance '(record { account = '$II_ACCOUNT_ID'})'