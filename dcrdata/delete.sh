#!/bin/bash

kubectl delete -f dcrdata-deployment.yaml
kubectl delete configmap dcrdata-bootscript -n dcrdata
kubectl delete namespace dcrdata
