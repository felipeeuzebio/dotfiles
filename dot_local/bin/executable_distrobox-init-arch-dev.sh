#!/usr/bin/env bash
set -euo pipefail

BLUE='\033[0;34m'
NC='\033[0m'

command -v paru > /dev/null && exit 0

cleanup() { rm -rf /tmp/paru; }
trap cleanup EXIT

printf "${BLUE}Building paru...${NC}\n"
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si --noconfirm
