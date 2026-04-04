#!/usr/bin/env bash
# setup.sh — Installer for REDVIM configuration on Linux / macOS
# Usage: bash setup.sh
# This script:
#  - checks for git and neovim and attempts a best-effort install via common package managers
#  - backs up any existing Neovim config
#  - clones the REDVIM repository into the Neovim config directory
#  - runs Neovim headless to trigger plugin installation via lazy.nvim
set -euo pipefail

REPO="https://github.com/riccce-4s/redvim.git"
BRANCH="main"

# Determine XDG config dir default
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_CONFIG_DIR="$XDG_CONFIG_HOME/nvim"

echo ">>> REDVIM installer"
echo "Target nvim config: $NVIM_CONFIG_DIR"

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Try to install git/nvim if missing (best-effort)
if ! command_exists git; then
  echo "git not found. Attempting to install..."
  if command_exists apt-get; then
    sudo apt-get update && sudo apt-get install -y git
  elif command_exists pacman; then
    sudo pacman -S --noconfirm git
  elif command_exists brew; then
    brew install git
  else
    echo "Please install git and re-run the script."
    exit 1
  fi
fi

if ! command_exists nvim; then
  echo "Neovim (nvim) not found. Attempting to install (best-effort)..."
  if command_exists apt-get; then
    sudo apt-get update && sudo apt-get install -y neovim
  elif command_exists pacman; then
    sudo pacman -S --noconfirm neovim
  elif command_exists brew; then
    brew install neovim
  else
    echo "Automatic installation not supported on this OS. Please install Neovim and re-run."
    exit 1
  fi
fi

# Backup existing config if present
if [ -d "$NVIM_CONFIG_DIR" ] || [ -f "$NVIM_CONFIG_DIR/init.lua" ]; then
  TIMESTAMP="$(date +%Y%m%d%H%M%S)"
  BACKUP="${NVIM_CONFIG_DIR}.backup.${TIMESTAMP}"
  echo "Backing up existing config to: $BACKUP"
  mv "$NVIM_CONFIG_DIR" "$BACKUP"
fi

# Clone repository
TMPDIR="$(mktemp -d)"
echo "Cloning $REPO (branch $BRANCH) to temporary dir $TMPDIR"
git clone --depth 1 --branch "$BRANCH" "$REPO" "$TMPDIR"

# Create config dir parent and move files
mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"
mv "$TMPDIR" "$NVIM_CONFIG_DIR"
echo "Configuration copied to $NVIM_CONFIG_DIR"

# Ensure file permissions
chmod -R u+rwX "$NVIM_CONFIG_DIR"

# Try headless install of plugins via lazy.nvim
echo "Running Neovim headless to install plugins (may take a while)..."
# Load init.lua and call lazy.sync() — best-effort; user can run :Lazy sync manually if needed
nvim --headless -u "${NVIM_CONFIG_DIR}/init.lua" \
  -c "lua if pcall(function() require('lazy').sync() end) then vim.cmd('qa') else vim.cmd('qa') end" \
  || echo "Headless plugin sync finished (or failed). If plugins aren't installed, open nvim and run :Lazy sync or :Lazy install."

# Cleanup tmp if still present
if [ -d "$TMPDIR" ]; then rm -rf "$TMPDIR"; fi

echo ">>> REDVIM installation complete."
echo "Open Neovim and verify config with: nvim"
