#!/usr/bin/env bash
set -e

#测试web页面的depositeAddress
ICP_DEPOSIT_ADDRESS=""
ROOT_PRINCIPAL="principal \"\""
ICP_DEPOSIT_ADDR_USER1=$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$II_ACCOUNT_ID_HEX'")]) + "}")')
#测试默认账户的depositeAddress
ICP_DEPOSIT_ADDR_USER1=$(node scripts/blobToHex.js $(dfx canister call predic getDepositAddress))
ROOT_PRINCIPAL="principal \"$(dfx identity get-principal)\""

echo "prices:"
dfx canister call predic getPrices
echo "depositeAddress:"
echo $ICP_DEPOSIT_ADDR_USER1
echo "transfer to depositeAddress:"
dfx canister call ledger transfer "(record { amount = record { e8s = 100_001_000 }; to = $ICP_DEPOSIT_ADDR_USER1; fee = record { e8s = 10000}; memo = 1;})"
echo "account balance:"
dfx canister call ledger account_balance '(record { account = '$ICP_DEPOSIT_ADDR_USER1'})'
echo "buy token:"
dfx canister call predic buy 0
echo "ownerNfs:"
dfx canister call predic ownerNfs "($ROOT_PRINCIPAL)"