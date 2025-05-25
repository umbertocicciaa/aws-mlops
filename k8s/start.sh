echo "Starting Docker daemon..."
open --background -a Docker

while ! docker system info > /dev/null 2>&1; do
    echo "Waiting for Docker daemon to start..."
    sleep 2
done


echo "Starting minikube..."
minikube start

kubectl config use-context minikube

echo "Applying Kubernetes manifests..."

while ! minikube status | grep -q "host: Running"; do
    echo "Waiting for minikube to be ready..."
    sleep 2
done

kubectl apply -f .
echo "Deployment complete."

echo "Opening minikube tunnel for service access..."
minikube tunnel &
echo "Minikube tunnel started in the background."