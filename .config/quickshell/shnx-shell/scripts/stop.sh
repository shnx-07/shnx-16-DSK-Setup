#!/usr/bin/env bash

set -u

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/shnx-shell"

BACKEND_PID_FILE="$RUNTIME_DIR/backend.pid"
QUICKSHELL_PID_FILE="$RUNTIME_DIR/quickshell.pid"

stop_process() {
  local name="$1"
  local pid_file="$2"

  if [[ ! -f "$pid_file" ]]; then
    echo "[SHNX] $name PID file not found."
    return
  fi

  local pid
  pid="$(cat "$pid_file" 2>/dev/null)"

  if [[ -z "$pid" ]]; then
    rm -f "$pid_file"
    return
  fi

  if ! kill -0 "$pid" 2>/dev/null; then
    echo "[SHNX] $name already stopped."
    rm -f "$pid_file"
    return
  fi

  echo "[SHNX] Stopping $name (PID $pid)..."

  kill -TERM "$pid" 2>/dev/null || true

  for _ in {1..30}; do
    if ! kill -0 "$pid" 2>/dev/null; then
      break
    fi

    sleep 0.1
  done

  if kill -0 "$pid" 2>/dev/null; then
    echo "[SHNX] Forcing $name to stop..."

    kill -KILL "$pid" 2>/dev/null || true
  fi

  rm -f "$pid_file"

  echo "[SHNX] $name stopped."
}

echo "[SHNX] Stopping shell..."

# Frontend first.
stop_process \
  "Quickshell" \
  "$QUICKSHELL_PID_FILE"

# Backend second.
stop_process \
  "Backend" \
  "$BACKEND_PID_FILE"

echo
echo "[SHNX] Shell stopped."
