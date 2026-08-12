Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " Antigravity IDE Multi-Task Setup for WSL2 Ecosystem" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

$wslConfigTarget = "$env:USERPROFILE\.wslconfig"
$wslConfigSource = ".\.wslconfig"

if (Test-Path $wslConfigSource) {
    Copy-Item -Path $wslConfigSource -Destination $wslConfigTarget -Force
    Write-Host "[OK] Updated $wslConfigTarget" -ForegroundColor Green
} else {
    Write-Host "[WARN] $wslConfigSource not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[+] Checking WSL status..." -ForegroundColor Yellow
wsl -l -v

Write-Host ""
Write-Host "[+] Active Antigravity and WSL Processes on Windows Host:" -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -match "antigravity|gemini|wsl"} | Select-Object Id, ProcessName, CPU, WorkingSet

Write-Host ""
Write-Host "[+] Active Processes inside WSL Linux Guest:" -ForegroundColor Yellow
wsl ps aux | Select-Object -First 15

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " Setup Completed. Restart WSL using wsl --shutdown " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
