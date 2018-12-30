# **Experimental - Under Development - Use at your own risk**

# Decred Kubernetes

This repo is to deploy the various Decred software using Kubernetes to provide development and hopefully production environments when everything is settle.

# Requirements

* minikube version: v0.31.0
* Docker version 18.09.0, build 4d60db4
* Kubernetes Client Version: v1.13.1
* Kubernetes Server Version: v1.10.0

# Kubernetes Environment

## Minikuke

```bash
minikube start --cpus 4 --memory 4096 --disk-size 30GB
```

## AWS

Follow the [AWS](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/blob/master/AWS.md) instructions.

# Deployments

The deployments currently available:

* [cold-wallet](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/tree/master/cold-wallet)
* [dcrstakepool](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/tree/master/dcrstakepool)
* [dcrdata](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/tree/master/dcrdata)
* politeia (ongoing)

# Contribution

All comments and contribution are welcome. You can contact me at oswald@continuous.lu

# Next Steps

* Adding politeia
* Adding DcrTime
* Adding monitoring and alerting
* Adding Backup and Restore

# Issue Tracker

The integrated [github issue](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/issues) tracker is used for this project.

# Version History

* 0.1.2  Added DrcData and Reorganized by projects
* 0.1.1  Changed to Statefulset
* 0.1.0  Initial release for development in testnet operations
