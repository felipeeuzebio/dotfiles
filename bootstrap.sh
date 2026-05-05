#!/usr/bin/env bash
# One-shot bootstrap for a fresh Arch-based machine.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/felipeeuzebio/dotfiles/main/bootstrap.sh | bash
#
# Steps:
#   1. Verify the host is Arch-based (ID/ID_LIKE matches "arch").
#   2. Ensure pacman prerequisites (git, base-devel) are installed.
#   3. Ensure an AUR helper (paru or yay) — bootstrap paru-bin from AUR if missing.
#   4. Install chezmoi + mise via paru/yay.
#   5. `chezmoi init --apply` against this repo.
#   6. Run the package + flatpak install tasks.

set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

REPO="${DOTFILES_REPO:-felipeeuzebio/dotfiles}"

step() { printf "${BLUE}==>${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}!!${NC} %s\n" "$*" >&2; }
die()  { printf "${RED}ERROR:${NC} %s\n" "$*" >&2; exit 1; }

ID=""; ID_LIKE=""
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
fi
case " ${ID} ${ID_LIKE} " in
    *" arch "*) ;;
    *) die "unsupported distribution: ${ID:-unknown} (Arch-based only)";;
esac

step "Installing pacman prerequisites (git, base-devel)..."
sudo pacman -S --needed --noconfirm git base-devel

helper=""
for h in paru yay; do
    if command -v "$h" >/dev/null 2>&1; then
        helper="$h"
        break
    fi
done

if [ -z "$helper" ]; then
    step "No AUR helper found — bootstrapping paru-bin from the AUR..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    git clone --depth=1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
    (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
    helper="paru"
fi

step "Installing chezmoi and mise via ${helper}..."
"$helper" -S --needed --noconfirm chezmoi mise

step "Applying chezmoi from ${REPO}..."
chezmoi init --apply "$REPO"

step "Installing Arch packages..."
mise run install-arch-packages

step "Installing Flatpaks..."
mise run install-flatpaks

printf "${GREEN}Bootstrap complete.${NC}\n"
