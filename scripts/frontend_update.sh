#!/usr/bin/env bash
set -e
dfx canister create frontend
pushd src/frontend
npm install
npm run build
popd
dfx build frontend
dfx canister install frontend --mode=reinstall

echo "===== VISIT DEFI FRONTEND ====="
echo "http://localhost:4943?canisterId=$(dfx canister id frontend)"
echo "===== VISIT DEFI FRONTEND ====="
