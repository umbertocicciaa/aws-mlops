# Docker deamon
echo "Starting Docker daemon..."
open --background -a Docker

while ! docker system info > /dev/null 2>&1; do
    echo "Waiting for Docker daemon to start..."
    sleep 2
done

# Minikube setup
echo "Starting minikube..."
minikube start
kubectl config use-context minikube

echo "Applying Kubernetes manifests..."
while ! minikube status | grep -q "host: Running"; do
    echo "Waiting for minikube to be ready..."
    sleep 2
done

# Kubernetes manifests
kubectl apply -f .
echo "Deployment complete."

# Open minikube tunnel for service access
echo "Opening minikube tunnel for service access..."