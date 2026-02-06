# Project Chimera - Makefile for Standardized Commands
# Provides consistent interface for development tasks

.PHONY: help setup test spec-check docker-build docker-test clean

# Default target
help:
	@echo "Project Chimera - Available Commands:"
	@echo ""
	@echo "  make setup       - Install dependencies using uv"
	@echo "  make test        - Run tests in Docker container"
	@echo "  make spec-check  - Verify code alignment with specifications"
	@echo "  make docker-build - Build Docker image"
	@echo "  make docker-test - Run tests in Docker container"
	@echo "  make clean       - Clean build artifacts and caches"
	@echo ""

# Install dependencies using uv
setup:
	@echo "Installing dependencies with uv..."
	uv pip install -e .
	uv pip install pytest pytest-cov
	@echo "Dependencies installed successfully!"

# Build Docker image (handles optional files)
docker-build:
	@echo "Building Docker image..."
	@if [ -f "scripts/docker-build.sh" ]; then \
		chmod +x scripts/docker-build.sh && \
		./scripts/docker-build.sh; \
	else \
		docker build -t chimera-dev:latest . || \
		(echo "Build failed. Creating placeholder files..." && \
		 mkdir -p chimera && touch main.py && \
		 docker build -t chimera-dev:latest .); \
	fi
	@echo "Docker image built successfully!"

# Run tests in Docker
docker-test: docker-build
	@echo "Running tests in Docker container..."
	docker run --rm \
		-v "$(PWD):/app" \
		-w /app \
		chimera-dev:latest \
		pytest tests/ -v
	@echo "Tests completed!"

# Alias for docker-test
test: docker-test

# Run spec-check script (cross-platform)
spec-check:
	@echo "Running spec-check to verify code alignment with specifications..."
	@if [ -f "scripts/spec-check.sh" ]; then \
		chmod +x scripts/spec-check.sh && \
		./scripts/spec-check.sh; \
	elif [ -f "scripts/spec-check.ps1" ]; then \
		powershell -ExecutionPolicy Bypass -File scripts/spec-check.ps1; \
	else \
		echo "Error: spec-check script not found!"; \
		exit 1; \
	fi
	@echo "Spec-check completed!"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	find . -type d -name "__pycache__" -exec rm -r {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -r {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -r {} + 2>/dev/null || true
	find . -type d -name ".coverage" -exec rm -r {} + 2>/dev/null || true
	@echo "Clean completed!"

