#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Capture official K++ assistant <-> FC GPS traffic via USBPcap (no com0com).

.DESCRIPTION
  1. Leave the K++ USB-SERIAL on COM3.
  2. Run this script as Administrator.
  3. When prompted, open the official K++ assistant and connect to COM3.
  4. Wait outdoors until GPS looks good, then press Enter here to stop.
  5. Script converts the pcap to jsonl and prints the analyzer summary.
#>
$ErrorActionPreference = "Stop"
$Tools = Split-Path -Parent $MyInvocation.MyCommand.Path
$Captures = Join-Path $Tools "captures"
New-Item -ItemType Directory -Force -Path $Captures | Out-Null

$UsbPcapCmd = "C:\Program Files\USBPcap\USBPcapCMD.exe"
$Tshark = "C:\Program Files\Wireshark\tshark.exe"
if (-not (Test-Path $UsbPcapCmd)) {
  throw "USBPcap not found at $UsbPcapCmd — reinstall desowin.USBPcap"
}

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$pcap = Join-Path $Captures "kpp_usb_$stamp.pcap"
$jsonl = Join-Path $Captures "kpp_usb_$stamp.jsonl"

Write-Host ""
Write-Host "K++ GPS capture (USBPcap)"
Write-Host "========================="
Write-Host "1) Keep USB-SERIAL CH340 on COM3 plugged in."
Write-Host "2) This window will start capturing USB traffic."
Write-Host "3) Open the official K++ assistant and connect to COM3."
Write-Host "4) Wait until GPS looks good outdoors."
Write-Host "5) Come back here and press Enter to stop."
Write-Host ""
Write-Host "PCAP -> $pcap"
Write-Host ""

# Prefer USBPcap1; fall back through USBPcap2..8
$filter = $null
foreach ($n in 1..8) {
  $candidate = "\\.\USBPcap$n"
  # Probe by starting a 0-second style open is hard; just try first available via tshark if present.
  $filter = $candidate
  break
}

# List filters with tshark if available
if (Test-Path $Tshark) {
  Write-Host "Available capture interfaces (tshark):"
  & $Tshark -D 2>&1 | Select-String -Pattern "USBPcap|usb" | ForEach-Object { Write-Host "  $_" }
}

Write-Host "Starting USBPcap on $filter (all devices on hub)..."
$proc = Start-Process -FilePath $UsbPcapCmd -ArgumentList @(
  "-d", $filter,
  "-o", $pcap,
  "-A",
  "--inject-descriptors"
) -PassThru -WindowStyle Minimized

Start-Sleep -Seconds 2
if ($proc.HasExited) {
  Write-Host ""
  Write-Host "USBPcap exited immediately (exit $($proc.ExitCode))."
  Write-Host "A reboot is often required after installing USBPcap."
  Write-Host "Reboot, then re-run this script as Administrator."
  exit 1
}

Write-Host "Capturing... connect the K++ assistant to COM3 now."
Read-Host "Press Enter to STOP capture"

Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

if (-not (Test-Path $pcap) -or (Get-Item $pcap).Length -lt 100) {
  throw "Capture file missing or empty: $pcap"
}

Write-Host "Converting pcap -> jsonl..."
Set-Location $Tools
python .\usbpcap_to_kpp_jsonl.py $pcap --out $jsonl
python .\analyze_kpp_capture.py $jsonl

Write-Host ""
Write-Host "Done. Share this file with the agent:"
Write-Host "  $jsonl"
