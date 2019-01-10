# **Experimental - Under Development - Use at your own risk**

# Decred Stake Pool Kubernetes

[dcrstakepool](https://github.com/decred/dcrstakepool) is a web application which coordinates generating 1-of-2 multisig addresses on a pool of dcrwallet servers so users can purchase proof-of-stake tickets on the Decred network and have the pool of wallet servers vote on their behalf when the ticket is selected.

This folder is to install the Decred Stakepool using Kubernetes and provide development and hopefully production environments when everything is settle.

Refer to the [Cold-wallet README](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/blob/master/cold-wallet/README.md) for the Ticket Purchasing testing.

## Configuration

Create a file variables.sh based on the [sample_variables.sh](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/blob/master/dcrstakepool/sample_variables.sh) and set the value.

## Building the docker images

```bash
cd ../docker/nginx/
docker build -t oswald/nginx .
docker push oswald/nginx:latest

cd ../../dcrstakepool/
cd ./docker/stakepoold
docker build -t oswald/stakepoold .
docker push oswald/stakepoold:latest

cd ../dcrstakepool/
docker build -t oswald/dcrstakepool .
docker push oswald/dcrstakepool:latest
```

NOTE: Replace with your own docker repository.

## Creating the infrastructure

Creation of the mysql deployments.

```bash
cd ../..
./dcrstart.sh --init
kubectl create -f ./mysql/mysql-deployment.yaml --save-config=true
kubectl get pods -l app=dcrstakepool-mysql -n dcrstakepool --watch
```
Wait till the READY state is 1/1 STATUS Running. Then press CTRL-C.

Create the stakepool deployments.

```bash
kubectl create -f ./stakepool/stakepool-deployment.yaml --save-config=true
```

Getting all stakepool pods:
```bash
kubectl get pods -l app=stakepoold-node -n dcrstakepool --watch
```

Wait till all stakepool pods are READY state is 1/1 STATUS Running. Then press CTRL-C.

Once the stakepool is deployed, you will need to configure the wallets for each stakepool pods:

**Wait that both stakepool nodes are Running.**

For each pods run:
```bash
kubectl exec -ti stakepoold-node-X -n dcrstakepool -- sh -c '/home/decred/go/bin/dcrwallet --create $TESTNET'
```

**IMPORTANT NOTE:** If its a first install, create the wallet with a new seed on the first stakepool pod, then on the second when asked if you like to use an existing wallet seed, provide the wallet seed created on the first one. For subsequant install you can use the wallet seed for all your stakepool node. Keep the wallet seed securly.

Once the wallets setup on each stakepool pods, you will need to update the configuration with:

```bash
./dcrstart.sh --update-config
```

This add the stakepool pods hosts and wallets certificate names in the kubernetes secrets and configmaps.

You are now ready to create the Decred Stakepool deployment with:

```bash
kubectl create -f dcrstakepool-deployment.yaml --save-config=true
kubectl get pods -n dcrstakepool --watch
```

Wait till all READY states are 1/1 STATUS Running. Then press CTRL-C.

Look at the logs till you get the following message:

```bash
kubectl logs dcrstakepool-node-0 -n dcrstakepool -f --tail=20
...
Please upload the Certificates with: ./dcrstart.sh --upload-cert
...
```
Then finaly, upload the dcrwallet and stakepoold certificates:

```bash
./dcrstart.sh --upload-cert
```

Get the service ports with minikube:

```bash
minikube service list
|-------------|----------------------|--------------------------------|
|  NAMESPACE  |         NAME         |              URL               |
|-------------|----------------------|--------------------------------|
| cold-wallet | cold-wallet          | No node port                   |
| default     | dcrstakepool-nginx   | http://192.168.99.100:32322    |
|             |                      | http://192.168.99.100:32110    |
...
```

**NOTE: Use https://192.168.99.100:32110 (note the https) to connect to the DCR Stake Pool site. You may have to wait a minute or so.**

Alternatively you can use port-forward:

```bash
kubectl port-forward dcrstakepool-nginx-0 4443:443
```

and use https://localhost:4443/

## Scaling the Stakepool

```bash
kubectl get statefulsets stakepoold-node -n dcrstakepool
kubectl scale statefulsets stakepoold-node -n dcrstakepool --replicas=YOUR_NUMBER_OF_REPLICAS
kubectl get pods -n dcrstakepool --watch
```

Create the wallet on the new replica.

```bash
kubectl exec -ti stakepoold-node-X -n dcrstakepool -- sh -c '/home/decred/go/bin/dcrwallet --create $TESTNET'
```

Applying changes to your infrastructure

```bash
./dcrstart.sh --apply
```

## Deleting the deployment

```bash
./delete.sh
```

# Contribution

All comments and contribution are welcome. You can contact me at oswald@continuous.lu

# Issue Tracker

The integrated [github issue](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/issues) tracker is used for this project.
