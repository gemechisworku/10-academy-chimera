# Spec Check Script for Project Chimera (PowerShell)
# Verifies that code implementation aligns with specifications

$ErrorActionPreference = "Stop"

# Counters
$script:Passed = 0
$script:Failed = 0
$script:Warnings = 0

# Function to print results
function Print-Result {
    param(
        [bool]$Success,
        [string]$Message
    )
    
    if ($Success) {
        Write-Host "✓ $Message" -ForegroundColor Green
        $script:Passed++
    } else {
        Write-Host "✗ $Message" -ForegroundColor Red
        $script:Failed++
    }
}

function Print-Warning {
    param([string]$Message)
    
    Write-Host "⚠ $Message" -ForegroundColor Yellow
    $script:Warnings++
}

Write-Host "=========================================="
Write-Host "Project Chimera - Spec Check"
Write-Host "=========================================="
Write-Host ""

# Check if specs directory exists
if (-not (Test-Path "specs")) {
    Write-Host "ERROR: specs/ directory not found!" -ForegroundColor Red
    exit 1
}

# Check if technical.md exists
if (-not (Test-Path "specs/technical.md")) {
    Write-Host "ERROR: specs/technical.md not found!" -ForegroundColor Red
    exit 1
}

# Check if functional.md exists
if (-not (Test-Path "specs/functional.md")) {
    Write-Host "ERROR: specs/functional.md not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Checking specification files..."
Print-Result $true "Specs directory exists"
Print-Result $true "technical.md found"
Print-Result $true "functional.md found"
Write-Host ""

# Check for required API endpoints in technical.md
Write-Host "Checking API contract specifications..."

$technicalContent = Get-Content "specs/technical.md" -Raw

if ($technicalContent -match "2\.2\.3 Detect Trends") {
    Print-Result $true "Detect Trends API contract defined"
} else {
    Print-Result $false "Detect Trends API contract missing"
}

if ($technicalContent -match "2\.2 Worker API") {
    Print-Result $true "Worker API section found"
} else {
    Print-Result $false "Worker API section missing"
}

if ($technicalContent -match "2\.1 Planner API") {
    Print-Result $true "Planner API section found"
} else {
    Print-Result $false "Planner API section missing"
}

if ($technicalContent -match "2\.3 Judge API") {
    Print-Result $true "Judge API section found"
} else {
    Print-Result $false "Judge API section missing"
}

Write-Host ""

# Check for skills interface definitions
Write-Host "Checking skills interface specifications..."

if (Test-Path "skills/README.md") {
    Print-Result $true "Skills README.md found"
    
    $skillsContent = Get-Content "skills/README.md" -Raw
    
    if ($skillsContent -match "skill_transcribe_audio") {
        Print-Result $true "skill_transcribe_audio defined"
    } else {
        Print-Warning "skill_transcribe_audio not found in skills/README.md"
    }
    
    if ($skillsContent -match "skill_download_youtube") {
        Print-Result $true "skill_download_youtube defined"
    } else {
        Print-Warning "skill_download_youtube not found in skills/README.md"
    }
    
    if ($skillsContent -match "skill_generate_content") {
        Print-Result $true "skill_generate_content defined"
    } else {
        Print-Warning "skill_generate_content not found in skills/README.md"
    }
} else {
    Print-Result $false "skills/README.md not found"
}

Write-Host ""

# Check for test files that validate specs
Write-Host "Checking test coverage for specifications..."

if (Test-Path "tests/test_trend_fetcher.py") {
    Print-Result $true "test_trend_fetcher.py exists (validates trend API contract)"
} else {
    Print-Result $false "test_trend_fetcher.py missing"
}

if (Test-Path "tests/test_skills_interface.py") {
    Print-Result $true "test_skills_interface.py exists (validates skills contracts)"
} else {
    Print-Result $false "test_skills_interface.py missing"
}

Write-Host ""

# Check for implementation files (these should exist or be planned)
Write-Host "Checking implementation status..."

# Check for worker module
if (Test-Path "worker") {
    Print-Result $true "worker module exists"
    
    if (Test-Path "worker/trend_fetcher.py") {
        Print-Result $true "worker/trend_fetcher.py implemented"
    } else {
        Print-Warning "worker/trend_fetcher.py not yet implemented (expected in TDD)"
    }
} else {
    Print-Warning "worker module not yet created (expected in TDD)"
}

# Check for skills modules
if (Test-Path "skills") {
    $skillFiles = Get-ChildItem -Path "skills" -Filter "*.py" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch "__pycache__" }
    $skillCount = ($skillFiles | Measure-Object).Count
    
    if ($skillCount -gt 0) {
        Print-Result $true "Skills modules found: $skillCount"
    } else {
        Print-Warning "No skill implementation files found yet (expected in TDD)"
    }
} else {
    Print-Warning "skills directory structure incomplete"
}

Write-Host ""

# Check for required dependencies in pyproject.toml
Write-Host "Checking project configuration..."

if (Test-Path "pyproject.toml") {
    Print-Result $true "pyproject.toml exists"
    
    $pyprojectContent = Get-Content "pyproject.toml" -Raw
    if ($pyprojectContent -match "requires-python") {
        $pythonVersion = [regex]::Match($pyprojectContent, "requires-python\s*=\s*[`">=]*([0-9.]+)").Groups[1].Value
        Print-Result $true "Python version requirement specified: >=$pythonVersion"
    } else {
        Print-Result $false "Python version requirement missing"
    }
} else {
    Print-Result $false "pyproject.toml missing"
}

Write-Host ""

# Summary
Write-Host "=========================================="
Write-Host "Spec Check Summary"
Write-Host "=========================================="
Write-Host "Passed: $script:Passed" -ForegroundColor Green
Write-Host "Failed: $script:Failed" -ForegroundColor Red
Write-Host "Warnings: $script:Warnings" -ForegroundColor Yellow
Write-Host ""

if ($script:Failed -eq 0) {
    Write-Host "✓ All critical checks passed!" -ForegroundColor Green
    if ($script:Warnings -gt 0) {
        Write-Host "⚠ Some warnings found (may be expected in TDD phase)" -ForegroundColor Yellow
    }
    exit 0
} else {
    Write-Host "✗ Some checks failed. Please review the output above." -ForegroundColor Red
    exit 1
}

