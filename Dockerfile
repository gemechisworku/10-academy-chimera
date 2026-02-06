# Project Chimera - Development Environment Dockerfile
# Python 3.13 with uv package manager

FROM python:3.13-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install --no-cache-dir uv

# Copy project files (required)
COPY pyproject.toml uv.lock* ./
COPY specs/ ./specs/
COPY tests/ ./tests/
COPY skills/ ./skills/

# Copy source code (optional - will fail gracefully if missing)
# These can be added as implementation progresses
COPY chimera/ ./chimera/
COPY main.py ./

# Install dependencies using uv (including dev dependencies for tests)
RUN uv pip install --system -e ".[dev]"

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# Default command
CMD ["/bin/bash"]
