#!/bin/bash
for (( ;; )); do
	echo -e "\033[0;32mCollecting rewards!\033[0m"
	kujirad tx distribution withdraw-rewards $KUJIRA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$KUJIRA_CHAIN_ID --fees=250ukuji --yes
	echo -e "\033[0;32mWaiting 30 seconds before requesting balance\033[0m"
	sleep 30
	AMOUNT=$(kujirad query bank balances $KUJIRA_WALLET_ADDRESS | grep amount | awk '{split($0,a,"\""); print a[2]}')
	AMOUNT=$(($AMOUNT - 500))
	AMOUNT_STRING=$AMOUNT"ukuji"
	echo -e "Your total balance: \033[0;32m$AMOUNT_STRING\033[0m"
	 kujirad tx staking delegate $KUJIRA_VALOPER_ADDRESS $AMOUNT_STRING --from $WALLET --chain-id $KUJIRA_CHAIN_ID --fees=250ukuji --yes
	echo -e "\033[0;32m$AMOUNT_STRING staked! Restarting in 3600 sec!\033[0m"
	sleep 3600
done
