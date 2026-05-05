#!/usr/bin/env bash
# Verify the host is an Arch-based distro.
# Exits 0 on supported, 1 on unsupported. Can also be sourced (defines
# `dotfiles_check_distro`) without exiting.

set -euo pipefail

dotfiles_check_distro() {
    local id="" id_like=""

    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        id="${ID:-}"
        id_like="${ID_LIKE:-}"
    fi

    case " ${id} ${id_like} " in
        *" arch "*)
            return 0
            ;;
    esac

    printf '\033[0;31mERROR:\033[0m unsupported distribution: %s\n' "${id:-unknown}" >&2
    printf 'These dotfiles only support Arch-based distros (pacman/paru required).\n' >&2
    return 1
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    dotfiles_check_distro
fi
