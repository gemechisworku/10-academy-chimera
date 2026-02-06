# Fix Chocolatey Lock File Issue
# Run this script as Administrator if the lock file persists

$lockFile = "C:\ProgramData\chocolatey\lib\995c915eb7cf3c8b25f2235e513ef8ca0c75c3e7"

Write-Host "Attempting to fix Chocolatey lock file issue..." -ForegroundColor Yellow

# Check if lock file exists
if (Test-Path $lockFile) {
    Write-Host "Found lock file: $lockFile" -ForegroundColor Yellow
    
    # Try to remove it
    try {
        Remove-Item -Path $lockFile -Force -ErrorAction Stop
        Write-Host "Lock file removed successfully!" -ForegroundColor Green
        Write-Host "You can now try: choco install make" -ForegroundColor Cyan
    } catch {
        Write-Host "Error: Could not remove lock file. You may need to:" -ForegroundColor Red
        Write-Host "1. Run PowerShell as Administrator" -ForegroundColor Yellow
        Write-Host "2. Close any other Chocolatey processes" -ForegroundColor Yellow
        Write-Host "3. Or use the PowerShell script instead: .\make.ps1" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "Lock file not found. The issue may be resolved." -ForegroundColor Green
    Write-Host "Try running: choco install make" -ForegroundColor Cyan
}

