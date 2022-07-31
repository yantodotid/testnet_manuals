#!/bin/bash
for (( ;; )); do
	echo -e "\033[0;32mCollecting rewards!\033[0m"
	echo -e "${PASSWORD}\n" | celestia-appd tx distribution withdraw-rewards $CELESTIA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CELESTIA_CHAIN_ID --fees=250utia --yes
	echo -e "\033[0;32mWaiting 30 seconds before requesting balance\033[0m"
	sleep 30
	AMOUNT=$(celestia-appd query bank balances $CELESTIA_WALLET_ADDRESS | grep amount | awk '{split($0,a,"\""); print a[2]}')
	AMOUNT=$(($AMOUNT - 500))
	AMOUNT_STRING=$AMOUNT"utia"
	echo -e "Your total balance: \033[0;32m$AMOUNT_STRING\033[0m"
	echo -e "${PASSWORD}\n" |  celestia-appd tx staking delegate $CELESTIA_VALOPER_ADDRESS $AMOUNT_STRING --from $WALLET --chain-id $CELESTIA_CHAIN_ID --fees=250utia --yes
	echo -e "\033[0;32m$AMOUNT_STRING staked! Restarting in 3600 sec!\033[0m"
	sleep 3600
done
