#!/bin/bash

echo -e "\033[0;35m"
echo " :::    ::: ::::::::::: ::::    :::  ::::::::  :::::::::  :::::::::: ::::::::  ";
echo " :+:   :+:      :+:     :+:+:   :+: :+:    :+: :+:    :+: :+:       :+:    :+: ";
echo " +:+  +:+       +:+     :+:+:+  +:+ +:+    +:+ +:+    +:+ +:+       +:+        ";
echo " +#++:++        +#+     +#+ +:+ +#+ +#+    +:+ +#+    +:+ +#++:++#  +#++:++#++ ";
echo " +#+  +#+       +#+     +#+  +#+#+# +#+    +#+ +#+    +#+ +#+              +#+ ";
echo " #+#   #+#  #+# #+#     #+#   #+#+# #+#    #+# #+#    #+# #+#       #+#    #+# ";
echo " ###    ###  #####      ###    ####  ########  #########  ########## ########  ";
echo -e "\e[0m"

sleep 2

# set vars
echo -e "\e[1m\e[32mReplace <NODENAME> below with the name of your node\e[0m"
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo -e "\e[1m\e[32mReplace <WALLET_ADDRESS> below with your account address from Polkadot.js wallet\e[0m"
if [ ! $WALLET_ADDRESS ]; then
	read -p "Enter wallet address: " WALLET_ADDRESS
	echo 'export WALLET_ADDRESS='$WALLET_ADDRESS >> $HOME/.bash_profile
fi
echo -e "\e[1m\e[32mReplace <PLOT_SIZE> with plot size in gigabytes or terabytes, for instance 100G or 2T (but leave at least 10G of disk space for node)\e[0m"
if [ ! $PLOT_SIZE ]; then
	read -p "Enter plot size: " PLOT_SIZE
	echo 'export PLOT_SIZE='$PLOT_SIZE >> $HOME/.bash_profile
fi
source ~/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET_ADDRESS\e[0m"
echo -e "Your plot size: \e[1m\e[32m$PLOT_SIZE\e[0m"
echo -e '================================================='
sleep 3

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update packages
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# update dependencies
sudo apt install curl jq ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y

# update executables
cd $HOME
rm -rf subspace-*
APP_VERSION=$(curl -s https://api.github.com/repos/subspace/subspace/releases/latest | jq -r ".tag_name" | sed "s/runtime-/""/g")
wget -O subspace-node https://github.com/subspace/subspace/releases/download/${APP_VERSION}/subspace-node-ubuntu-x86_64-${APP_VERSION}
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/${APP_VERSION}/subspace-farmer-ubuntu-x86_64-${APP_VERSION}
chmod +x subspace-*
mv subspace-* /usr/local/bin/

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create subspace-node service 
sudo tee <<EOF >/dev/null /etc/systemd/system/subspaced.service
[Unit]
Description=Subspace Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which subspace-node) \\
--chain="gemini-1" \\
--execution="wasm" \\
--pruning=1024 \\
--keep-blocks=1024 \\
--validator \\
--name="$NODENAME"
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# create subspaced-farmer service 
sudo tee <<EOF >/dev/null /etc/systemd/system/subspaced-farmer.service
[Unit]
Description=Subspace Farmer
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which subspace-farmer) farm \\
--reward-address=$WALLET_ADDRESS \\
--plot-size=$PLOT_SIZE
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
subspace-farmer wipe
subspace-node purge-chain --chain gemini-1 -y
sleep 5
systemctl restart subspaced
sleep 20
systemctl restart subspaced-farmer
sleep 5

echo "==================================================="
echo -e '\e[32mCheck node status\e[39m' && sleep 1
if [[ `service subspaced status | grep active` =~ "running" ]]; then
  echo -e "Your Subspace node \e[32minstalled and running\e[39m!"
else
  echo -e "Your Subspace node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
echo -e "Check your node logs: \e[journalctl -fu subspaced -o cat\e[39m"
sleep 2
echo "==================================================="
echo -e '\e[32mCheck farmer status\e[39m' && sleep 1
if [[ `service subspaced-farmer status | grep active` =~ "running" ]]; then
  echo -e "Your Subspace farmer \e[32minstalled and running\e[39m!"
else
  echo -e "Your Subspace farmer \e[31mwas not installed correctly\e[39m, please reinstall."
fi
echo -e "Check your farmer logs \e[32mjournalctl -fu subspaced-farmer -o cat\e[39m"
echo -e "If you are having issues please try to restart farmer service: \e[32msystemctl restart subspaced-farmer\e[39m"
