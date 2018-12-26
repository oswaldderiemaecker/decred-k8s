# Decred Wallet

## Starting the Decred Wallet
```bash
kubectl create namespace cold-wallet
kubectl create configmap testnet-config --from-literal=testnet=--testnet -n cold-wallet
kubectl create secret -n cold-wallet generic rpc-user --from-literal=user=YOUR_USER
kubectl create secret -n cold-wallet generic rpc-pass --from-literal=password=YOUR_PASSWORD
kubectl get secrets -n cold-wallet
kubectl create -f cold-wallet-deployment.yaml --save-config
kubectl get pods -n cold-wallet
```

## Creating the Decred wallet

```bash
kubectl exec -ti cold-wallet-0 -n cold-wallet -- sh -c '/go/bin/dcrwallet --create $TESTNET'
```

## Starting the Decred wallets

```bash
kubectl exec -ti cold-wallet-0 -n cold-wallet -- /bin/bash
dcrwallet -u $RPC_USER -P $RPC_PASS $TESTNET
```

## Getting Decred coins

Connect to the Decred Wallet Pod.

```bash
kubectl exec -ti cold-wallet-0 -n cold-wallet -- /bin/bash
```

Create a Decred Address.

```bash
dcrctl --wallet -u $RPC_USER -P $RPC_PASS --testnet getaccountaddress "default"
```

```bash
dcrctl --wallet -u $RPC_USER -P $RPC_PASS --testnet getbalance
```

Goto the [Decred Faucet](https://faucet.decred.org/) site, paste in your account address.

## Submit the Address to the Decred Stakepool

```bash
dcrctl -u $RPC_USER -P $RPC_PASS --testnet --wallet validateaddress YOUR_ACCOUNT_ADDRESS
```

Get the public key address (pubkeyaddr) and paste it in the Address / Submit Address page of the Decred Stakepool.

Verify that your public key address belongs to your wallet.

```bash
dcrctl -u $RPC_USER -P $RPC_PASS --testnet --wallet validateaddress YOUR_PUBLIC_KEY_ADDRESS
```

In the result, you will see fields such as "ismine" and "account" if the address is present.

## Ticket Setting

On the Ticket page.

Your multisignature script for delegating votes has been generated.

Import it locally into your wallet using dcrctl for safe keeping, so you can recover your funds and vote in the unlikely event of a pool failure:

```bash
dcrctl -u $RPC_USER -P $RPC_PASS --testnet --wallet importscript YOUR_MULTISIGNATURE
```

You can now Manual purchasing Tickets (see step 3/B).

```
dcrctl -u $RPC_USER -P $RPC_PASS --testnet --wallet purchaseticket "default" 100 1 YOUR_TICKET_ADDRESS 1 THE_POOL_ADDRESS 7.5
```
