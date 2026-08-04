from __future__ import annotations

import asyncio
import logging
import os
from pathlib import Path
from typing import Awaitable, Callable

from .messages import error_message
from .protocol import ProtocolError, decode_message, encode_message


MessageHandler = Callable[
    [object],
    Awaitable[dict],
]


class IpcServer:
    def __init__(
        self,
        socket_path: Path,
        message_handler: MessageHandler,
    ) -> None:
        self._socket_path = socket_path
        self._message_handler = message_handler
        self._server: asyncio.AbstractServer | None = None
        self._clients: set[asyncio.StreamWriter] = set()
        self._logger = logging.getLogger(__name__)

    @property
    def socket_path(self) -> Path:
        return self._socket_path

    async def start(self) -> None:
        self._socket_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        self._remove_stale_socket()

        self._server = await asyncio.start_unix_server(
            self._handle_client,
            path=self._socket_path,
        )

        os.chmod(self._socket_path, 0o600)

        self._logger.info(
            "IPC server listening at %s",
            self._socket_path,
        )

    async def stop(self) -> None:
        for writer in list(self._clients):
            writer.close()

        for writer in list(self._clients):
            try:
                await writer.wait_closed()
            except (BrokenPipeError, ConnectionError):
                pass

        self._clients.clear()

        if self._server is not None:
            self._server.close()
            await self._server.wait_closed()
            self._server = None

        self._remove_stale_socket()

    async def serve_forever(self) -> None:
        if self._server is None:
            raise RuntimeError(
                "IPC server must be started before serve_forever()."
            )

        async with self._server:
            await self._server.serve_forever()

    async def send(
        self,
        writer: asyncio.StreamWriter,
        message: dict,
    ) -> None:
        writer.write(encode_message(message))
        await writer.drain()

    async def _handle_client(
        self,
        reader: asyncio.StreamReader,
        writer: asyncio.StreamWriter,
    ) -> None:
        self._clients.add(writer)

        self._logger.info("QML client connected")

        try:
            while not reader.at_eof():
                raw_message = await reader.readline()

                if not raw_message:
                    break

                if len(raw_message) > 1024 * 1024:
                    await self.send(
                        writer,
                        error_message(
                            request_id=None,
                            code="message_too_large",
                            message="Message exceeds the 1 MiB limit.",
                        ),
                    )
                    continue

                try:
                    incoming = decode_message(raw_message)
                    outgoing = await self._message_handler(incoming)
                except ProtocolError as error:
                    outgoing = error_message(
                        request_id=None,
                        code=error.code,
                        message=error.message,
                    )
                except Exception:
                    self._logger.exception(
                        "Unhandled error while processing message"
                    )

                    outgoing = error_message(
                        request_id=None,
                        code="internal_error",
                        message="The backend encountered an internal error.",
                    )

                await self.send(writer, outgoing)

        except (
            asyncio.IncompleteReadError,
            BrokenPipeError,
            ConnectionResetError,
        ):
            pass
        finally:
            self._clients.discard(writer)

            writer.close()

            try:
                await writer.wait_closed()
            except (BrokenPipeError, ConnectionError):
                pass

            self._logger.info("QML client disconnected")

    def _remove_stale_socket(self) -> None:
        try:
            if self._socket_path.exists():
                self._socket_path.unlink()
        except OSError:
            self._logger.exception(
                "Could not remove socket %s",
                self._socket_path,
            )
            raise
