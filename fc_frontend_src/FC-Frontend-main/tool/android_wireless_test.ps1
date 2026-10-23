# Wireless debug install-over (no USB cable after pairing).
# Phone and laptop must be on the same Wi‑Fi.
#
# On phone (Nothing / Android 11+):
#   Settings → System → Developer options → Wireless debugging → ON
#   Tap "Pair device with pairing code"
#   Note: pairing IP:port + 6-digit code, and the "IP address & port" for connect
#
# Then run:
#   powershell -File tool\android_wireless_test.ps1 -PairHost 192.168.x.x -PairPort 37xxx -PairCode 123456 -ConnectHost 192.168.x.x -ConnectPort 41xxx
#
# Next times (already paired): only -ConnectHost and -ConnectPort.

param(
  [string]$PairHost = "",
  [int]$PairPort = 0,
  [string]$PairCode = "",
  [Parameter(Mandatory = $true)][string]$ConnectHost,
  [Parameter(Mandatory = $true)][int]$ConnectPort
)

$ErrorActionPreference = "Stop"
$adb = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"
$appRoot = Split-Path $PSScriptRoot -Parent
Set-Location $appRoot

if (-not (Test-Path $adb)) {
  Write-Error "adb not found at $adb"
}

if ($PairHost -and $PairPort -gt 0 -and $PairCode) {
  Write-Host "Pairing $($PairHost):$PairPort ..."
  & $adb pair "$($PairHost):$PairPort" $PairCode
}

Write-Host "Connecting $($ConnectHost):$ConnectPort ..."
& $adb connect "$($ConnectHost):$ConnectPort"
& $adb devices -l

$devices = & $adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "device$" }
if (-not $devices) {
  Write-Error "Phone not connected. Check Wireless debugging is ON and both devices share Wi‑Fi."
}

Write-Host "Starting Flutter debug (install-over + hot reload)..."
Write-Host "r = hot reload, R = hot restart, q = quit"
flutter run --debug
