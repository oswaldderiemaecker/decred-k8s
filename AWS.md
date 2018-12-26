# AWS Install

# Install Kubernetes

The simplest is to use Kops, follow this [nice tutorial](https://medium.com/containermind/how-to-create-a-kubernetes-cluster-on-aws-in-few-minutes-89dda10354f4).

# Configure the dcrstakepool nginx deployment

Replace in the [dcrstakepool-deployment.yaml](https://github.com/oswaldderiemaecker/dcrstakepool-k8s/blob/master/dcrstakepool/dcrstakepool-deployment.yaml) the type of service NodePort with LoadBalancer like:

```bash
 apiVersion: v1
 kind: Service
 metadata:
   name: dcrstakepool-nginx
   labels:
     app: dcrstakepool-nginx
     tier: frontend
 spec:
   type: NodePort
```

To

```bash
 apiVersion: v1
 kind: Service
 metadata:
   name: dcrstakepool-nginx
   labels:
     app: dcrstakepool-nginx
     tier: frontend
 spec:
   type: LoadBalancer
```

Follow the regular installation.

Once installed. Get the LoadBalancer URL in the AWS Console.
