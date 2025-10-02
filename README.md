# mantis-deploy

Deploys Mantis and necessary services with Helm and Kubernetes.

By default, the chart starts the following services:

1. **Mantis Control Plane** - This is the main service that runs the Mantis Control Plane.
2. **Mantis API** - This is the API service that exposes Mantis API.
3. **Mantis Agent** - Two mantis agents are started by default. These are the agents that run the
   Mantis jobs.
4. **Mantis Publisher** - This is a sample service that publishes events to Mantis.

# Deploying locally

These steps use minikube to deploy Mantis locally.
You can use any Kubernetes cluster to deploy the Mantis chart.

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
    eval $(minikube -p minikube docker-env)
    ```
   From this point on, `docker` command points to minikube's Docker instance.

3. Use Helm to deploy the Mantis stack on minikube
    ```sh
    cd mantis-stack
    helm upgrade --install mantis-stack .
    ```

4. You can now look at minikube dashboard via the following command to verify if all the pods are
   running successfully.
   The pods may take a few minutes to start up.
   ```sh
   minikube dashboard
   ```

5. By default, the Mantis stack starts the `SharedMrePublishEventSource` source job that allows
   services to publish events to Mantis.
   You can verify that the job is running successfully by looking at the Mantis UI.
   For this, set up port-forwarding to the Mantis API service.
   Mantis API service is exposed on port 7001. You can port-forward a local port to port 7001 of
   container using
   ```sh
   kubectl port-forward  deployment.apps/mantis-api 7001
   ```
   You can now access [Mantis UI](https://netflix.github.io/mantis-ui) with `http://localhost:7001`
   as the `Mantis Master API URL`.
   You can verify that the `SharedMrePublishEventSource` job is running successfully by looking at
   the [Jobs tab](https://netflix.github.io/mantis-ui/#/jobs) in the UI or
   by looking at the job cluster status on
   the [Job Cluster Page](https://netflix.github.io/mantis-ui/#/clusters/SharedMrePublishEventSource).

6. You can now run MQL (Mantis Query Language) queries against the Mantis Publisher service to
   verify
   that the events are being published.
   For this, let's run the following queries which should only propagate android events from the
   publisher service.
   ```sql
    SELECT * FROM defaultStream where e["deviceType"] == "android"
    ```

   To run the query, you can use the MQL Query UI on
   the [Job Cluster Page](https://netflix.github.io/mantis-ui/#/clusters/SharedMrePublishEventSource).
   ```angular2html
   http://localhost:7001/api/v1/jobconnectbyid/SharedMrePublishEventSource-1?clientId=sundaram&subscriptionId=sundaram&criterion=SELECT%20%2A%20FROM%20defaultStream%20where%20e%5B%22deviceType%22%5D%20%3D%3D%20%22android%22
   ```

## Deploying Mantis stack with local changes

1. We need a Docker registry to host the images that can be read from within the minikube cluster.
   To achieve this, start a local Docker registry in minikube Docker (the `docker` command is
   talking to minikube
   Docker)
    ```sh
    docker run -d -p 5001:5000 --restart=always --name registry registry:2
    ```
   We tunnel port `5001` to `5000`, you can choose any available port.

2. Build Docker images from your checked out version
   of [Mantis codebase](https://github.com/Netflix/mantis).
   The images are automatically pushed to the local Docker registry used by Minikube as long as the
   shell has Minikube’s environment.
    ```sh
    # Run this command from mantis root directory
    ./gradlew dockerPushImage
    ```

3. Make local changes to `mantis-controlplane/values.yaml` to fetch local image. Update the `image`
   value:
    ```
    image: localhost:5001/netflixoss/mantiscontrolplaneserver:latest
    ```

4. local this local image from local machine the minikube container runtime
   ```
   minikube image load localhost:5001/netflixoss/mantiscontrolplaneserver:latest
   ```

5. temporarily change the imagePullPolicy from `Always` to `IfNotPresent` (this is must!!)

6. Update Helm charts to pick up `values.yaml` changes
    ```sh
    # Run this command from mantis-stack directory   
    helm dependency update  
    ```
7. verify the k8s yaml config output with
   ```
   > cd mantis-stack
   > helm template mantis-stack . -f values.yaml
   to validate the imagePullPolicy if changed or not

8. Verify the services are running with Kubernetes CLI
    ```sh
    kubectl get all
    ```

## Useful commands

1. To make calls to mantis-master, you can port-forward a local port to port 8100 of container using
   ```sh
   kubectl port-forward  deployment.apps/mantis-controlplane 8100
   ```
