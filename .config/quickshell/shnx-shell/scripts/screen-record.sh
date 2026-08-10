#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
SOCKET="$RUNTIME_DIR/shnx-shell/backend.sock"

send_command() {
  local command="$1"
  local payload="$2"

  python3 - "$SOCKET" "$command" "$payload" <<'PY'
import json
import socket
import sys

socket_path = sys.argv[1]
command = sys.argv[2]
payload = json.loads(sys.argv[3])

message = {
    "protocol_version": 1,
    "type": "command",
    "request_id": "screen-record-shortcut",
    "command": command,
    "payload": payload,
}

with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
    sock.connect(socket_path)
    sock.sendall((json.dumps(message) + "\n").encode())

    response = sock.makefile().readline()

    if response:
        print(response.strip())
PY
}

STATUS="$(
  send_command \
    "screen.status" \
    '{}'
)"

ACTIVE="$(
  printf '%s\n' "$STATUS" |
    jq -r '.payload.active // false'
)"

if [[ "$ACTIVE" == "true" ]]; then
  send_command \
    "screen.stop" \
    '{}'

  exit 0
fi

OUTPUT="$(
  hyprctl activeworkspace -j |
    jq -r '.monitor'
)"

if [[ -z "${OUTPUT:-}" || "$OUTPUT" == "null" ]]; then
  echo "[screen-record] Could not resolve active monitor" >&2
  exit 1
fi

send_command \
  "screen.start" \
  "$(jq -nc --arg output "$OUTPUT" '{output:$output}')"
