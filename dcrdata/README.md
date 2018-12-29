# Configure DcrData

```bash
kubectl delete configmap dcrdata-bootscript
kubectl create configmap dcrdata-bootscript --from-file=dcrdata-bootscript.sh
```

# Creating DcrData deployment

```bash
kubectl create -f dcrdata-deployment.yaml
```

# Accessing DcrData

```bash
minikube service list
```
