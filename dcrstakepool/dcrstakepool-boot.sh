#!/bin/bash

mkdir -p /root/certs/dcrwallet /root/certs/stakepoold

cd /go/src/app/dcrstakepool

echo "Set DCR_RPC_USER and DCR_RPC_PASS"

unset $DCRSTAKE_POOL_DCR_RPC_USER
unset $DCRSTAKE_POOL_DCR_RPC_PASS

for host in $(echo $WALLET_HOSTS | sed "s/,/ /g")
do
    echo "$host"
    if [ -z "$DCRSTAKE_POOL_DCR_RPC_USER" ]
    then
      export DCRSTAKE_POOL_DCR_RPC_USER=$DCR_RPC_USER
    else
      export DCRSTAKE_POOL_DCR_RPC_USER=$DCRSTAKE_POOL_DCR_RPC_USER,$DCR_RPC_USER
    fi

    if [ -z "$DCRSTAKE_POOL_DCR_RPC_PASS" ]
    then
      export DCRSTAKE_POOL_DCR_RPC_PASS=$DCR_RPC_PASS
    else
      export DCRSTAKE_POOL_DCR_RPC_PASS=$DCRSTAKE_POOL_DCR_RPC_PASS,$DCR_RPC_PASS
    fi
done

# Fix the hidden chars
export VOTING_WALLET_EXT_PUB=$(echo $VOTING_EXT_PUB | sed $'s/[^[:print:]\t]//g')

# Wait while Wallet created
while [ ! -f /root/certs/stakepoold/*.cert ]
do
    echo "$(date) - Please upload the Certificates with: ./dcrstart.sh --upload-cert"
  sleep 10
done

sleep 10

# Set Readyness Probe Test
touch /root/alive.txt

dcrstakepool --coldwalletextpub=$COLD_WALLET_EXT_PUB --apisecret=$API_SECRET --cookiesecret=$COOKIE_SECRET --dbpassword=$STAKEPOOL_MYSQL_DB_PASSWORD --dbhost=mysql --adminips=$ADMIN_IPS --adminuserids=$ADMIN_IDS --votingwalletextpub=$VOTING_WALLET_EXT_PUB --wallethosts=$WALLET_HOSTS --walletcerts=$WALLET_CERTS --walletusers=$DCRSTAKE_POOL_DCR_RPC_USER --walletpasswords=$DCRSTAKE_POOL_DCR_RPC_PASS --maxvotedage=8640 --poolfees=7.5 --stakepooldhosts=$WALLET_HOSTS --stakepooldcerts=$STAKEPOOL_CERTS --poolemail=$POOL_EMAIL --poollink=$POOL_LINK --smtpfrom=$SMTP_FROM --smtphost=$SMTP_HOST --smtpusername=$SMTP_USERNAME --smtppassword=$SMTP_PASSWORD $TESTNET
