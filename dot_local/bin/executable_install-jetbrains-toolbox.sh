#!/usr/bin/env bash

# The three safeguards
set -euo pipefail

# ANSI Color Codes
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Define paths
INSTALL_DIR="$HOME/.local/bin"
TOOLBOX_PATH="$INSTALL_DIR/jetbrains-toolbox"
TEMP_DIR=$(mktemp -d)
API_URL="https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"

# Cleanup function for temp files
cleanup() {
    if [ -d "${TEMP_DIR:-}" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Check for existing installation
if [ -f "$TOOLBOX_PATH" ]; then
    printf "${YELLOW}JetBrains Toolbox is already installed at:${NC} %s\n" "$TOOLBOX_PATH"
    printf "${YELLOW}Skipping installation. Use the Toolbox App itself to check for updates.${NC}\n"
    exit 0
fi

printf "${BLUE}Fetching latest JetBrains Toolbox version...${NC}\n"

# Get the download URL for Linux
DOWNLOAD_URL=$(curl -sL "$API_URL" | grep -oP 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-[^"]+\.tar\.gz' | head -n 1) || {
    printf "${RED}Error: Could not reach JetBrains API.${NC}\n"
    exit 1
}

printf "${CYAN}Downloading from:${NC} %s\n" "$DOWNLOAD_URL"
curl -L "$DOWNLOAD_URL" -o "$TEMP_DIR/toolbox.tar.gz"

printf "${BLUE}Extracting...${NC}\n"
tar -xzf "$TEMP_DIR/toolbox.tar.gz" -C "$TEMP_DIR" --strip-components=1

# Move the binary
mkdir -p "$INSTALL_DIR"
mv "$TEMP_DIR/jetbrains-toolbox" "$TOOLBOX_PATH"
chmod +x "$TOOLBOX_PATH"

printf "${GREEN}Success: JetBrains Toolbox installed successfully.${NC}\n"
