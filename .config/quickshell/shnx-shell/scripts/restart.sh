#!/usr/bin/env bash

set -e

SHELL_ROOT="$HOME/.config/quickshell/shnx-shell"
SCRIPTS_DIR="$SHELL_ROOT/scripts"

echo "[SHNX] Restarting shell..."
echo

"$SCRIPTS_DIR/stop.sh"

sleep 0.5

echo

"$SCRIPTS_DIR/start.sh"
