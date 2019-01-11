#!bin/bash

kubectl delete namespace cold-wallet
kubectl delete service -n cold-wallet cold-wallet
kubectl delete deployment cold-wallet -n cold-wallet
kubectl delete secret rpc-pass rpc-user -n cold-wallet
kubectl delete configmaps testnet-config -n cold-wallet
kubectl delete pvc cold-wallet-pv-claim -n cold-wallet
kubectl delete pvc dcrd-pv-claim -n cold-wallet
