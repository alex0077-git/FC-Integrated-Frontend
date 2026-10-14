#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Helps install signed com0com (SourceForge blocks automated download here).

.DESCRIPTION
  1. Opens the official signed com0com 2.2.2.0 download page.
  2. Waits until the zip appears in your Downloads folder.
  3. Extracts and runs the x64 setup.
  4. Creates a COM10 <-> COM11 pair for the GPS bridge.
#>
$ErrorActionPreference = "Stop"
$Vendor = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "vendor"
New-Item -ItemType Directory -Force -Path $Vendor | Out-Null

$url = "https://sourceforge.net/projects/com0com/files/com0com/2.2.2.0/com0com-2.2.2.0-x64-fre-signed.zip/download"
Write-Host "Opening download page..."
Start-Process $url

$downloads = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
Write-Host "Waiting for com0com-2.2.2.0-x64-fre-signed.zip in:"
Write-Host "  $downloads"
Write-Host "Save the file there (or copy it), then this script continues automatically."

$zip = $null
for ($i = 0; $i -lt 600; $i++) {
  $hit = Get-ChildItem -Path $downloads, $Vendor -Filter "com0com*signed*.zip" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
  if ($hit -and $hit.Length -gt 50000) {
    $zip = $hit.FullName
    break
  }
  Start-Sleep -Seconds 2
}
if (-not $zip) {
  throw "Timed out waiting for com0com zip. Download it manually into Downloads and re-run."
}

Write-Host "Found $zip"
$extract = Join-Path $Vendor "com0com_extract"
if (Test-Path $extract) { Remove-Item $extract -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $extract -Force

$setup = Get-ChildItem -Path $extract -Recurse -Filter "*setup*.exe" | Select-Object -First 1
if (-not $setup) {
  $setup = Get-ChildItem -Path $extract -Recurse -Filter "*.exe" | Select-Object -First 1
}
if (-not $setup) { throw "No setup.exe inside zip" }

Write-Host "Running $($setup.FullName) ..."
Start-Process -FilePath $setup.FullName -Wait

$setupc = @(
  "${env:ProgramFiles}\com0com\setupc.exe",
  "${env:ProgramFiles(x86)}\com0com\setupc.exe",
  "C:\Program Files\com0com\setupc.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($setupc) {
  Write-Host "Creating CNCA0/CNCB0 pair mapped toward COM10/COM11 if possible..."
  & $setupc install PortName=COM10 PortName=COM11 2>&1
  & $setupc list 2>&1
} else {
  Write-Host "Open Setup Command Prompt for com0com and run:"
  Write-Host '  setupc install PortName=COM10 PortName=COM11'
}

Write-Host ""
Write-Host "Next:"
Write-Host "  python kpp_com_bridge.py --fc COM3 --app COM11 --baud 115200"
Write-Host "  Then connect K++ assistant to COM10."
