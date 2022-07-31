<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/QmGfDKrA" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/172356220-b8326ceb-9950-4226-b66e-da69099aaf6e.png">
</p>

# kujira node setup for mainnet — kaiyo-1

Official documentation:
>- [Validator setup instructions](https://docs.kujira.app/run-a-node)

Explorer:
>-  https://kujira.explorers.guru/

## Usefull tools and references
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for kujira validator](https://github.com/kj89/testnet_manuals/blob/main/kujira/monitoring/README.md)
>
> To migrate your validator to another machine read [Migrate your validator to another machine](https://github.com/kj89/testnet_manuals/blob/main/kujira/migrate_validator.md)

## Hardware Requirements
Like any Cosmos-SDK chain, the hardware requirements are pretty modest.

### Minimum Hardware Requirements
 - 3x CPUs; the faster clock speed the better
 - 4GB RAM
 - 80GB Disk
 - Permanent Internet connection (traffic will be minimal during mainnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

### Recommended Hardware Requirements 
 - 4x CPUs; the faster clock speed the better
 - 8GB RAM
 - 200GB of storage (SSD or NVME)
 - Permanent Internet connection (traffic will be minimal during mainnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

## Set up your kujira fullnode
### Option 1 (automatic)
You can setup your kujira fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O kujira.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/kujira/kujira.sh && chmod +x kujira.sh && ./kujira.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/kujira/manual_install.md) if you better prefer setting up node manually

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
kujirad status 2>&1 | jq .SyncInfo
```

### (OPTIONAL) Disable and cleanup indexing
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.kujira/config/config.toml
sudo systemctl restart kujirad
sleep 3
sudo rm -rf $HOME/.kujira/data/tx_index.db
```

### (OPTIONAL) State Sync
You can state sync your node in minutes by running commands below. Special thanks to `polkachu | polkachu.com#1249`
```
N/A
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
kujirad keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
kujirad keys add $WALLET --recover
```

To get current list of wallets
```
kujirad keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
KUJIRA_WALLET_ADDRESS=$(kujirad keys show $WALLET -a)
```
```
KUJIRA_VALOPER_ADDRESS=$(kujirad keys show $WALLET --bech val -a)
```
Load variables into the system
```
echo 'export KUJIRA_WALLET_ADDRESS='${KUJIRA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export KUJIRA_VALOPER_ADDRESS='${KUJIRA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create validator
Before creating validator please make sure that you have at least 1 kuji (1 kuji is equal to 1000000 ukuji) and your node is synchronized

To check your wallet balance:
```
kujirad query bank balances $KUJIRA_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
kujirad tx staking create-validator \
  --amount 100000ukuji \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(kujirad tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $KUJIRA_CHAIN_ID
```

## Security
To protect you keys please make sure you follow basic security rules

### Set up ssh keys for authentication
Good tutorial on how to set up ssh keys for authentication to your server can be found [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-20-04)

### Basic Firewall security
Start by checking the status of ufw.
```
sudo ufw status
```

Sets the default to allow outgoing connections, deny all incoming except ssh and 26656. Limit SSH login attempts
```
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow ${KUJIRA_PORT}656,${KUJIRA_PORT}660/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for kujira validator](https://github.com/kj89/testnet_manuals/blob/main/kujira/monitoring/README.md)

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node\
It measures average blocks per minute that are being synchronized for period of 5 minutes and then gives you results
```
wget -O synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/kujira/tools/synctime.py && python3 ./synctime.py
```

### Get list of validators
```
kujirad q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " \t " + .description.moniker' | sort -gr | nl
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${KUJIRA_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu kujirad -o cat
```

Start service
```
sudo systemctl start kujirad
```

Stop service
```
sudo systemctl stop kujirad
```

Restart service
```
sudo systemctl restart kujirad
```

### Node info
Synchronization info
```
kujirad status 2>&1 | jq .SyncInfo
```

Validator info
```
kujirad status 2>&1 | jq .ValidatorInfo
```

Node info
```
kujirad status 2>&1 | jq .NodeInfo
```

Show node id
```
kujirad tendermint show-node-id
```

### Wallet operations
List of wallets
```
kujirad keys list
```

Recover wallet
```
kujirad keys add $WALLET --recover
```

Delete wallet
```
kujirad keys delete $WALLET
```

Get wallet balance
```
kujirad query bank balances $KUJIRA_WALLET_ADDRESS
```

Transfer funds
```
kujirad tx bank send $KUJIRA_WALLET_ADDRESS <TO_KUJIRA_WALLET_ADDRESS> 10000000ukuji
```

### Voting
```
kujirad tx gov vote 1 yes --from $WALLET --chain-id=$KUJIRA_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
kujirad tx staking delegate $KUJIRA_VALOPER_ADDRESS 10000000ukuji --from=$WALLET --chain-id=$KUJIRA_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
kujirad tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ukuji --from=$WALLET --chain-id=$KUJIRA_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
kujirad tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$KUJIRA_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
kujirad tx distribution withdraw-rewards $KUJIRA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$KUJIRA_CHAIN_ID
```

### Validator management
Edit validator
```
kujirad tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$KUJIRA_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
kujirad tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$KUJIRA_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop kujirad
sudo systemctl disable kujirad
sudo rm /etc/systemd/system/kujira* -rf
sudo rm $(which kujirad) -rf
sudo rm $HOME/.kujira* -rf
sudo rm $HOME/kujira -rf
sed -i '/KUJIRA_/d' ~/.bash_profile
```
