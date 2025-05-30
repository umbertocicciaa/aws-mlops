# Helm Chart for My Frontend Application

This Helm chart provides a convenient way to deploy the frontend application on a Kubernetes cluster. It includes all necessary Kubernetes manifests and configurations to get your application up and running.

## Prerequisites

- A Kubernetes cluster (e.g., Minikube, EKS, GKE, AKS)
- Helm installed on your local machine

## Chart Structure

- `templates/`: Contains Kubernetes manifests:
  - `deployment.yaml`: Deployment configuration for the application.
  - `service.yaml`: Service configuration to expose the application.
  - `secrets.yaml`: Secrets configuration for sensitive information.
  - `_helpers.tpl`: Helper functions for templates.
  - `NOTES.txt`: Post-installation instructions.
- `values.yaml`: Default configuration values for the chart.
- `Chart.yaml`: Metadata about the Helm chart.

## Installation and Uninstallation

### Installation

To install the Helm chart, use the provided script:

```sh
./install.sh install
```

This will deploy the frontend application to your Kubernetes cluster using Helm.

### Uninstallation

To remove the deployed application, run:

```sh
./install.sh uninstall
```

This will uninstall the Helm release and clean up associated resources.
