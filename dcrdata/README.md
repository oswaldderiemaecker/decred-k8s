# DcrData

[DcrData](https://github.com/decred/dcrdata) is the Decred block explorer, with packages and apps for data collection and storage. Written in Go.

## Building the docker images

```bash
cd ./docker/dcrdata/
docker build -t oswald/dcrdata .
docker push oswald/dcrdata:latest
```

NOTE: Replace with your own docker repository.

# Configuration

```bash
kubectl delete configmap dcrdata-bootscript
kubectl create configmap dcrdata-bootscript --from-file=dcrdata-bootscript.sh
kubectl delete secret pgsql-pass
kubectl create secret generic pgsql-pass --from-literal=password=YOUR_PASSWORD
```
# DcrData Deployment

```bash
kubectl create -f dcrdata-deployment.yaml
```

# Accessing DcrData

```bash
minikube service list
```
