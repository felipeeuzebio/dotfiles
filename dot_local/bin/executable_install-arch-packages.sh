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

# AUR packages — all at once. Exact names (already filtered from official
# repos) let paru use AUR info lookups instead of fuzzy search, so no
# disambiguation menu appears. Batching lets paru resolve shared deps once
# and build in the optimal order.
comm -23 <(pacman -Slq | sort) <(sort "$MANIFEST") \
    | xargs -r paru -S --needed --noconfirm

printf "${GREEN}Arch package installs finished.${NC}\n"
