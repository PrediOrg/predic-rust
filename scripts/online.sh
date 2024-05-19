set -e
# dfx start --host 0.0.0.0:4943 --background --clean > dfx.log 2>&1 &
# sleep 10
dfx --identity=line canister create predic --network ic
dfx build predic
dfx generate predic
# candid-extractor "target/wasm32-unknown-unknown/release/predic.wasm" > $did_file
ledger_id="$(dfx canister id ledger)"
dfx --identity=line canister install predic --network ic --argument "record{
    name=\"Prediction NFT\";
    symbol=\"PREDIC\";
    buy_prices=vec { 100000000;200000000;300000000};
    remaing=vec { 30;20;10};
    custodians=null;
    logo=null;
    ledger=principal\"$ledger_id\"
}"

dfx canister create frontend --network ic --identity=line
pushd src/frontend
npm install
npm run build
popd
dfx build frontend
dfx --identity=line canister install frontend --network ic

echo "===== VISIT DEFI FRONTEND ====="
echo "https://$(dfx canister id frontend).ic0.app"
echo "===== VISIT DEFI FRONTEND ====="
