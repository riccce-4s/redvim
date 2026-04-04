<#
setup.ps1 — Installer for REDVIM configuration on Windows (PowerShell)
Run: Run PowerShell (may require Administrator for package installs)
Example: powershell -ExecutionPolicy Bypass -File .\setup.ps1

This script:
 - prefers XDG_CONFIG_HOME for config path, falls back to %LOCALAPPDATA%\nvim
 - checks for git and neovim and attempts installation via winget (best-effort)
 - backs up existing config if present
 - clones the REDVIM repository to the target config path
 - runs Neovim headless to trigger lazy.nvim plugin sync (best-effort)
#>

param(
    [string]$Repo = "https://github.com/riccce-4s/redvim.git",
    [string]$Branch = "main"
)

function Write-Ok($m) { Write-Host ">>> $m" -ForegroundColor Green }
function Write-Err($m) { Write-Host ">>> $m" -ForegroundColor Red }

Write-Ok "REDVIM installer (Windows PowerShell)"

# Resolve config path: prefer XDG_CONFIG_HOME, otherwise use %LOCALAPPDATA%\nvim
$config = $env:XDG_CONFIG_HOME
if (-not $config -or $config -eq "") {
    $config = Join-Path $env:LOCALAPPDATA "nvim"
}
Write-Ok "Target Neovim config: $config"

# Check git and nvim presence
$git = Get-Command git -ErrorAction SilentlyContinue
$nvim = Get-Command nvim -ErrorAction SilentlyContinue

if (-not $git) {
    Write-Host "git not found. Attempting to install via winget..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
    } else {
        Write-Err "winget not available. Please install git manually and re-run."
        exit 1
    }
}

if (-not $nvim) {
    Write-Host "Neovim not found. Attempting to install via winget..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Neovim.Neovim -e --accept-package-agreements --accept-source-agreements
    } else {
        Write-Err "winget not available. Please install Neovim manually and re-run."
        exit 1
    }
}

# If config exists, backup
if (Test-Path $config) {
    $ts = Get-Date -Format "yyyyMMddHHmmss"
    $backup = "${config}.backup.${ts}"
    Write-Ok "Backing up existing config to $backup"
    Rename-Item -Path $config -NewName $backup -ErrorAction Stop
}

# Clone repo
$tmpPath = Join-Path $env:TEMP ("redvim_" + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tmpPath -Force | Out-Null
Write-Ok "Cloning $Repo (branch $Branch) to $tmpPath"
git clone --depth 1 --branch $Branch $Repo $tmpPath

# Move to config location
$parent = Split-Path $config -Parent
if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
Move-Item -Path $tmpPath -Destination $config -Force

Write-Ok "Configuration placed in $config"

# Run headless Neovim to trigger lazy sync
Write-Ok "Running nvim headless to install plugins..."
# Use -u to load the new init.lua then call require('lazy').sync() (best-effort)
$nvimCmd = @(
    "--headless",
    "-u", (Join-Path $config "init.lua"),
    "-c", "lua if pcall(function() require('lazy').sync() end) then vim.cmd('qa') else vim.cmd('qa') end"
)
& nvim @nvimCmd

Write-Ok "REDVIM installation finished. Open nvim to verify."
