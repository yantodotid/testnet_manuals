<p style="font-size:14px" align="right">
<a href="https://t.me/kjnotes" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/50621007/168689534-796f181e-3e4c-43a5-8183-9888fc92cfa7.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/177221972-75fcf1b3-6e95-44dd-b43e-e32377685af8.png">
</p>

# Generate rebus testnet gentx

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=reb_3333-1" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt-get install make build-essential gcc git jq chrony -y
```

## Install go
```
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
```

## Download and install binaries
```
cd $HOME
git clone https://github.com/rebuschain/rebus.core.git 
cd rebus.core && git checkout testnet
make install
```

## Config app
```
rebusd config chain-id $CHAIN_ID
rebusd config keyring-backend test
```

## Init node
```
rebusd init $NODENAME --chain-id $CHAIN_ID
```

## Recover or create new wallet for mainnet
Option 1 - generate new wallet
```
rebusd keys add $WALLET
```

Option 2 - recover existing wallet
```
rebusd keys add $WALLET --recover
```

## Add genesis account
```
WALLET_ADDRESS=$(rebusd keys show $WALLET -a)
rebusd add-genesis-account $WALLET_ADDRESS 100rebus
```

## Generate gentx
```
rebusd gentx $WALLET 100000000000000000000arebus \
--chain-id $CHAIN_ID \
--moniker=$NODENAME \
--commission-rate=0.05 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.01
```

## Things you have to backup
- `24 word mnemonic` of your generated wallet
- contents of `$HOME/.rebusd/config/*`

## Submit PR with Gentx
1. Copy the contents of ${HOME}/.rebusdd/config/gentx/gentx-XXXXXXXX.json.
2. Fork https://github.com/rebuschain/rebus.testnet
3. Create a file <VALIDATOR_NAME>.json under the `rebus_3333-1/gentxs/` folder in the forked repo, paste the copied text into the file.
4. Create a Pull Request to the main branch of the repository

### Await further instructions!