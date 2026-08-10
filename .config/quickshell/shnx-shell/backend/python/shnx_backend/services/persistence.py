from __future__ import annotations

import json
import os
import tempfile
from pathlib import Path
from typing import Any


class PersistenceError(RuntimeError):
    """Raised when SHNX backend state cannot be loaded or saved."""


_BACKEND_ROOT = Path(__file__).resolve().parents[1]

_STORAGE_DIRECTORY = (
    _BACKEND_ROOT
    / "storage"
)


def ensure_storage() -> None:
    """
    Ensure backend-owned storage exists.
    """

    try:
        _STORAGE_DIRECTORY.mkdir(
            parents=True,
            exist_ok=True,
        )

    except OSError as exc:
        raise PersistenceError(
            f"Could not create storage directory: "
            f"{_STORAGE_DIRECTORY}"
        ) from exc


def load_json(
    path: Path,
    *,
    default: Any = None,
) -> Any:
    """
    Safely load JSON.

    Missing files return the provided default.
    """

    if not path.exists():
        return default

    try:
        with path.open(
            "r",
            encoding="utf-8",
        ) as handle:
            return json.load(handle)

    except json.JSONDecodeError as exc:
        raise PersistenceError(
            f"Invalid JSON in {path}"
        ) from exc

    except OSError as exc:
        raise PersistenceError(
            f"Could not read {path}"
        ) from exc


def save_json(
    path: Path,
    data: Any,
) -> None:
    """
    Atomically save JSON.

    The temporary file is written in the same directory
    and then moved over the destination.
    """

    ensure_storage()

    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    temporary_path: Path | None = None

    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=path.parent,
            prefix=path.name + ".",
            suffix=".tmp",
            delete=False,
        ) as handle:
            json.dump(
                data,
                handle,
                ensure_ascii=False,
                indent=2,
                sort_keys=True,
            )

            handle.write("\n")
            handle.flush()

            os.fsync(
                handle.fileno()
            )

            temporary_path = Path(
                handle.name
            )

        os.replace(
            temporary_path,
            path,
        )

    except OSError as exc:
        if (
            temporary_path is not None
            and temporary_path.exists()
        ):
            try:
                temporary_path.unlink()
            except OSError:
                pass

        raise PersistenceError(
            f"Could not save {path}"
        ) from exc



