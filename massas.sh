#!/bin/bash
cd $HOME/massa/massa-client/
handle() {
  local wallet_info=$(./massa-client -j wallet_info)
  local wallet_address=$(jq -r "[.[]] | .[0].address_info.address // empty" <<<"$wallet_info")
  local candidate_rolls=$(jq -r "[.[]] | .[-1].address_info.rolls.candidate_rolls" <<<"$wallet_info")
  local balance=$(jq -r "[.[]] | .[-1].address_info.balance.candidate_ledger_info.balance" <<<"$wallet_info")
  local roll_count=$(bc -l <<<"$balance/100")
  if [ -z "$wallet_address" ]; then
    echo " Wallet not found."
    echo " Create new wallet with $HOME/massa/massa-client/massa-client wallet_generate_private_key"
  elif [ "$candidate_rolls" -eq "0" ]; then
    local response=$(./massa-client buy_rolls "$wallet_address" 1 0)
    if grep -q 'insuffisant balance' <<<"$response"; then
      echo " Not enough tokens to buy rolls."
      echo "Need 100."
      echo "You have $balance."
      echo " Faucet for $wallet_address"
    else
      echo " Done. Bought 1 roll."
    fi
  else
    echo " Everything is ok."
  fi
}

while true; do
  echo " Running the script..."
  if grep -q "check if your node is running" <<<"$(./massa-client get_status)"; then
    echo " Node is not running."
    echo " Run the node with $HOME/massa/massa-node/massa-node"
  else
    handle
  fi
  echo " Sleeping for 5 min..."
  sleep 200
done
