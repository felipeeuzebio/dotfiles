#!/usr/bin/env bash
# Runs once per machine during `chezmoi apply` — or run manually: mise run install-brave
exec "$HOME/.local/bin/install-brave.sh"
