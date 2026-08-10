#!/usr/bin/env bash
set -euo pipefail

GEOMETRY="$(slurp)"

[[ -z "${GEOMETRY:-}" ]] && exit 0

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
SOCKET="$RUNTIME_DIR/shnx-shell/backend.sock"

python3 - "$SOCKET" "$GEOMETRY" <<'PY'
import json
import socket
import sys

socket_path = sys.argv[1]
geometry = sys.argv[2]

message = {
    "protocol_version": 1,
    "type": "command",
    "request_id": "screenshot-region-shortcut",
    "command": "screenshot.region",
    "payload": {
        "geometry": geometry
    }
}

with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
    sock.connect(socket_path)
    sock.sendall((json.dumps(message) + "\n").encode())

    response = sock.makefile().readline()
    if response:
        print(response.strip())
PY
