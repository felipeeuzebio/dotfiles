#!/usr/bin/env bash

set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/check-distro.sh"

for helper in paru yay; do
    if command -v "$helper" >/dev/null 2>&1; then
        printf "${YELLOW}AUR helper '%s' is already installed, skipping.${NC}\n" "$helper"
        exit 0
    fi
done

TEMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "${TEMP_DIR:-}"; }
trap cleanup EXIT

printf "${BLUE}Installing build prerequisites...${NC}\n"
sudo pacman -S --needed base-devel

printf "${BLUE}Building paru from the AUR...${NC}\n"
cd "${TEMP_DIR}"
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

printf "${GREEN}paru installed successfully.${NC}\n"
