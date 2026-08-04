#!/usr/bin/env python3

from __future__ import annotations

import asyncio
import logging
import sys

from shnx_backend.application import BackendApplication


def configure_logging() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="[shnx-backend] %(levelname)s %(name)s: %(message)s",
    )


async def async_main() -> None:
    application = BackendApplication()
    await application.run()


def main() -> int:
    configure_logging()

    try:
        asyncio.run(async_main())
    except KeyboardInterrupt:
        return 0
    except Exception:
        logging.getLogger(__name__).exception(
            "Backend stopped because of an unrecoverable error"
        )
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
