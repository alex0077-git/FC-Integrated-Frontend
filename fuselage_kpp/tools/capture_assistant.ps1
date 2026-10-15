#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Capture K++ Assistant <-> FC USB traffic for GPS parity with Fuselage.

.DESCRIPTION
  1. Ensures a com0com virtual pair COM10 <-> COM11 exists (repairs if needed).
  2. Starts kpp_com_bridge.py: real FC on COM3 (or -FcPort), assistant on COM10.
  3. You connect the official K++ assistant to COM10, open Status/GPS, wait ~30s.
  4. Ctrl+C stops the bridge. Then analyze the jsonl.

.EXAMPLE
  .\capture_assistant.ps1
  .\capture_assistant.ps1 -FcPort COM3 -Baud 115200
#>
param(
  [string]$FcPort = "COM3",
  [string]$AppBridgePort = "COM11",
  [string]$AssistantPort = "COM10",
  [int]$Baud = 115200
)

$ErrorActionPreference = "Stop"
$Tools = Split-Path -Parent $MyInvocation.MyCommand.Path
$Setupc = @(
  "${env:ProgramFiles(x86)}\com0com\setupc.exe",
  "${env:ProgramFiles}\com0com\setupc.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $Setupc) {
  Write-Host "com0com not found. Run install_com0com.ps1 first, then re-run this script."
  exit 1
}

Write-Host "com0com: $Setupc"
$list = & $Setupc list 2>&1 | Out-String
Write-Host $list

if ($list -notmatch $AssistantPort -or $list -notmatch $AppBridgePort) {
  Write-Host "Installing virtual pair $AssistantPort <-> $AppBridgePort ..."
  & $Setupc install "PortName=$AssistantPort" "PortName=$AppBridgePort" 2>&1
  & $Setupc list 2>&1
}

# Soft-disable broken CNC devices then rescan
Get-PnpDevice | Where-Object { $_.FriendlyName -match 'com0com' -and $_.Status -ne 'OK' } | ForEach-Object {
  Write-Host "Enabling $($_.FriendlyName) ..."
  Enable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
}

$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) { throw "python not on PATH (need pyserial)" }

$out = Join-Path $Tools "captures" ("kpp_assistant_{0:yyyyMMdd_HHmmss}.jsonl" -f (Get-Date))
Write-Host ""
Write-Host "=== CAPTURE STEPS ==="
Write-Host "1. Close Fuselage / any app using $FcPort"
Write-Host "2. Bridge will open FC=$FcPort and bridge=$AppBridgePort"
Write-Host "3. In K++ assistant, connect to serial port $AssistantPort @ $Baud"
Write-Host "4. Open the Status / GPS screen (wired GPS as you normally use it)"
Write-Host "5. Leave it for 30–60 seconds (outdoors if you want a lock)"
Write-Host "6. Press Ctrl+C here to stop"
Write-Host "Log -> $out"
Write-Host ""

python (Join-Path $Tools "kpp_com_bridge.py") --fc $FcPort --app $AppBridgePort --baud $Baud --out $out
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Analyzing..."
python (Join-Path $Tools "analyze_kpp_capture.py") $out
Write-Host ""
Write-Host "Share the summary above (or the file) so Fuselage can mirror the assistant GPS path."
