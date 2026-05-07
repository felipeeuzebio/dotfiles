#!/usr/bin/env bash

set -euo pipefail

BLUE='\033[0;34m'
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

printf "${BLUE}Installing Flatpaks from %s...${NC}\n" "$MANIFEST"

# For each remote in the manifest: ensure it exists, then install all its
# apps in one call. --noninteractive suppresses the progress UI that leaks
# ANSI cursor-position queries (^[[row;colR) into the terminal output.
while IFS= read -r remote; do
    [[ "$remote" == "flathub" ]] && \
        flatpak remote-add --if-not-exists flathub 'https://flathub.org/repo/flathub.flatpakrepo'
    mapfile -t apps < <(awk -F'\t' -v r="$remote" '$2 == r {print $1}' "$MANIFEST")
    flatpak install --noninteractive "$remote" "${apps[@]}"
done < <(awk -F'\t' '{print $2}' "$MANIFEST" | sort -u)

printf "${GREEN}Flatpak installs finished.${NC}\n"
