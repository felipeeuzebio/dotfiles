#!/usr/bin/env bash

set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
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
while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    [[ -z "$pkg" ]] && continue

    # Skip if already installed.
    if pacman -Qi "$pkg" &>/dev/null; then
        continue
    fi

    # Try paru and verify the exact package was installed afterwards.
    # --noconfirm silently picks option 1 when paru shows a provider
    # disambiguation menu, which may not match the requested package name.
    if ! paru -S --needed --noconfirm "$pkg" || ! pacman -Qi "$pkg" &>/dev/null; then
        printf "${YELLOW}paru did not install %s; retrying via direct AUR clone...${NC}\n" "$pkg" >&2
        _tmpdir="$(mktemp -d)"
        git clone --depth=1 "https://aur.archlinux.org/${pkg}.git" "${_tmpdir}"
        # Remove any conflicting packages declared in the PKGBUILD.
        mapfile -t _conflicts < <(bash -c "cd '${_tmpdir}' && . ./PKGBUILD 2>/dev/null && printf '%s\n' \"\${conflicts[@]:-}\"")
        for _c in "${_conflicts[@]:-}"; do
            [[ -z "${_c}" ]] && continue
            pacman -Qi "${_c}" &>/dev/null && sudo pacman -R --noconfirm "${_c}" || true
        done
        (cd "${_tmpdir}" && makepkg -si --noconfirm --needed)
        rm -rf "${_tmpdir}"
    fi
done < "$MANIFEST"
printf "${GREEN}Arch package installs finished.${NC}\n"
