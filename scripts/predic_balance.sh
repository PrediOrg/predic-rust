#!/usr/bin/env bash
set -e

PRINCIPAL=$(dfx canister id predic)
ROOT_PRINCIPAL="principal \"$PRINCIPAL\""
# script to retrieve default subaccount of II in hex format
II_ACCOUNT_ID_HEX=$(python3 ./scripts/principal_to_default_account_id.py $PRINCIPAL)
II_ACCOUNT_ID=$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$II_ACCOUNT_ID_HEX'")]) + "}")')
echo "account balance:"
dfx canister call ledger account_balance '(record { account = '$II_ACCOUNT_ID'})'