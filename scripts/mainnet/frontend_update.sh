#!/usr/bin/env bash
set -e

pushd src/frontend
npm install
NODE_ENV="production" npm run build
popd
dfx build frontend --network ic
dfx canister install frontend --ic --mode=upgrade

# echo "===== VISIT DEFI FRONTEND ====="
# echo "https://$(dfx canister id frontend --ic).icp0.io/"
# echo "===== VISIT DEFI FRONTEND ====="

# curl -sLv -X POST -H 'Content-Type: application/json' https://icp0.io/registrations --data @- <<EOF
# {
#     "name": "app.predi.org"
# }
# EOF