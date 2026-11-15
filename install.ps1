# Install fishfetch on Windows for the current user.
#   .\install.ps1              -> ~\.local\bin\fishfetch.cmd (+ fishfetch.py), ~\.local\share\fishfetch\frames
#   .\install.ps1 -Uninstall
param([switch]$Uninstall)
$ErrorActionPreference = 'Stop'
$bin = Join-Path $HOME '.local\bin'
$share = Join-Path $HOME '.local\share\fishfetch'

if ($Uninstall) {
    Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $bin 'fishfetch.py'), (Join-Path $bin 'fishfetch.cmd')
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $share
    Write-Host "removed fishfetch from $bin"
    exit 0
}

if (-not (Get-Command fastfetch -ErrorAction SilentlyContinue)) {
    Write-Warning 'fastfetch is not installed; fishfetch needs it (winget install Fastfetch-cli.Fastfetch)'
}
New-Item -ItemType Directory -Force $bin, (Join-Path $share 'frames') | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'fishfetch') (Join-Path $bin 'fishfetch.py') -Force
Copy-Item (Join-Path $PSScriptRoot 'frames\frame-*.txt') (Join-Path $share 'frames') -Force
Set-Content -Encoding ascii (Join-Path $bin 'fishfetch.cmd') "@echo off`r`npython `"%~dp0fishfetch.py`" %*"
Write-Host "installed: $bin\fishfetch.cmd"

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $bin) {
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$bin", 'User')
    Write-Host "added $bin to your PATH (open a new terminal)"
}
