# dotfiles

Personal dotfiles for Arch-based distros (Arch, CachyOS, EndeavourOS, Manjaro, Garuda, etc.). Managed by [chezmoi](https://www.chezmoi.io/).

## Bootstrap

On a fresh machine:

```bash
curl -fsSL https://raw.githubusercontent.com/felipeeuzebio/dotfiles/main/bootstrap.sh | bash
```

This will:

1. Verify the host is Arch-based (`/etc/os-release` `ID` / `ID_LIKE` matches `arch`).
2. Install `git` and `base-devel` via `pacman`.
3. Bootstrap `paru-bin` from the AUR if no AUR helper (`paru` / `yay`) is present.
4. Install `chezmoi` and `mise`.
5. Apply the dotfiles with `chezmoi init --apply felipeeuzebio/dotfiles`.
6. Install packages from `arch-packages.txt` and Flatpaks from `flatpaks.txt`.

## Manual tasks

After bootstrap, [`mise`](https://mise.jdx.dev/) tasks are available:

```bash
mise run install-arch-packages   # paru -S from arch-packages.txt
mise run install-flatpaks        # flatpak install from flatpaks.txt
mise run setup-distrobox         # distrobox assemble from distrobox.ini
```

## Layout

- `arch-packages.txt` — pacman/AUR package names, one per line.
- `flatpaks.txt` — `app<TAB>remote` per line.
- `bootstrap.sh` — one-shot installer (above).
- `run_once_before_check-distro.sh` — chezmoi guard that aborts on non-Arch hosts.
- `run_once_install-paru.sh` — bootstraps `paru` during `chezmoi apply` (skips if `paru` or `yay` is present).
- `dot_local/bin/` — installer scripts (chezmoi applies to `~/.local/bin/`).
- `private_dot_config/mise/` — mise config and task files.
- `distrobox.ini` — distrobox assemble manifest (Arch dev container).
