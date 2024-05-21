#!/usr/bin/env bash
set -e

PRINCIPAL="dusfl-kjzll-b5zyz-y5isb-wzzbr-35r7s-g24xv-ewm2r-5abgi-2sd6h-zqe"
ROOT_PRINCIPAL="principal \"$PRINCIPAL\""
# script to retrieve default subaccount of II in hex format
II_ACCOUNT_ID_HEX=$(python3 ./scripts/principal_to_default_account_id.py $PRINCIPAL)
II_ACCOUNT_ID=$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$II_ACCOUNT_ID_HEX'")]) + "}")')
# convert hex account ID to vec format
dfx canister call ledger transfer "(record { amount = record { e8s = 500_001_000 }; to = $II_ACCOUNT_ID; fee = record { e8s = 10000}; memo = 1;})"
echo "account balance:"
dfx canister call ledger account_balance '(record { account = '$II_ACCOUNT_ID'})'
echo "ownerNfs:"
dfx canister call predic ownerNfs "($ROOT_PRINCIPAL)"