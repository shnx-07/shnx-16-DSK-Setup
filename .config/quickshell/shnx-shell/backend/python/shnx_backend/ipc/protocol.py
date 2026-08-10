from __future__ import annotations

import json
from typing import Any

from .messages import IncomingMessage, PROTOCOL_VERSION


class ProtocolError(ValueError):
    def __init__(self, code: str, message: str) -> None:
        super().__init__(message)
        self.code = code
        self.message = message


def decode_message(raw_message: bytes) -> IncomingMessage:
    try:
        decoded = raw_message.decode("utf-8")
    except UnicodeDecodeError as error:
        raise ProtocolError(
            "invalid_encoding",
            "Messages must use UTF-8 encoding.",
        ) from error

    try:
        data = json.loads(decoded)
    except json.JSONDecodeError as error:
        raise ProtocolError(
            "invalid_json",
            "Message is not valid JSON.",
        ) from error

    if not isinstance(data, dict):
        raise ProtocolError(
            "invalid_message",
            "Top-level JSON value must be an object.",
        )

    protocol_version = data.get("protocol_version")

    if not isinstance(protocol_version, int):
        raise ProtocolError(
            "missing_protocol_version",
            "protocol_version must be an integer.",
        )

    if protocol_version != PROTOCOL_VERSION:
        raise ProtocolError(
            "protocol_version_mismatch",
            (
                f"Unsupported protocol version {protocol_version}; "
                f"expected {PROTOCOL_VERSION}."
            ),
        )

    message_type = data.get("type")

    if not isinstance(message_type, str):
        raise ProtocolError(
            "missing_message_type",
            "type must be a string.",
        )

    request_id = data.get("request_id")

    if request_id is not None and not isinstance(request_id, str):
        raise ProtocolError(
            "invalid_request_id",
            "request_id must be a string or null.",
        )

    command = data.get("command")

    if command is not None and not isinstance(command, str):
        raise ProtocolError(
            "invalid_command",
            "command must be a string or null.",
        )

    payload = data.get("payload", {})

    if not isinstance(payload, dict):
        raise ProtocolError(
            "invalid_payload",
            "payload must be an object.",
        )

    return IncomingMessage(
        protocol_version=protocol_version,
        message_type=message_type,
        request_id=request_id,
        command=command,
        payload=payload,
    )


def encode_message(message: dict[str, Any]) -> bytes:
    return (
        json.dumps(
            message,
            ensure_ascii=False,
            separators=(",", ":"),
        )
        + "\n"
    ).encode("utf-8")
