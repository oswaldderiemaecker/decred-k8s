#!/bin/bash

rm ./certs/dcrwallet/*.cert
rm ./certs/stakepoold/*.cert

rm dcrpoolstake.crt dcrpoolstake.key

kubectl delete -f dcrstakepool-deployment.yaml
kubectl delete -f ../stakepool/stakepool-deployment.yaml
kubectl delete -f ../mysql/mysql-deployment.yaml

kubectl delete secret --all
kubectl delete configmap --all
kubectl delete pvc --all
kubectl delete pv --all
