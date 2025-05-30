 #!/bin/bash

CHART_NAME="frontend-chart"
RELEASE_NAME="frontend"
CHART_PATH="."

case "$1" in
  install)
    helm install "$RELEASE_NAME" "$CHART_PATH" -f values.yaml --namespace frontend --create-namespace
    ;;
  uninstall)
    helm uninstall "$RELEASE_NAME" --namespace frontend
    kubectl delete namespace frontend
    ;;
  *)
    echo "Usage: $0 {install|uninstall}"
    exit 1
    ;;
esac