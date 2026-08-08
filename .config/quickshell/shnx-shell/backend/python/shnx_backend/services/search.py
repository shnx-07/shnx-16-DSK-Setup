from __future__ import annotations

import asyncio
import os
from pathlib import Path


class SearchError(Exception):
    """Raised when filesystem search cannot be completed."""


class SearchService:
    DEFAULT_LIMIT = 20
    MAX_LIMIT = 100
    MAX_VISITED_ENTRIES = 50_000

    _SKIPPED_DIRECTORIES = {
        ".cache",
        ".git",
        ".local/share/Trash",
        "node_modules",
        "__pycache__",
    }

    def __init__(self) -> None:
        self._home = Path.home()

    async def search_files(
        self,
        query: str,
        limit: int = DEFAULT_LIMIT,
    ) -> dict:
        query = query.strip()

        if not query:
            return {
                "query": "",
                "results": [],
            }

        limit = min(
            max(1, limit),
            self.MAX_LIMIT,
        )

        try:
            results = await asyncio.to_thread(
                self._search_sync,
                query,
                limit,
            )

        except OSError as error:
            raise SearchError(
                f"Filesystem search failed: {error}"
            ) from error

        return {
            "query": query,
            "results": results,
        }

    def _search_sync(
        self,
        query: str,
        limit: int,
    ) -> list[dict]:
        normalized_query = query.casefold()

        exact_matches: list[dict] = []
        prefix_matches: list[dict] = []
        contains_matches: list[dict] = []

        visited = 0

        for current_root, directories, files in os.walk(
            self._home,
            topdown=True,
            followlinks=False,
        ):
            root_path = Path(current_root)

            directories[:] = [
                directory
                for directory in directories
                if not self._should_skip_directory(
                    root_path / directory
                )
            ]

            for directory in directories:
                visited += 1

                if visited > self.MAX_VISITED_ENTRIES:
                    return self._combine_results(
                        exact_matches,
                        prefix_matches,
                        contains_matches,
                        limit,
                    )

                self._consider_path(
                    root_path / directory,
                    "folder",
                    normalized_query,
                    exact_matches,
                    prefix_matches,
                    contains_matches,
                )

            for filename in files:
                visited += 1

                if visited > self.MAX_VISITED_ENTRIES:
                    return self._combine_results(
                        exact_matches,
                        prefix_matches,
                        contains_matches,
                        limit,
                    )

                self._consider_path(
                    root_path / filename,
                    "file",
                    normalized_query,
                    exact_matches,
                    prefix_matches,
                    contains_matches,
                )

        return self._combine_results(
            exact_matches,
            prefix_matches,
            contains_matches,
            limit,
        )

    def _consider_path(
        self,
        path: Path,
        result_type: str,
        query: str,
        exact_matches: list[dict],
        prefix_matches: list[dict],
        contains_matches: list[dict],
    ) -> None:
        name = path.name
        normalized_name = name.casefold()

        result = {
            "type": result_type,
            "name": name,
            "path": str(path),
        }

        if normalized_name == query:
            exact_matches.append(result)
            return

        if normalized_name.startswith(query):
            prefix_matches.append(result)
            return

        if query in normalized_name:
            contains_matches.append(result)

    def _combine_results(
        self,
        exact_matches: list[dict],
        prefix_matches: list[dict],
        contains_matches: list[dict],
        limit: int,
    ) -> list[dict]:
        exact_matches.sort(
            key=lambda item: item["name"].casefold()
        )

        prefix_matches.sort(
            key=lambda item: item["name"].casefold()
        )

        contains_matches.sort(
            key=lambda item: item["name"].casefold()
        )

        return (
            exact_matches
            + prefix_matches
            + contains_matches
        )[:limit]

    def _should_skip_directory(
        self,
        path: Path,
    ) -> bool:
        try:
            relative = path.relative_to(
                self._home
            )

        except ValueError:
            return False

        relative_text = relative.as_posix()

        if relative_text in self._SKIPPED_DIRECTORIES:
            return True

        if path.name in {
            ".cache",
            ".git",
            "node_modules",
            "__pycache__",
        }:
            return True

        return False


    async def open_path(
        self,
        path: str,
    ) -> dict:
        target = Path(path).expanduser()

        if not target.exists():
            raise SearchError(
                f"Path does not exist: {target}"
            )

        process = await asyncio.create_subprocess_exec(
            "xdg-open",
            str(target),
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
            start_new_session=True,
        )

        return {
            "path": str(target),
            "pid": process.pid,
        }

    async def run_command(
        self,
        command: str,
    ) -> dict:
        command = command.strip()

        if not command:
            raise SearchError(
                "Command cannot be empty."
            )

        process = await asyncio.create_subprocess_shell(
            command,
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
            start_new_session=True,
        )

        return {
            "command": command,
            "pid": process.pid,
        }
