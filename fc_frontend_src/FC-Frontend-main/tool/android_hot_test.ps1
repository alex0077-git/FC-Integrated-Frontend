# Iterative Android test — replaces the app without uninstalling.
# 1) Phone: Developer options → USB debugging ON
# 2) Plug USB (or: adb tcpip 5555 after one USB pair)
# 3) From this folder's parent:  powershell -File tool\android_hot_test.ps1
#
# Uses debug builds only so signatures stay the same. Release APK later.

$ErrorActionPreference = "Stop"
$adb = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"
$appRoot = Split-Path $PSScriptRoot -Parent
Set-Location $appRoot

if (-not (Test-Path $adb)) {
  Write-Error "adb not found at $adb"
}

$devices = & $adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "device$" }
if (-not $devices) {
  Write-Host "No phone seen by adb."
  Write-Host "Enable USB debugging, plug the cable, tap Allow on the phone, then run this again."
  & $adb devices -l
  exit 1
}

Write-Host "Phone connected. Starting Flutter debug (install-over + hot reload)..."
Write-Host "After first launch: press r = hot reload, R = hot restart, q = quit."
flutter run --debug
