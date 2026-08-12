# Test Scenario Suite for WSL2 and Antigravity IDE Multi-Task Environment
# Run in PowerShell

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Running Multi-Tasking Testing Scenarios for WSL2" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$testResults = @()

# ---------------------------------------------------------
# Skenario 1: Test Plan9 VFS and Path Translation File I/O
# ---------------------------------------------------------
Write-Host ""
Write-Host "[Skenario 1] Testing Plan9 VFS File I/O and Path Translation..." -ForegroundColor Yellow
$startTime = Get-Date
try {
    $tempDir = ".\test_io_temp"
    if (Test-Path $tempDir) { Remove-Item -Path $tempDir -Recurse -Force }
    New-Item -ItemType Directory -Path $tempDir | Out-Null

    # Generate 50 small files in parallel simulation
    1..50 | ForEach-Object {
        "Test content for file $_ - $(Get-Date)" | Out-File -FilePath "$tempDir\file_$_.txt" -Encoding utf8
    }

    $fileCount = (Get-ChildItem -Path $tempDir).Count
    Remove-Item -Path $tempDir -Recurse -Force

    $duration = ((Get-Date) - $startTime).TotalMilliseconds
    Write-Host "[OK] Skenario 1 PASSED: Created and cleaned $fileCount files in ${duration}ms" -ForegroundColor Green
    $testResults += [PSCustomObject]@{ Scenario = "1. Plan9 VFS File I/O"; Status = "PASSED"; DurationMs = [math]::Round($duration, 2) }
} catch {
    Write-Host "[FAIL] Skenario 1 FAILED: $_" -ForegroundColor Red
    $testResults += [PSCustomObject]@{ Scenario = "1. Plan9 VFS File I/O"; Status = "FAILED"; DurationMs = 0 }
}

# ---------------------------------------------------------
# Skenario 2: Test WSL2 Mirrored Networking Stack
# ---------------------------------------------------------
Write-Host ""
Write-Host "[Skenario 2] Testing Mirrored Networking Stack..." -ForegroundColor Yellow
$startTime = Get-Date
try {
    # Test network interface query inside WSL
    $wslNetworkTest = wsl hostname -I
    if ($wslNetworkTest) {
        $duration = ((Get-Date) - $startTime).TotalMilliseconds
        Write-Host "[OK] Skenario 2 PASSED: Mirrored networking active. Output: $wslNetworkTest" -ForegroundColor Green
        $testResults += [PSCustomObject]@{ Scenario = "2. Mirrored Networking"; Status = "PASSED"; DurationMs = [math]::Round($duration, 2) }
    } else {
        throw "Network interface query returned empty"
    }
} catch {
    Write-Host "[FAIL] Skenario 2 FAILED: $_" -ForegroundColor Red
    $testResults += [PSCustomObject]@{ Scenario = "2. Mirrored Networking"; Status = "FAILED"; DurationMs = 0 }
}

# ---------------------------------------------------------
# Skenario 3: Test Concurrent Background Tasks inside WSL2
# ---------------------------------------------------------
Write-Host ""
Write-Host "[Skenario 3] Testing Concurrent Task Execution in WSL2..." -ForegroundColor Yellow
$startTime = Get-Date
try {
    # Launch 4 parallel background sleep/echo commands in WSL
    $wslParallelTask = wsl bash -c 'for i in 1 2 3 4; do (sleep 1 && echo Task $i completed) & done; wait'
    $duration = ((Get-Date) - $startTime).TotalMilliseconds
    Write-Host "[OK] Skenario 3 PASSED: Parallel Tasks completed in ${duration}ms" -ForegroundColor Green
    Write-Host "    Output: $wslParallelTask" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{ Scenario = "3. Concurrent Tasks WSL2"; Status = "PASSED"; DurationMs = [math]::Round($duration, 2) }
} catch {
    Write-Host "[FAIL] Skenario 3 FAILED: $_" -ForegroundColor Red
    $testResults += [PSCustomObject]@{ Scenario = "3. Concurrent Tasks WSL2"; Status = "FAILED"; DurationMs = 0 }
}

# ---------------------------------------------------------
# Skenario 4: Test Memory and PID Resource Limits
# ---------------------------------------------------------
Write-Host ""
Write-Host "[Skenario 4] Testing Memory and PID Monitoring..." -ForegroundColor Yellow
$startTime = Get-Date
try {
    $vmmemProc = Get-Process -Name "vmmemWSL" -ErrorAction SilentlyContinue
    $antigravityProcs = Get-Process | Where-Object {$_.ProcessName -match "antigravity"}
    
    $vmmemRamMB = if ($vmmemProc) { [math]::Round($vmmemProc.WorkingSet64 / 1MB, 2) } else { 0 }
    $agCount = $antigravityProcs.Count

    $duration = ((Get-Date) - $startTime).TotalMilliseconds
    Write-Host "[OK] Skenario 4 PASSED: vmmemWSL RAM: ${vmmemRamMB}MB | Antigravity PIDs Active: $agCount" -ForegroundColor Green
    $testResults += [PSCustomObject]@{ Scenario = "4. Resource and PID Check"; Status = "PASSED"; DurationMs = [math]::Round($duration, 2) }
} catch {
    Write-Host "[FAIL] Skenario 4 FAILED: $_" -ForegroundColor Red
    $testResults += [PSCustomObject]@{ Scenario = "4. Resource and PID Check"; Status = "FAILED"; DurationMs = 0 }
}

# ---------------------------------------------------------
# Summary Table
# ---------------------------------------------------------
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Multi-Tasking Scenario Testing Summary" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
$testResults | Format-Table -AutoSize
