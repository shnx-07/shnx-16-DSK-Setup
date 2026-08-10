#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
SOCKET="$RUNTIME_DIR/shnx-shell/backend.sock"

OUTPUT="$(hyprctl activeworkspace -j | jq -r '.monitor')"

if [[ -z "${OUTPUT:-}" || "$OUTPUT" == "null" ]]; then
  echo "[screenshot-full] Could not resolve active monitor" >&2
  exit 1
fi

echo "[screenshot-full] Capturing monitor: $OUTPUT"

python3 - "$SOCKET" "$OUTPUT" <<'PY'
import json
import socket
import sys

socket_path = sys.argv[1]
output = sys.argv[2]

message = {
    "protocol_version": 1,
    "type": "command",
    "request_id": "screenshot-full-shortcut",
    "command": "screenshot.full",
    "payload": {
        "output": output
    }
}

with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
    sock.connect(socket_path)
    sock.sendall((json.dumps(message) + "\n").encode())

    response = sock.makefile().readline()

    if response:
        print(response.strip())
PY
