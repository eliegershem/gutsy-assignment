#!/bin/bash

# Create kind cluster
echo "Creating kind cluster..."
kind create cluster --name gutsy

# Build the server executable
echo "Building server executable..."
cd services/web-server
CGO_ENABLED=0 GOOS=linux go build -o server

# Build Docker image
echo "Building Docker image..."
docker build -t localhost:5000/web-server:latest .

# Load the image into kind cluster
echo "Loading image into kind cluster..."
kind load docker-image --name gutsy localhost:5000/web-server:latest

# Return to project root
cd ../..

# Install Redis helm chart
echo "Installing Redis..."
helm install redis ./charts/redis -n web-server -f ./values/redis/values.yaml --create-namespace

# create configmap for redis data
echo "Creating redis data configmap..."
kubectl create configmap redis-data --from-file=data.rdb=./data/data.rdb -n web-server

# Wait for Redis to be ready
echo "Waiting for Redis to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=redis -n web-server --timeout=180s

# Install web-server helm chart
echo "Installing web-server..."
helm install web-server ./charts/web-server -n web-server -f ./values/web-server/values.yaml
