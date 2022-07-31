<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/QmGfDKrA" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/172488614-7d93b016-5fe4-4a51-99e2-67da5875ab7a.png">
</p>

# Manual node setup
If you want to setup fullnode manually follow the steps below

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
PALOMA_PORT=10
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export PALOMA_CHAIN_ID=paloma-testnet-6" >> $HOME/.bash_profile
echo "export PALOMA_PORT=${PALOMA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl build-essential git wget jq make gcc tmux -y
```

## Install go
```
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi
```

## Download and build binaries
```
wget -O - https://github.com/palomachain/paloma/releases/download/v0.4.1-alpha/paloma_0.4.1-alpha_Linux_x86_64.tar.gz | \
sudo tar -C /usr/local/bin -xvzf - palomad
sudo chmod +x /usr/local/bin/palomad
sudo wget -P /usr/lib https://github.com/CosmWasm/wasmvm/raw/main/api/libwasmvm.x86_64.so
```

## Config app
```
palomad config chain-id $PALOMA_CHAIN_ID
palomad config keyring-backend test
palomad config node tcp://localhost:${PALOMA_PORT}657
```

## Init app
```
palomad init $NODENAME --chain-id $PALOMA_CHAIN_ID
```

## Download genesis and addrbook
```
wget -O ~/.paloma/config/genesis.json https://raw.githubusercontent.com/palomachain/testnet/master/paloma-testnet-6/genesis.json
wget -O ~/.paloma/config/addrbook.json https://raw.githubusercontent.com/palomachain/testnet/master/paloma-testnet-6/addrbook.json
```

## Set seeds and peers
```
SEEDS=""
PEERS="ae6eaae5fb773948281b65eca4ec031a40e42b17@50.116.15.176:26656,8912f06b337b9f773225bd59e5a139e5af7eb852@65.108.235.107:10656,abc044647c4906472ca3564c5b30c6cede44e9d1@23.88.77.188:20003,b1d4dd40ea8aeb01443e92d941a719ccd7a2f4b5@130.185.118.165:10656,2d81fe626fcbeb39baa7f0e5f80ce397c87b2ee1@185.144.99.227:26656,b522201fa15b07ee3b503e853fe90cb44cf56a3c@168.119.229.69:26656,1cf04bee1fbf28f6a6a3da3d1aa13f89d0d4c296@185.244.181.27:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.paloma/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PALOMA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PALOMA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PALOMA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PALOMA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PALOMA_PORT}660\"%" $HOME/.paloma/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PALOMA_PORT}317\"%; s%^address = \":8080\"%address = \":${PALOMA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PALOMA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PALOMA_PORT}091\"%" $HOME/.paloma/config/app.toml
```

## Disable indexing
```
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.paloma/config/config.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.paloma/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.paloma/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.paloma/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.paloma/config/app.toml
```

## Set minimum gas price
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ugrain\"/" $HOME/.paloma/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.paloma/config/config.toml
```

## Reset chain data
```
palomad tendermint unsafe-reset-all --home $HOME/.paloma
```

## Create service
```
sudo tee /etc/systemd/system/palomad.service > /dev/null <<EOF
[Unit]
Description=paloma
After=network-online.target

[Service]
User=$USER
ExecStart=$(which palomad) start --home $HOME/.paloma
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

## Register and start service
```
sudo systemctl daemon-reload
sudo systemctl enable palomad
sudo systemctl restart palomad && sudo journalctl -u palomad -f -o cat
```
