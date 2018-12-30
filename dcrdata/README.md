# DcrData

# Configuration

```bash
kubectl delete configmap dcrdata-bootscript
kubectl create configmap dcrdata-bootscript --from-file=dcrdata-bootscript.sh
```
# DcrData Deployment

```bash
kubectl create -f dcrdata-deployment.yaml
```

# Accessing DcrData

```bash
minikube service list
```
