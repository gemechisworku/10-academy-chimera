#!/bin/bash
# Docker build script that handles optional files gracefully

set -e

echo "Preparing Docker build context..."

# Create temporary directory structure for optional files
mkdir -p .docker-temp/chimera
touch .docker-temp/main.py

# Copy optional files if they exist
if [ -d "chimera" ] && [ "$(ls -A chimera)" ]; then
    cp -r chimera/* .docker-temp/chimera/ 2>/dev/null || true
fi

if [ -f "main.py" ]; then
    cp main.py .docker-temp/main.py
fi

# Build Docker image
echo "Building Docker image..."
docker build -t chimera-dev:latest .

# Cleanup
rm -rf .docker-temp

echo "Docker image built successfully!"

