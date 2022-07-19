KEY="mykey"
CHAINID="astra_11110-1"
MONIKER="localtestnet"
KEYRING="test"
KEYALGO="eth_secp256k1"
LOGLEVEL="info"
# to trace evm
#TRACE="--trace"
TRACE=""

KEY_DEV="dev"
KEY_DEV_VESTING="dev_vesting"

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

rm -rf ~/.astrad*

# Reinstall daemon
make install

# Set client config
astrad config keyring-backend $KEYRING
astrad config chain-id $CHAINID

# if $KEY exists it should be deleted
astrad keys add $KEY --keyring-backend $KEYRING
astrad keys add $KEY_DEV --keyring-backend $KEYRING
astrad keys add $KEY_DEV_VESTING --keyring-backend $KEYRING

# Set moniker and chain-id for Evmos (Moniker can be anything, chain-id must be an integer)
astrad init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to aastra
cat $HOME/.astrad/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="aastra"' > $HOME/.astrad/config/tmp_genesis.json && mv $HOME/.astrad/config/tmp_genesis.json $HOME/.astrad/config/genesis.json
cat $HOME/.astrad/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="aastra"' > $HOME/.astrad/config/tmp_genesis.json && mv $HOME/.astrad/config/tmp_genesis.json $HOME/.astrad/config/genesis.json
cat $HOME/.astrad/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="aastra"' > $HOME/.astrad/config/tmp_genesis.json && mv $HOME/.astrad/config/tmp_genesis.json $HOME/.astrad/config/genesis.json
cat $HOME/.astrad/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="aastra"' > $HOME/.astrad/config/tmp_genesis.json && mv $HOME/.astrad/config/tmp_genesis.json $HOME/.astrad/config/genesis.json
cat $HOME/.astrad/config/genesis.json | jq '.app_state["distribution"]["params"]["community_tax"]="0.0"' > $HOME/.astrad/config/tmp_genesis.json && mv $HOME/.astrad/config/tmp_genesis.json $HOME/.astrad/config/genesis.json


 cat $HOME/.astrad/config/genesis.json | jq '.app_state["epochs"]["epochs"][0]["identifier"]="hour"' > $HOME/.astrad/config/tmp_genesis.json && mv $HOME/.astrad/config/tmp_genesis.json $HOME/.astrad/config/genesis.json
 cat $HOME/.astrad/config/genesis.json | jq '.app_state["epochs"]["epochs"][0]["duration"]="3600s"' > $HOME/.astrad/config/tmp_genesis.json && mv $HOME/.astrad/config/tmp_genesis.json $HOME/.astrad/config/genesis.json
 cat $HOME/.astrad/config/genesis.json | jq '.app_state["inflation"]["epoch_identifier"]="hour"' > $HOME/.astrad/config/tmp_genesis.json && mv $HOME/.astrad/config/tmp_genesis.json $HOME/.astrad/config/genesis.json

# increase block time (?)
cat $HOME/.astrad/config/genesis.json | jq '.consensus_params["block"]["time_iota_ms"]="1000"' > $HOME/.astrad/config/tmp_genesis.json && mv $HOME/.astrad/config/tmp_genesis.json $HOME/.astrad/config/genesis.json

# Set gas limit in genesis
cat $HOME/.astrad/config/genesis.json | jq '.consensus_params["block"]["max_gas"]="10000000"' > $HOME/.astrad/config/tmp_genesis.json && mv $HOME/.astrad/config/tmp_genesis.json $HOME/.astrad/config/genesis.json

# disable produce empty block
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.astrad/config/config.toml
  else
    sed -i 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.astrad/config/config.toml
fi

if [[ $1 == "pending" ]]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.astrad/config/config.toml
      sed -i '' 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.astrad/config/config.toml
      sed -i '' 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.astrad/config/config.toml
      sed -i '' 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.astrad/config/config.toml
      sed -i '' 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.astrad/config/config.toml
      sed -i '' 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.astrad/config/config.toml
      sed -i '' 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.astrad/config/config.toml
      sed -i '' 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.astrad/config/config.toml
      sed -i '' 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.astrad/config/config.toml
  else
      sed -i 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.astrad/config/config.toml
      sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.astrad/config/config.toml
      sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.astrad/config/config.toml
      sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.astrad/config/config.toml
      sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.astrad/config/config.toml
      sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.astrad/config/config.toml
      sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.astrad/config/config.toml
      sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.astrad/config/config.toml
      sed -i 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.astrad/config/config.toml
  fi
fi

# Allocate genesis accounts (cosmos formatted addresses)
astrad add-genesis-account $KEY 1000000astra --keyring-backend $KEYRING
astrad add-genesis-account $KEY_DEV 2000001astra --keyring-backend $KEYRING
# astrad add-genesis-account astra12lakkamgtx84ep0txku7ejpeajmv2d674apc9d 2000000astra --keyring-backend test --vesting ./vesting/vesting_dev.json --clawback --funder astra1z4p2nev0l590pnvs6jdn80288sp3kcg3gy3stq
# Sign genesis transaction
# astrad gentx mykey 1000000astra --keyring-backend test --chain-id astra_11110-1

# Collect genesis tx
# astrad collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
astrad validate-genesis