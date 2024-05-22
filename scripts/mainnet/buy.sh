#!/usr/bin/env bash
set -e
# ROOT_PRINCIPAL="principal \"$(dfx identity get-principal)\""
ROOT_PRINCIPAL="principal \"n2mcg-uqcb5-edvb3-if2dz-qmfdf-fnmfh-fqpmq-iwj6n-alqqk-v5w7r-rae\""
echo "buy token:"
dfx canister --ic call predic buy 0
# echo "ownerNfs:"
# dfx canister --ic call predic ownerNfs "($ROOT_PRINCIPAL)"