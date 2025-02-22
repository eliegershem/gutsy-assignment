#!/bin/bash

# Build the server executable
echo "Building server executable..."
cd services/web-server
CGO_ENABLED=0 GOOS=linux go build -o server

# Build Docker image
echo "Building Docker image..."
docker build -t localhost:5000/web-server:latest .

# Return to project root
cd ../..

# Create kind cluster using external config
echo "Creating kind cluster..."
kind create cluster --name gutsy --config=./kind-config/cluster-config.yaml

# Load the image into kind cluster
echo "Loading image into kind cluster..."
kind load docker-image --name gutsy localhost:5000/web-server:latest

# Install NGINX Ingress Controller
echo "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller
echo "Waiting for ingress controller..." && sleep 10
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Install Redis helm chart
echo "Installing Redis..."
helm install redis ./charts/redis -n web-server -f ./values/redis/values.yaml --create-namespace

# create configmap for redis data
echo "Creating redis data configmap..."
kubectl create configmap redis-data --from-file=data.rdb=./data/data.rdb -n web-server

# Wait for Redis to be ready
echo "Waiting for Redis to be ready..." && sleep 10
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=redis -n web-server --timeout=120s

# Generate TLS certificate
echo "Generating TLS certificate..."
chmod +x ./scripts/generate-cert.sh
./scripts/generate-cert.sh

# Create TLS secret
echo "Creating TLS secret..."
kubectl create secret tls web-server-tls \
    --key=certs/server.key \
    --cert=certs/server.crt \
    -n web-server

# Install web-server helm chart
echo "Installing web-server..."
helm install web-server ./charts/web-server -n web-server -f ./values/web-server/values.yaml

# Add entry to hosts file
echo "Adding entry to /etc/hosts..."
echo "127.0.0.1 web-server.local" | sudo tee -a /etc/hosts
