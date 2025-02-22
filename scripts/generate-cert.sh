#!/bin/bash

# Create directory for certificates if it doesn't exist
mkdir -p certs

# Generate private key and self-signed certificate
openssl req -x509 \
    -newkey rsa:4096 \
    -keyout certs/server.key \
    -out certs/server.crt \
    -days 365 \
    -nodes \
    -subj "/CN=web-server.local" \
    -addext "subjectAltName = DNS:web-server.local,DNS:localhost"