set -e
ledger_id="$(dfx canister id ledger)"
dfx deploy predic --network ic --with-cycles 8000000000000 --argument "record{
    name=\"Prediction NFT\";
    symbol=\"PREDIC\";
    buy_prices=vec { 100000000;200000000;300000000};
    remaing=vec { 30;20;10};
    custodians=null;
    logo=null;
    ledger=principal\"$ledger_id\"
}"

pushd src/frontend
npm install
NODE_ENV="production" npm run build
popd

dfx  deploy frontend --network ic --with-cycles 1000000000000

echo "===== VISIT DEFI FRONTEND ====="
echo "https://$(dfx canister id frontend).ic0.app"
echo "===== VISIT DEFI FRONTEND ====="