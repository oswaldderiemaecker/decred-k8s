#!/bin/bash

# Starting DCRD
echo "$(date) - Starting Decred Daemon"
dcrd -u $DCR_RPC_USER -P $DCR_RPC_PASS --txindex $TESTNET &
sleep 40

# Wait while Wallet created
while [ ! -f /root/.dcrwallet/testnet3/wallet.db ]
do
    echo "$(date) - Please connect and create wallet with: dcrwallet --create $TESTNET (Ensure to keep the seed and use the same seed for all wallets)"
  sleep 10
done

# Creating Wallet
#dcrwallet --create $TESTNET

# Starting Wallet
echo "$(date) - Starting dcrwallet"
dcrwallet -u test -P test $TESTNET --pass=$PRIVATE_WALLET_PASS --enablevoting --grpclisten=$(hostname --ip-address) --rpclisten=$(hostname --ip-address) &
sleep 30

# Get Master Public Key
echo "$(date) - Get Master Public Key"
dcrctl --wallet $TESTNET -u test -P test --rpcserver=$(hostname --ip-address) getmasterpubkey default

# Starting the stake pool
sleep 15
echo "$(date) - Starting Stake pool"

# Set the Readiness Probe test
touch /root/alive.txt

#sleep 40000 #debug
stakepoold --dbhost=mysql --dbuser=stakepool --dbpassword=$STAKEPOOL_MYSQL_DB_PASSWORD --coldwalletextpub=$COLD_WALLET_EXT_PUB --dcrdhost=127.0.0.1 --dcrduser=$DCR_RPC_USER --dcrdpassword=$DCR_RPC_PASS --testnet --dcrdcert=../.dcrd/rpc.cert --wallethost=$(hostname --ip-address) --walletcert=../.dcrwallet/rpc.cert --walletuser=$DCR_RPC_USER --walletpassword=$DCR_RPC_PASS --rpclisten=$(hostname --ip-address) $TESTNET
