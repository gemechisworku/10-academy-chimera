# Project Chimera - PowerShell Makefile Alternative
# Provides the same commands as Makefile for Windows users

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

function Show-Help {
    Write-Host "Project Chimera - Available Commands:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  .\make.ps1 setup       - Install dependencies using uv" -ForegroundColor Yellow
    Write-Host "  .\make.ps1 test        - Run tests in Docker container" -ForegroundColor Yellow
    Write-Host "  .\make.ps1 spec-check  - Verify code alignment with specifications" -ForegroundColor Yellow
    Write-Host "  .\make.ps1 docker-build - Build Docker image" -ForegroundColor Yellow
    Write-Host "  .\make.ps1 docker-test - Run tests in Docker container" -ForegroundColor Yellow
    Write-Host "  .\make.ps1 clean       - Clean build artifacts and caches" -ForegroundColor Yellow
    Write-Host ""
}

function Invoke-Setup {
    Write-Host "Installing dependencies with uv..." -ForegroundColor Green
    # Install with dev dependencies (includes pytest, pydantic, etc.)
    uv pip install -e ".[dev]"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to install dependencies" -ForegroundColor Red
        exit 1
    }
    Write-Host "Dependencies installed successfully!" -ForegroundColor Green
}

function Invoke-DockerBuild {
    Write-Host "Building Docker image..." -ForegroundColor Green
    
    # Ensure placeholder files exist
    if (-not (Test-Path "chimera\__init__.py")) {
        New-Item -ItemType File -Path "chimera\__init__.py" -Force | Out-Null
    }
    if (-not (Test-Path "main.py")) {
        New-Item -ItemType File -Path "main.py" -Force | Out-Null
    }
    
    docker build -t chimera-dev:latest .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Docker build failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "Docker image built successfully!" -ForegroundColor Green
}

function Invoke-DockerTest {
    Write-Host "Running tests in Docker container..." -ForegroundColor Green
    
    # Build if not already built
    $imageExists = docker images chimera-dev:latest -q
    if (-not $imageExists) {
        Write-Host "Docker image not found. Building..." -ForegroundColor Yellow
        Invoke-DockerBuild
    }
    
    $pwd = (Get-Location).Path
    docker run --rm `
        -v "${pwd}:/app" `
        -w /app `
        chimera-dev:latest `
        pytest tests/ -v
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Tests completed with failures (expected in TDD)" -ForegroundColor Yellow
    } else {
        Write-Host "All tests passed!" -ForegroundColor Green
    }
}

function Invoke-SpecCheck {
    Write-Host "Running spec-check to verify code alignment with specifications..." -ForegroundColor Green
    
    if (Test-Path "scripts\spec-check.ps1") {
        & powershell -ExecutionPolicy Bypass -File scripts\spec-check.ps1
    } elseif (Test-Path "scripts/spec-check.sh") {
        Write-Host "Using bash script (requires Git Bash or WSL)" -ForegroundColor Yellow
        bash scripts/spec-check.sh
    } else {
        Write-Host "Error: spec-check script not found!" -ForegroundColor Red
        exit 1
    }
}

function Invoke-Clean {
    Write-Host "Cleaning build artifacts..." -ForegroundColor Green
    
    # Remove __pycache__ directories
    Get-ChildItem -Path . -Filter "__pycache__" -Recurse -Directory -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    
    # Remove .pyc files
    Get-ChildItem -Path . -Filter "*.pyc" -Recurse -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    
    # Remove .egg-info directories
    Get-ChildItem -Path . -Filter "*.egg-info" -Recurse -Directory -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    
    # Remove pytest cache
    if (Test-Path ".pytest_cache") {
        Remove-Item -Path ".pytest_cache" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Remove coverage files
    if (Test-Path ".coverage") {
        Remove-Item -Path ".coverage" -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "htmlcov") {
        Remove-Item -Path "htmlcov" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "Clean completed!" -ForegroundColor Green
}

# Main command router
switch ($Command.ToLower()) {
    "help" { Show-Help }
    "setup" { Invoke-Setup }
    "docker-build" { Invoke-DockerBuild }
    "docker-test" { Invoke-DockerTest }
    "test" { Invoke-DockerTest }
    "spec-check" { Invoke-SpecCheck }
    "clean" { Invoke-Clean }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Write-Host ""
        Show-Help
        exit 1
    }
}

