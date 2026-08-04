from __future__ import annotations

from dataclasses import dataclass
from typing import Any


PROTOCOL_VERSION = 1


@dataclass(slots=True)
class IncomingMessage:
    protocol_version: int
    message_type: str
    request_id: str | None
    command: str | None
    payload: dict[str, Any]


def response_message(
    *,
    request_id: str | None,
    command: str,
    payload: dict[str, Any] | None = None,
) -> dict[str, Any]:
    return {
        "protocol_version": PROTOCOL_VERSION,
        "type": "response",
        "request_id": request_id,
        "command": command,
        "ok": True,
        "payload": payload or {},
    }


def error_message(
    *,
    request_id: str | None,
    code: str,
    message: str,
) -> dict[str, Any]:
    return {
        "protocol_version": PROTOCOL_VERSION,
        "type": "error",
        "request_id": request_id,
        "ok": False,
        "error": {
            "code": code,
            "message": message,
        },
    }


def event_message(
    *,
    event: str,
    payload: dict[str, Any] | None = None,
) -> dict[str, Any]:
    return {
        "protocol_version": PROTOCOL_VERSION,
        "type": "event",
        "event": event,
        "payload": payload or {},
    }
