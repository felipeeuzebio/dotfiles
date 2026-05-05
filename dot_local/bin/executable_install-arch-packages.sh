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

printf "${BLUE}Installing packages from %s (paru)...${NC}\n" "$MANIFEST"
xargs paru -S --needed --noconfirm < "$MANIFEST"
printf "${GREEN}Arch package installs finished.${NC}\n"
