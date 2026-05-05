#!/usr/bin/env bash
# Runs once per machine during `chezmoi apply` — or run manually: mise run install-paru
exec "$HOME/.local/bin/install-paru.sh"
