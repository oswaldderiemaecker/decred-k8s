#!/bin/bash

# Starting DCRD
echo "$(date) - Starting Decred Daemon"
dcrd -u $RPC_USER -P $RPC_PASS --txindex 1 --addrindex $TESTNET &

# Wait for DCRD to start
sleep 60

cd /home/decred/go/bin
dcrdata --dcrduser=$RPC_USER --dcrdpass=$RPC_PASS --dcrdcert=/home/decred/.dcrd/rpc.cert --apilisten=$(hostname -i):7777  $TESTNET

touch /home/decred/alive
