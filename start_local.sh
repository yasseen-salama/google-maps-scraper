#!/bin/bash

# Load Backend Env
if [ -f .env.development ]; then
    source .env.development
elif [ -f .env ]; then
    source .env
else
    echo "Error: No .env.development or .env file found."
    exit 1
fi

# Load Frontend Env (for Clerk keys) and prepare for build
FRONTEND_DIR="../google-maps-scraper-webapp"
if [ -d "$FRONTEND_DIR" ]; then
    if [ -f "$FRONTEND_DIR/.env.development" ]; then
        echo "Loading frontend .env.development..."
        set -a
        source "$FRONTEND_DIR/.env.development"
        set +a
        
        # Copy to .env for Docker build
        cp "$FRONTEND_DIR/.env.development" "$FRONTEND_DIR/.env"
        echo "Debug: Content of frontend .env:"
        cat "$FRONTEND_DIR/.env"
    elif [ -f "$FRONTEND_DIR/.env" ]; then
        echo "Loading frontend .env..."
        set -a
        source "$FRONTEND_DIR/.env"
        set +a
    fi
fi

# Replace 127.0.0.1 or localhost with host.docker.internal in DSN
# This is required for Docker containers to access the host's database on Mac/Windows
export DSN=$(echo $DSN | sed 's/127.0.0.1/host.docker.internal/g' | sed 's/localhost/host.docker.internal/g')

echo "Starting Google Maps Scraper with Docker..."
echo "Using DSN: $DSN"

# Run Docker Compose with the dev configuration
docker compose -f docker-compose.dev.yaml up --build
