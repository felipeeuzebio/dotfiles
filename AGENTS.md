## Learned User Preferences

- Prefer concise, minimal solutions; avoid over-engineering or extra machinery when a few lines of bash/config will do.
- If a Python project is needed, initialize a `uv` project named `scripts` at the repo root (do not nest under `mise/` or other folders).
- Prefer flat directory layouts (e.g., `mise/tasks/<task>`) over nested subgroups.
- Avoid AppImages when reasonable; do not commit large binaries to this repo.
- When proposing changes that span multiple approaches, lay out trade-offs and let the user pick the direction instead of assuming.

## Learned Workspace Facts

- Dotfiles are managed by chezmoi; respect chezmoi naming conventions: `executable_*`, `dot_*`, `private_dot_*`, `run_once_*`, `run_once_before_*`, and `*.tmpl` templates.
- Supported scope is **Arch-based distros only**: `/etc/os-release` `ID` and `ID_LIKE` must match `arch` (covers Manjaro, EndeavourOS, CachyOS, etc.). Debian/Fedora support is deferred.
- Two-layer distro guard: `run_once_before_check-distro.sh` aborts `chezmoi apply` early (plain bash, sources `/etc/os-release`); `dot_local/bin/executable_check-distro.sh` is the runtime helper (executable and sourceable as `dotfiles_check_distro`). Other install scripts call it via `"${SCRIPT_DIR}/check-distro.sh"`.
- An Arch-based distrobox (`arch-dev`) is bootstrapped by `distrobox.ini`; its `init_hooks` build `paru` from the AUR for AUR-package access. The `setup-distrobox` mise task runs `distrobox assemble create --file ~/distrobox.ini`.
- Runtime versions and tasks are managed by `mise`; runtime config lives at `private_dot_config/mise/config.toml`.
- Package installs use `pacman`/`paru` (no Homebrew or `Brewfile` in-repo; `brew-bundle` / `brew-dump` mise tasks removed). `executable_install-paru.sh` bootstraps `paru` from the AUR and skips if `paru` or `yay` is already present; `run_once_install-paru.sh` runs it during apply.
- Nerd fonts on Linux are installed via the `io.github.getnf.embellish` flatpak rather than Homebrew casks.
- Flatpak apps are listed in `flatpaks.txt` (format: `app<TAB>remote` per line; chezmoi applies to `~/flatpaks.txt`); `executable_install-flatpaks.sh` and mise task `install-flatpaks` install from that manifest (`FLATPAKS_MANIFEST` overrides the path).
- Arch packages are listed in `arch-packages.txt` (plain package names only, one per line, no comments or headers; chezmoi applies to `~/arch-packages.txt`); `executable_install-arch-packages.sh` and mise task `install-arch-packages` install via `xargs paru -S --needed --noconfirm < manifest` (`ARCH_PACKAGES_MANIFEST` overrides the path). Includes `brave-bin`, `jetbrains-toolbox`, and other official-repo/AUR packages — dedicated install scripts for those were removed.
- Bash install scripts in `dot_local/bin/` use `set -euo pipefail` and a shared ANSI color palette (`BLUE`, `CYAN`, `GREEN`, `RED`, `YELLOW`, `NC`).
- `bootstrap.sh` at repo root installs `chezmoi` + `mise` via pacman, runs `chezmoi init --apply github.com/<user>/<repo>`, then `mise run install-arch-packages` + `mise run install-flatpaks`; takes `<github-user>/<repo>` as CLI arg.
- Continual-learning index lives at `.cursor/hooks/state/continual-learning-index.json` and tracks transcript mtimes for incremental processing.
