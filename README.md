# mantis-deploy

Deploys Mantis and necessary services with Helm and Kubernetes.

# Deploy locally

## Prerequisites

- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Install [minikube](https://minikube.sigs.k8s.io/docs/start/)
- Install [helm](https://helm.sh/docs/intro/install/)

## Steps

1. Start minikube
```sh
minikube start
```


2. Point docker-cli to Docker running in minikube
```sh
minikube docker-env
eval $(minikube -p minikube docker-env)
```
From this point on, `docker` command points to minikube's Docker instance.

3. Start local Docker registry in minikube Docker (the `docker` command is talking to minikube Docker)
```sh
docker run -d -p 5001:5000 --restart=always --name registry registry:2
```
We tunnel port `5001` to `5000`, you can choose any available port.

4. Build a new image from the Mantis repo (e.g. in the `mantis/mantis-control-plane` directory)
```sh
./buildDockerImage.sh
```

5. Tag this image with a tag for the local registry
```sh
docker image tag netflixoss/mantiscontrolplaneserver localhost:5001/netflixoss/mantiscontrolplaneserver
```

6. Push image to local registry
```sh
docker push localhost:5001/netflixoss/mantiscontrolplaneserver  
```

7. Make local changes to `mantis-controlplane/values.yaml` to fetch local image. Update the `image` value:
```
image: localhost:5001/netflixoss/mantiscontrolplaneserver:latest
```

8. Update Helm charts to pick up `values.yaml` changes
```sh
helm dependency update  
```

9. Use Helm to deploy the Mantis stack on minikube
```sh
cd mantis-stack
helm upgrade --install --reset-values --force mantis-stack .  
```

10. Verify the services are running with Kubernetes CLI
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