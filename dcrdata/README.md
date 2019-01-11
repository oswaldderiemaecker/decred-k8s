# DcrData

[DcrData](https://github.com/decred/dcrdata) is the Decred block explorer, with packages and apps for data collection and storage. Written in Go.

## Building the docker images

```bash
cd ./docker/dcrdata/
docker build -t oswald/dcrdata .
docker push oswald/dcrdata:latest
```

**NOTE: Replace with your own docker repository.**

# Configuration

```bash
kubectl create namespace dcrdata
kubectl create configmap testnet-config --from-literal=testnet=--testnet -n dcrdata
kubectl create configmap dcrdata-bootscript --from-file=dcrdata-bootscript.sh -n dcrdata
kubectl create secret generic pgsql-pass --from-literal=password=YOUR_PASSWORD -n dcrdata
kubectl create secret generic dcrdata-rpc-user --from-literal=user=YOUR_USER -n dcrdata
kubectl create secret generic dcrdata-rpc-pass --from-literal=password=YOUR_PASSWORD -n dcrdata
```
# DcrData Deployment

```bash
kubectl create -f dcrdata-deployment.yaml
kubectl get pods --watch -n dcrdata
```
Wait till dcrdata's pods are READY state is 1/1 STATUS Running. Then press CTRL-C.

# Accessing DcrData

```bash
minikube service list
|-------------|----------------------|--------------------------------|
|  NAMESPACE  |         NAME         |              URL               |
|-------------|----------------------|--------------------------------|
| cold-wallet | cold-wallet          | No node port                   |
| default     | dcrdata              | http://192.168.99.100:31047    |
| default     | dcrdata-pgsql        | No node port                   |
```

Use http://192.168.99.100:31047 to get access to the DcrData.
