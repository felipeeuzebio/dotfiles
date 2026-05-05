## Learned User Preferences

- Prefer concise, minimal solutions; avoid over-engineering or extra machinery when a few lines of bash/config will do.
- If a Python project is needed, initialize a `uv` project named `scripts` at the repo root (do not nest under `mise/` or other folders).
- Prefer flat directory layouts (e.g., `mise/tasks/<task>`) over nested subgroups.
- Avoid AppImages when reasonable; do not commit large binaries to this repo.
- When proposing changes that span multiple approaches, lay out trade-offs and let the user pick the direction instead of assuming.

## Learned Workspace Facts

- Dotfiles are managed by chezmoi; respect chezmoi naming conventions: `executable_*`, `dot_*`, `private_dot_*`, `run_once_*`, `run_once_before_*`, and `*.tmpl` templates.
- Supported distro families: Arch, Debian (incl. Ubuntu), and Fedora (incl. RHEL) — both mutable and immutable variants. Detection matches `/etc/os-release` `ID` and `ID_LIKE` against `arch`, `debian`, `ubuntu`, `fedora`, `rhel`.
- Two-layer distro guard: `run_once_before_check-distro.sh.tmpl` aborts `chezmoi apply` early; `dot_local/bin/executable_check-distro.sh` is the runtime helper (executable and sourceable as `dotfiles_check_distro`). Other install scripts call it via `"${SCRIPT_DIR}/check-distro.sh"`.
- An Arch-based distrobox (`arch-dev`) is bootstrapped by `distrobox.ini`; its `init_hooks` build `paru` from the AUR for AUR-package access.
- Runtime versions and tasks are managed by `mise`; runtime config lives at `private_dot_config/mise/config.toml`.
- `Brewfile` is the cross-platform package manifest. On Linux only `brew`, `tap`, and `vscode` directives apply; `cask` is macOS-only and silently no-ops on Linux.
- Nerd fonts on Linux are installed via the `io.github.getnf.embellish` flatpak rather than Homebrew casks.
- Bash install scripts in `dot_local/bin/` use `set -euo pipefail` and a shared ANSI color palette (`BLUE`, `CYAN`, `GREEN`, `RED`, `YELLOW`, `NC`).
- Continual-learning index lives at `.cursor/hooks/state/continual-learning-index.json` and tracks transcript mtimes for incremental processing.
