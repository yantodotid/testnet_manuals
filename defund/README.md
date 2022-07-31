<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/QmGfDKrA" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/171904810-664af00a-e78a-4602-b66b-20bfd874fa82.png">
</p>

# defund node setup for Testnet — defund-private-1

Official documentation:
>- [Validator setup instructions](https://github.com/defund-labs/defund/blob/main/testnet/private/validators.md)
>- [DeFund Tokenomics](https://medium.com/defund-finance/detf-token-economics-release-schedule-78a8d32713a5)
>- [FundDrop Breakdown](https://medium.com/defund-finance/airdrop-d-c2685d282858)

Explorer:
>-  https://defund.explorers.guru/

## Usefull tools and references
> To set up monitoring for your validator node navigate to [Set up monitoring and alerting for defund validator](https://github.com/kj89/testnet_manuals/blob/main/defund/monitoring/README.md)
>
> To migrate your validator to another machine read [Migrate your validator to another machine](https://github.com/kj89/testnet_manuals/blob/main/defund/migrate_validator.md)

## Set up your defund fullnode
### Option 1 (automatic)
You can setup your defund fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O defund.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/defund/defund.sh && chmod +x defund.sh && ./defund.sh
```

### Option 2 (manual)
You can follow [manual guide](https://github.com/kj89/testnet_manuals/blob/main/defund/manual_install.md) if you better prefer setting up node manually

### Post installation
When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Next you have to make sure your validator is syncing blocks. You can use command below to check synchronization status
```
defundd status 2>&1 | jq .SyncInfo
```

## If your node is experiencing slow synchronization please try commands below:
```
sed -i.bak -e "s/indexer *=.*/indexer = \"null\"/g" $HOME/.defund/config/config.toml
sed -i "s/index-events=.*/index-events=[\"tx.hash\",\"tx.height\",\"block.height\"]/g" $HOME/.defund/config/app.toml
systemctl restart defundd
```
![image](https://user-images.githubusercontent.com/50621007/170612347-40eb0075-c239-4c35-a7ec-716606bd4df9.png)

## Sync your node
### Using snapshot
**Simo | Active Nodes#3233** are providing with light weighted snapshots. Try to search Discord for latest snapshot from this guy.
```
systemctl stop defundd
cd ~/.defund/
cp data/priv_validator_state.json .
rm -rf data
wget http://repository.activenodes.io/snapshots/defund-private-1_2022-07-04.tar.gz
tar xzvf defund*.tar.gz
rm defund*.tar.gz
mv priv_validator_state.json data/
systemctl start defundd
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
defundd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
defundd keys add $WALLET --recover
```

To get current list of wallets
```
defundd keys list
```

### Save wallet info
Add wallet address
```
WALLET_ADDRESS=$(defundd keys show $WALLET -a)
```

Add valoper address
```
VALOPER_ADDRESS=$(defundd keys show $WALLET --bech val -a)
```

Load variables into system
```
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Top up your wallet balance using faucet
To get 20 free tokens in defund-private-1 testnet:
* navigate to https://bitszn.com/faucets.html
* switch to `COSMOS` tab and select `DeFund.Finance Testnet`
* input your wallet address and click `Request`

### Create validator
Before creating validator please make sure that you have at least 1 fetf (1 fetf is equal to 1000000 ufetf) and your node is synchronized

To check your wallet balance:
```
defundd query bank balances $WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
defundd tx staking create-validator \
  --amount 1000000ufetf \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(defundd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID
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
sudo ufw allow 26656,26660/tcp
sudo ufw enable
```

## Monitoring
To monitor and get alerted about your validator health status you can use my guide on [Set up monitoring and alerting for defund validator](https://github.com/kj89/testnet_manuals/blob/main/defund/monitoring/README.md)

## Calculate synchronization time
This script will help you to estimate how much time it will take to fully synchronize your node\
It measures average blocks per minute that are being synchronized for period of 5 minutes and then gives you results
```
wget -O synctime.py https://raw.githubusercontent.com/kj89/testnet_manuals/main/defund/tools/synctime.py && python3 ./synctime.py
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:26657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu defundd -o cat
```

Start service
```
systemctl start defundd
```

Stop service
```
systemctl stop defundd
```

Restart service
```
systemctl restart defundd
```

### Node info
Synchronization info
```
defundd status 2>&1 | jq .SyncInfo
```

Validator info
```
defundd status 2>&1 | jq .ValidatorInfo
```

Node info
```
defundd status 2>&1 | jq .NodeInfo
```

Show node id
```
defundd tendermint show-node-id
```

### Wallet operations
List of wallets
```
defundd keys list
```

Recover wallet
```
defundd keys add $WALLET --recover
```

Delete wallet
```
defundd keys delete $WALLET
```

Get wallet balance
```
defundd query bank balances $WALLET_ADDRESS
```

Transfer funds
```
defundd tx bank send $WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000ufetf
```

### Voting
```
defundd tx gov vote 1 yes --from $WALLET --chain-id=$CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
defundd tx staking delegate $VALOPER_ADDRESS 10000000ufetf --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
defundd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ufetf --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw all rewards
```
defundd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
defundd tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID
```

### Validator management
Edit validator
```
defundd tx staking edit-validator \
--moniker=$NODENAME \
--identity=<your_keybase_id> \
--website="<your_website>" \
--details="<your_validator_description>" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Unjail validator
```
defundd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
systemctl stop defundd
systemctl disable defundd
rm /etc/systemd/system/defund* -rf
rm $(which defundd) -rf
rm $HOME/.defund* -rf
rm $HOME/defund -rf
sed -i '/DEFUND_/d' ~/.bash_profile
```
