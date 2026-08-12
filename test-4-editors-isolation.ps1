# Skenario Testing Multi-Editor Isolation di WSL2
# Buka 4 Editor di 4 Direktori WSL Berbeda -> Tutup Editor Pertama -> Pastikan 3 Lainnya Tidak Reconnect

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Testing Multi-Editor Isolation in WSL2 Environment" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$bytes = [System.IO.File]::ReadAllBytes("$PSScriptRoot\run_scenario_4editors.sh")
# Strip UTF-8 BOM if present
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $bytes = $bytes[3..($bytes.Length - 1)]
}
$text = [System.Text.Encoding]::UTF8.GetString($bytes) -replace "`r`n", "`n"

$text | wsl bash
