set -e
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
# # dfx start --host 0.0.0.0:4943 --background --clean > dfx.log 2>&1 &
# # sleep 10
# rm -f .env
# dfx start --host 0.0.0.0:4943 --background --clean > dfx.log 2>&1
# dfx identity new taro --storage-mode plaintext --force
# dfx identity new default --storage-mode plaintext --force

# echo "===========SETUP========="
# dfx identity new alice_icp_transfer --storage-mode plaintext --force
# export MINTER_ACCOUNT_ID=$(dfx --identity anonymous ledger account-id)
# export DEFAULT_ACCOUNT_ID=$(dfx ledger account-id)
# dfx deploy ledger --argument "
#   (variant {
#     Init = record {
#       minting_account = \"$MINTER_ACCOUNT_ID\";
#       initial_values = vec {
#         record {
#           \"$DEFAULT_ACCOUNT_ID\";
#           record {
#             e8s = 10_000_000_000 : nat64;
#           };
#         };
#       };
#       send_whitelist = vec {};
#       transfer_fee = opt record {
#         e8s = 10_000 : nat64;
#       };
#       token_symbol = opt \"LICP\";
#       token_name = opt \"Local ICP\";
#     }
#   })
# "
# dfx canister call ledger account_balance '(record { account = '$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$DEFAULT_ACCOUNT_ID'")]) + "}")')'})'
# echo "===========SETUP DONE========="


# II_FETCH_ROOT_KEY=1 dfx deploy internet_identity --no-wallet --argument '(null)'
=======
=======
>>>>>>> fec167d6f3853e7e70ecf73aff4345b59a6244f2
=======
>>>>>>> fec167d6f3853e7e70ecf73aff4345b59a6244f2
# dfx start --host 0.0.0.0:4943 --background --clean > dfx.log 2>&1 &
# sleep 10
rm -f .env
dfx start --host 0.0.0.0:4943 --background --clean > dfx.log 2>&1
dfx identity new taro --storage-mode plaintext --force
dfx identity new default --storage-mode plaintext --force

echo "===========SETUP========="
dfx identity new alice_icp_transfer --storage-mode plaintext --force
export MINTER_ACCOUNT_ID=$(dfx --identity anonymous ledger account-id)
export DEFAULT_ACCOUNT_ID=$(dfx ledger account-id)
dfx deploy ledger --argument "
  (variant {
    Init = record {
      minting_account = \"$MINTER_ACCOUNT_ID\";
      initial_values = vec {
        record {
          \"$DEFAULT_ACCOUNT_ID\";
          record {
            e8s = 10_000_000_000 : nat64;
          };
        };
      };
      send_whitelist = vec {};
      transfer_fee = opt record {
        e8s = 10_000 : nat64;
      };
      token_symbol = opt \"LICP\";
      token_name = opt \"Local ICP\";
    }
  })
"
dfx canister call ledger account_balance '(record { account = '$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$DEFAULT_ACCOUNT_ID'")]) + "}")')'})'
echo "===========SETUP DONE========="


II_FETCH_ROOT_KEY=1 dfx deploy internet_identity --no-wallet --argument '(null)'
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> fec167d6f3853e7e70ecf73aff4345b59a6244f2
=======
>>>>>>> fec167d6f3853e7e70ecf73aff4345b59a6244f2
=======
>>>>>>> fec167d6f3853e7e70ecf73aff4345b59a6244f2
bash scripts/predic.sh
bash scripts/frontend.sh