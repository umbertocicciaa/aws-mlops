# Kubernetes Manifests for AWS MLOps

This directory contains Kubernetes manifests and configuration files for deploying application frontend on localhost.

## Structure

- `deployments.yml` – Deployment YAMLs for frontend service
- `service.yml` – Service definitions for exposing workloads
- `secrets.yml` – Secrets definitions for aws credential and env variables

## Usage

1. **Customize** the manifests as needed for your environment.
2. **Start** Bash script. Start application on localhost:

    ```sh
    chmod u+x start.sh
    ./start.sh
    ```

## Prerequisites

- Minikube cluster
- `kubectl` configured for your cluster
