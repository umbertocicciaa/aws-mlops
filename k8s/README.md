# Kubernetes Manifests for AWS MLOps

This directory contains Kubernetes manifests and configuration files for deploying application frontend on localhost.

## Prerequisites

- Minikube cluster
- `kubectl` configured for your cluster

## Structure

- `deployment.yml` – Deployment YAMLs for frontend service
- `service.yaml` – Service definitions for exposing workloads
- `secrets.yaml` – Secrets definitions for aws credential and env variables

## Usage

1. **Customize** the manifests as needed for your environment.
2. **Start** Bash script. Start application on localhost:

    ```sh
    chmod u+x start.sh
    ./start.sh
    ```
