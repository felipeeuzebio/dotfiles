#!/usr/bin/env bash

set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/check-distro.sh"

if ! command -v paru >/dev/null 2>&1; then
    printf "${RED}paru not found.${NC} Install it with install-paru.\n" >&2
    exit 1
fi

MANIFEST="${ARCH_PACKAGES_MANIFEST:-$HOME/arch-packages.txt}"
if [ ! -f "$MANIFEST" ]; then
    printf "${RED}Manifest not found:${NC} %s\n" "$MANIFEST" >&2
    exit 1
fi

printf "${BLUE}Installing packages from %s...${NC}\n" "$MANIFEST"

# Official repo packages — install all at once with pacman.
comm -12 <(pacman -Slq | sort) <(sort "$MANIFEST") \
    | xargs -r sudo pacman -S --needed --noconfirm

# AUR packages — one at a time so paru performs an exact-name lookup
# instead of a fuzzy search that triggers a disambiguation menu.
comm -23 <(pacman -Slq | sort) <(sort "$MANIFEST") \
    | xargs -rI {} paru -S --needed --noconfirm {}

printf "${GREEN}Arch package installs finished.${NC}\n"
