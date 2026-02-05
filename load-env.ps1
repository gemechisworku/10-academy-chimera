# PowerShell script to load .env file and set environment variables
# Usage: .\load-env.ps1

if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
            Write-Host "Loaded: $name"
        }
    }
    Write-Host "Environment variables loaded from .env"
} else {
    Write-Warning ".env file not found"
}

