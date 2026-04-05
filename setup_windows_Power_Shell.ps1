<#
setup.ps1 — REDVIM configuration installer for Windows
Usage: powershell -ExecutionPolicy Bypass -File .\setup.ps1
#>

param(
    [string]$Repo = "https://github.com/riccce-4s/redvim.git",
    [string]$Branch = "main"
)

# UI Helper functions
function Write-Ok($m) { Write-Host ">>> $m" -ForegroundColor Green }
function Write-Err($m) { Write-Host ">>> $m" -ForegroundColor Red }
function Write-Info($m) { Write-Host ">>> $m" -ForegroundColor Cyan }

Write-Ok "Starting REDVIM installer (Windows PowerShell)..."

# 1. Check for Administrator privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Info "Note: Running without Admin rights. Some installations may prompt for elevation."
}

# 2. Dependency Check & Installation Function
function Install-Dependency($cmd, $id, $name) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Info "$name not found. Attempting to install via winget..."
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget install --id $id -e --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -ne 0) {
                Write-Err "Failed to install $name via winget."
                exit 1
            }
            # Refresh Path after each install to ensure the tool is available
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        } else {
            Write-Err "winget not found. Please install $name manually."
            exit 1
        }
    } else {
        Write-Ok "$name is already installed."
    }
}

# Install core tools
Install-Dependency "git" "Git.Git" "Git"
Install-Dependency "nvim" "Neovim.Neovim" "Neovim"
Install-Dependency "node" "OpenJS.NodeJS" "Node.js"
Install-Dependency "rg" "BurntSushi.ripgrep" "Ripgrep"

# 3. Install JetBrains Mono Nerd Font
Write-Info "Installing JetBrains Mono Nerd Font..."
if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install --id "DEVCOM.JetBrainsMonoNerdFont" -e --accept-package-agreements --accept-source-agreements
}

# 4. Resolve configuration path
$config = $env:XDG_CONFIG_HOME
if (-not $config -or $config -eq "") {
    $config = Join-Path $env:LOCALAPPDATA "nvim"
}

# 5. Backup existing configuration
if (Test-Path $config) {
    $ts = Get-Date -Format "yyyyMMddHHmmss"
    $backup = "${config}.backup.${ts}"
    Write-Ok "Backing up existing config to: $backup"
    try {
        Rename-Item -Path $config -NewName $backup -ErrorAction Stop
    } catch {
        Write-Err "Could not rename existing folder. Please close Neovim and try again."
        exit 1
    }
}

# 6. Clone repository to a temporary location
$tmpPath = Join-Path $env:TEMP ("redvim_" + [guid]::NewGuid().ToString())
Write-Ok "Cloning repository $Repo (branch: $Branch)..."

try {
    git clone --depth 1 --branch $Branch $Repo $tmpPath
    if ($LASTEXITCODE -ne 0) { throw "Git clone failed" }
} catch {
    Write-Err "Error during cloning. Check your connection or the URL: $Repo"
    exit 1
}

# 7. Deploy files to the config directory
Write-Ok "Installing configuration files to $config..."
$parent = Split-Path $config -Parent
if (-not (Test-Path $parent)) { 
    New-Item -ItemType Directory -Path $parent -Force | Out-Null 
}

try {
    Move-Item -Path $tmpPath -Destination $config -Force
} catch {
    Write-Err "Failed to move files. The directory might be in use."
    exit 1
}

# 8. Post-install: Plugin sync via lazy.nvim
Write-Ok "Syncing plugins via lazy.nvim..."
$nvimCmd = @(
    "--headless",
    "-u", (Join-Path $config "init.lua"),
    "-c", "lazy sync",
    "-c", "qa"
)

try {
    & nvim @nvimCmd
    Write-Ok "Plugins synchronized successfully."
} catch {
    Write-Info "Headless sync finished. Open nvim to complete any remaining setup."
}

Write-Ok "REDVIM installation completed successfully!"
Write-Info "1. Set terminal font to 'JetBrainsMono NF'."
Write-Info "2. Run 'nvim' to start."
