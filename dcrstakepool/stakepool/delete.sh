#!/bin/bash

kubectl delete services voting-wallet
kubectl delete deployment stakepoold-node
kubectl delete secrets rpc-pass rpc-user coldwalletextpub wallet-pass
kubectl delete configmap stakepoold-config
kubectl delete configmap testnet-config
kubectl delete configmap stakepoold-bootscript
kubectl delete pvc dcrd-pv-claim voting-wallet-pv-claim
