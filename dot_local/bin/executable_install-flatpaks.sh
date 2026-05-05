#!/usr/bin/env bash

set -euo pipefail

BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/check-distro.sh"

if ! command -v flatpak >/dev/null 2>&1; then
    printf "${RED}flatpak not found.${NC} Install it with pacman: sudo pacman -S flatpak\n" >&2
    exit 1
fi

MANIFEST="${FLATPAKS_MANIFEST:-$HOME/flatpaks.txt}"
if [ ! -f "$MANIFEST" ]; then
    printf "${RED}Manifest not found:${NC} %s\n" "$MANIFEST" >&2
    exit 1
fi

# Ensure Flathub exists when manifests reference it (all current entries use flathub).
flatpak remote-add --if-not-exists flathub 'https://flathub.org/repo/flathub.flatpakrepo'

printf "${BLUE}Installing Flatpaks from ${MANIFEST}...${NC}\n"
while IFS=$'\t' read -r app remote || [ -n "${app:-}" ]; do
    app="${app%$'\r'}"
    remote="${remote%$'\r'}"
    [[ -z "$app" || "$app" =~ ^[[:space:]]*# ]] && continue
    remote="${remote:-flathub}"
    printf "${CYAN}%s${NC} ← %s\n" "$app" "$remote"
    flatpak install -y "$remote" "$app"
done <"$MANIFEST"

printf "${GREEN}Flatpak installs finished.${NC}\n"
