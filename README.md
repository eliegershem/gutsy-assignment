# Gutsy Assignment
This repository contains the gutsy assignment project, a comprehensive setup for a web server with SSL encryption, load balancing, and caching using Kubernetes and Helm charts.

## Prerequisites
Before installing the project, you need to install the required tools. This project is compatible with Ubuntu 22. Run the following commands:

```bash
chmod +x scripts/install-tools.sh
./scripts/install-tools.sh
```
After tools installation, either:
1. Log out and log back in, OR
2. Run these commands in your current terminal:
```bash
newgrp docker
source ~/.bashrc
```

## Installation
To install the project, follow these steps:

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

This script will build the server executable, create a Docker image, set up a kind cluster, load the image into the cluster, install the NGINX Ingress Controller, install Redis, generate TLS certificates, and install the web-server Helm chart. The compiled server executable can be found under `services/web-server/` with the name `server`.

## Uninstallation
To uninstall the project, follow these steps:

```bash
chmod +x scripts/uninstall.sh
./scripts/uninstall.sh
```

This script will remove the kind cluster.

## Testing
After deploying the project, you can test it by running the following curl command in your terminal:
```bash
curl -k https://web-server.local/api/v1/music-albums\?key\=100
```
You should see the response {"album":"Iron Maiden"}. If you encounter any issues, check the logs of the web server and other components to identify the problem.
