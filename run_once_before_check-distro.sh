#!/usr/bin/env bash
# Aborts `chezmoi apply` on non-Arch hosts. Runs before any files are written.

set -euo pipefail

ID=""
ID_LIKE=""
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
fi

case " ${ID} ${ID_LIKE} " in
    *" arch "*)
        exit 0
        ;;
esac

printf '\033[0;31mERROR:\033[0m unsupported distribution: %s\n' "${ID:-unknown}" >&2
printf 'These dotfiles only support Arch-based distros (pacman/paru required).\n' >&2
exit 1
