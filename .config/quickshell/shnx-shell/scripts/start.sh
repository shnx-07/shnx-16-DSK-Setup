#!/usr/bin/env bash

set -u

SHELL_ROOT="$HOME/.config/quickshell/shnx-shell"
BACKEND_DIR="$SHELL_ROOT/backend/python"

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/shnx-shell"
LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/shnx-shell"

BACKEND_PID_FILE="$RUNTIME_DIR/backend.pid"
QUICKSHELL_PID_FILE="$RUNTIME_DIR/quickshell.pid"

BACKEND_LOG="$LOG_DIR/backend.log"
QUICKSHELL_LOG="$LOG_DIR/quickshell.log"

mkdir -p "$RUNTIME_DIR" "$LOG_DIR"

pid_is_running() {
  local pid_file="$1"

  [[ -f "$pid_file" ]] || return 1

  local pid
  pid="$(cat "$pid_file" 2>/dev/null)"

  [[ -n "$pid" ]] || return 1

  kill -0 "$pid" 2>/dev/null
}

echo "[SHNX] Starting shell..."

# ============================================================
# Backend
# ============================================================

if pid_is_running "$BACKEND_PID_FILE"; then
  echo "[SHNX] Backend already running."
else
  rm -f "$BACKEND_PID_FILE"

  echo "[SHNX] Starting backend..."

  (
    cd "$BACKEND_DIR" || exit 1

    exec python3 main.py
  ) >>"$BACKEND_LOG" 2>&1 &

  BACKEND_PID=$!

  echo "$BACKEND_PID" >"$BACKEND_PID_FILE"

  sleep 0.2

  if kill -0 "$BACKEND_PID" 2>/dev/null; then
    echo "[SHNX] Backend started (PID $BACKEND_PID)."
  else
    echo "[SHNX] WARNING: Backend failed to start."
    echo "[SHNX] Check: $BACKEND_LOG"

    rm -f "$BACKEND_PID_FILE"
  fi
fi

# ============================================================
# Quickshell
# ============================================================

if pid_is_running "$QUICKSHELL_PID_FILE"; then
  echo "[SHNX] Quickshell already running."
else
  rm -f "$QUICKSHELL_PID_FILE"

  echo "[SHNX] Starting Quickshell..."

  qs -c shnx-shell \
    >>"$QUICKSHELL_LOG" 2>&1 &

  QUICKSHELL_PID=$!

  echo "$QUICKSHELL_PID" >"$QUICKSHELL_PID_FILE"

  sleep 0.2

  if kill -0 "$QUICKSHELL_PID" 2>/dev/null; then
    echo "[SHNX] Quickshell started (PID $QUICKSHELL_PID)."
  else
    echo "[SHNX] ERROR: Quickshell failed to start."
    echo "[SHNX] Check: $QUICKSHELL_LOG"

    rm -f "$QUICKSHELL_PID_FILE"

    exit 1
  fi
fi

echo
echo "[SHNX] Shell running."
