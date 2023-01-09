# mantis-deploy

Deploys Mantis and necessary services with Helm and Kubernetes.

# Deploy locally

## Prerequisites

- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Install [minikube](https://minikube.sigs.k8s.io/docs/start/)

## Steps

1. Build the Mantis control plane Docker image from the [Mantis repo](https://github.com/Netflix/mantis/blob/master/mantis-control-plane/buildDockerImage.sh).

2. Use Helm to deploy the Mantis stack on minikube

```sh
cd mantis-stack
helm upgrade --install mantis-stack .
```

3. Verify the services are running with Kubernetes CLI
```sh
kubectl get all
```