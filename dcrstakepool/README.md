# **Experimental - Under Development - Use at your own risk**

# Decred Stake Pool Kubernetes

[dcrstakepool](https://github.com/decred/dcrstakepool) is a web application which coordinates generating 1-of-2 multisig addresses on a pool of dcrwallet servers so users can purchase proof-of-stake tickets on the Decred network and have the pool of wallet servers vote on their behalf when the ticket is selected.

This repo is to install the Decred Stakepool using Kubernetes and provide development and hopefully in production environments when everything is settle.

Refer to the [Cold-wallet README](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/blob/master/cold-wallet/README.md) for the Ticket Purchasing testing.

# Requirements

* minikube version: v0.31.0
* Docker version 18.09.0, build 4d60db4
* Kubernetes Client Version: v1.13.1
* Kubernetes Server Version: v1.10.0

# Development Environment

```bash
minikube start --cpus 4 --memory 4096 --disk-size 30GB
```

## Configuration

Create a file variables.sh based on the [sample_variables.sh](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/blob/master/dcrstakepool/sample_variables.sh) and set the value.

## Building the docker images

```bash
cd docker/nginx/
docker build -t oswald/nginx .
docker push oswald/nginx:latest

cd ../stakepoold
docker build -t oswald/stakepoold .
docker push oswald/stakepoold:latest

cd ../dcrstakepool
docker build -t oswald/dcrstakepool .
docker push oswald/dcrstakepool:latest
```

NOTE: Replace with your own docker repository.

## Creating the infrastructure

Creation of the mysql and stakepool deployments.

```bash
cd ../dcrstakepool
./dcrstart.sh --init
kubectl create -f ./mysql/mysql-deployment.yaml --save-config=true
kubectl create -f ../stakepool/stakepool-deployment.yaml --save-config=true
```

Once the stakepool is deployed, you will need to configure the wallets for each stakepool pods:

Getting all stakepool pods:
```bash
kubectl get pods -l app=stakepoold-node
```

For each pods run:
```bash
kubectl exec -ti stakepoold-node-X -- sh -c '/home/decred/go/bin/dcrwallet --create $TESTNET'
```

**IMPORTANT NOTE:** If its a first install, create the wallet with a new seed on the first stakepool pod, then on the second when asked if you like to use an existing wallet seed, provide the wallet seed created on the first one. For subsequant install you can use the wallet seed for all your stakepool node. Keep the wallet seed securly.

One the wallets setup on each stakepool pods, you will need to update the configuration with:

```bash
./dcrstart.sh --update-config
```

This add the stakepool pods hosts and wallets certificate names in the kubernetes secrets and configmaps.

You are now ready to create the Decred Stakepool deployment with:

```bash
kubectl create -f dcrstakepool-deployment.yaml --save-config=true
```

Look at the logs when the deployment is ready:

```bash
kubectl logs dcrstakepool-node-0
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

Use https://192.168.99.100:32110 (note the https) to connect to the DCR Stake Pool site.
Note: You may have to wait a minute.

Alternatively you can use port-forward:

kubectl port-forward dcrstakepool-nginx-0 4443:443

and use https://localhost:4443/

## Scaling the Stakepool

```bash
kubectl get statefulsets stakepoold-node
kubectl scale statefulsets stakepoold-node --replicas=YOUR_NUMBER_OF_REPLICAS
```

Create the wallet on the new replica.

```bash
kubectl exec -ti stakepoold-node-X -- sh -c '/go/bin/dcrwallet --create $TESTNET'
```

Applying changes to your infrastructure

```bash
./dcrstart.sh --apply
```

# Deploying the infrastructure on AWS

Follow the [AWS](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/blob/master/AWS.md) instructions.

# Contribution

All comments and contribution are welcome. You can contact me at oswald@continuous.lu

# Next Steps

* When there is sleep, implement state verification instead
* Adding monitoring and alerting
* Adding Backup and Restore

# Issue Tracker

The integrated [github issue](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/issues) tracker is used for this project.

# Version History

* 0.1.1  Changed to Statefulset
* 0.1.0  Initial release for development in testnet operations
