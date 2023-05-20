# mantis-deploy

Deploys Mantis and necessary services with Helm and Kubernetes.

# Deploy locally

## Prerequisites

- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Install [minikube](https://minikube.sigs.k8s.io/docs/start/)
- Install [helm](https://helm.sh/docs/intro/install/)

## Steps

1. Fetch latest mantis-control-plane image from docker hub [netflixoss/mantiscontrolplaneserver](https://hub.docker.com/r/netflixoss/mantiscontrolplaneserver/tags) OR Build one locally from the [Mantis repo](https://github.com/Netflix/mantis/blob/master/mantis-control-plane/buildDockerImage.sh).

2. Start minikube
```sh
minikube start
```

3. Use Helm to deploy the Mantis stack on minikube
```sh
cd mantis-stack
helm upgrade --install mantis-stack .
```

4. Verify the services are running with Kubernetes CLI
```sh
kubectl get all
```

## Inspection Tips

1. You can also look at minikube dashboard via
```sh
minikube dashboard
```

2. To make calls to mantis-master, you can port-forward a local port to port 8100 of container using
```sh
kubectl port-forward  deployment.apps/mantis-controlplane 8100
```