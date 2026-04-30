#!/usr/bin/env bash

set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

if command -v brave-browser >/dev/null 2>&1; then
    printf "${YELLOW}Brave is already installed, skipping.${NC}\n"
    exit 0
fi

printf "${BLUE}Installing Brave via official install script (curl | sh).${NC}\n"
printf "${YELLOW}This may prompt for privileges to configure your package manager.${NC}\n"

curl -fsS https://dl.brave.com/install.sh | sh

printf "${GREEN}Brave installation finished.${NC}\n"
