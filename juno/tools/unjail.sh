#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
DELAY=300 #Delay time in seconds
for (( ;; )); do
        JAIL=$(junod q staking validator $(junod keys show ${WALLET} --bech val -a) | grep jailed:);
        if [[ ${JAIL} == *"false"* ]]; then
            echo -e "${GREEN}${JAIL} \n"
        else
            echo -e "${GREEN}${JAIL} \n"
            echo -e $(junod tx slashing unjail --chain-id ${JUNO_CHAIN_ID} --from ${WALLET} --gas=auto --fees=1000$ujunox -y) \n;
            sleep 1
        fi
        for (( timer=${DELAY}; timer>0; timer-- ))
        do
                printf "* sleep for ${RED}%02d${NC} sec\r" $timer
                sleep 1
        done
done
