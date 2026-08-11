from __future__ import annotations

import asyncio
import bisect
import os
import time
from dataclasses import dataclass, field
from pathlib import Path


class SearchError(Exception):
    """Raised when filesystem search cannot be completed."""


@dataclass(slots=True)
class _Entry:
    name: str
    name_cf: str
    type: str  # "file" | "folder"
    path: str


@dataclass(frozen=True, slots=True)
class _IndexSnapshot:
    """Immutable point-in-time view of the index. Readers always see
    either a fully-old or fully-new snapshot, never a torn mix of
    entries from one build paired with lookup tables from another."""

    entries: list[_Entry]
    sorted_names: list[tuple[str, int]]  # (casefolded name, entry index), sorted
    by_name: dict[str, list[int]]        # casefolded name -> entry indices
    built_at: float


class _FileIndex:
    """In-memory index of the home directory tree. Once built, search()
    never touches disk - it's a dict lookup plus two in-memory scans."""

    def __init__(
        self,
        home: Path,
        skip_names: set[str],
        skip_markers: tuple[str, ...],
    ) -> None:
        self._home = home
        self._skip_names = skip_names
        self._skip_markers = skip_markers
        self._snapshot: _IndexSnapshot | None = None

    @property
    def snapshot(self) -> _IndexSnapshot | None:
        return self._snapshot

    def build(self) -> None:
        """Blocking full rebuild - run via asyncio.to_thread. Builds a
        complete new snapshot, then swaps it in with a single atomic
        attribute assignment."""
        entries: list[_Entry] = []
        stack = [str(self._home)]

        while stack:
            current = stack.pop()

            try:
                with os.scandir(current) as it:
                    for de in it:
                        try:
                            is_dir = de.is_dir(follow_symlinks=False)
                        except OSError:
                            continue

                        if is_dir:
                            if self._should_skip(current, de.name):
                                continue
                            stack.append(de.path)
                            entries.append(
                                _Entry(de.name, de.name.casefold(), "folder", de.path)
                            )
                        else:
                            entries.append(
                                _Entry(de.name, de.name.casefold(), "file", de.path)
                            )
            except OSError:
                continue

        sorted_names = sorted(
            ((entry.name_cf, index) for index, entry in enumerate(entries)),
            key=lambda pair: pair[0],
        )

        by_name: dict[str, list[int]] = {}
        for index, entry in enumerate(entries):
            by_name.setdefault(entry.name_cf, []).append(index)

        self._snapshot = _IndexSnapshot(
            entries=entries,
            sorted_names=sorted_names,
            by_name=by_name,
            built_at=time.monotonic(),
        )

    def _should_skip(self, current_root: str, directory: str) -> bool:
        if directory in self._skip_names:
            return True
        candidate = f"{current_root}/{directory}"
        return any(marker in candidate for marker in self._skip_markers)

    def search(
        self,
        snapshot: _IndexSnapshot,
        query_cf: str,
        limit: int,
        overcollect: int,
    ) -> list[dict]:
        exact_idx = snapshot.by_name.get(query_cf, [])
        exact_set = set(exact_idx)

        # Prefix match: binary search into the sorted name list instead
        # of scanning everything - O(log n + k) instead of O(n).
        lo = bisect.bisect_left(snapshot.sorted_names, (query_cf,))
        prefix_idx: list[int] = []
        i = lo
        while i < len(snapshot.sorted_names) and snapshot.sorted_names[i][0].startswith(query_cf):
            name_cf, idx = snapshot.sorted_names[i]
            if idx not in exact_set:
                prefix_idx.append(idx)
            i += 1
        prefix_set = set(prefix_idx)

        # Substring match: only needed if exact+prefix didn't already
        # give us plenty. This is an in-memory scan (no disk I/O), so
        # even over a few hundred thousand entries it's milliseconds.
        contains_idx: list[int] = []
        if len(exact_idx) + len(prefix_idx) < overcollect:
            for index, entry in enumerate(snapshot.entries):
                if index in exact_set or index in prefix_set:
                    continue
                if query_cf in entry.name_cf:
                    contains_idx.append(index)
                    if len(contains_idx) >= overcollect:
                        break

        def to_result(index: int) -> dict:
            e = snapshot.entries[index]
            return {"type": e.type, "name": e.name, "path": e.path}

        exact = sorted((to_result(i) for i in exact_idx), key=lambda r: r["name"].casefold())
        prefix = sorted((to_result(i) for i in prefix_idx), key=lambda r: r["name"].casefold())
        contains = sorted((to_result(i) for i in contains_idx), key=lambda r: r["name"].casefold())

        return (exact + prefix + contains)[:limit]


class SearchService:
    DEFAULT_LIMIT = 20
    MAX_LIMIT = 100
    MAX_VISITED_ENTRIES = 50_000
    OVERCOLLECT_FACTOR = 5
    FD_TIMEOUT_SECONDS = 2.0

    # How stale the in-memory index is allowed to get before a
    # background rebuild is triggered. Rebuilds never block a query -
    # this just bounds how out-of-date results can be.
    INDEX_REFRESH_INTERVAL = 20.0

    _SKIPPED_NAMES = {
        ".cache",
        ".git",
        "node_modules",
        "__pycache__",
        ".venv",
        "venv",
        ".idea",
        ".vscode",
        "dist",
        "build",
    }

    _SKIPPED_SUBPATH_MARKERS = (
        "/.local/share/Trash",
    )

    def __init__(self) -> None:
        self._home = Path.home()
        self._home_str = str(self._home)
        self._fd_available: bool | None = None
        self._index = _FileIndex(self._home, self._SKIPPED_NAMES, self._SKIPPED_SUBPATH_MARKERS)
        self._index_building = False

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    async def search_files(
        self,
        query: str,
        limit: int = DEFAULT_LIMIT,
    ) -> dict:
        query = query.strip()

        if not query:
            return {"query": "", "results": []}

        limit = min(max(1, limit), self.MAX_LIMIT)
        normalized_query = query.casefold()

        snapshot = self._index.snapshot

        if snapshot is not None:
            # Instant path: pure in-memory lookup, no disk I/O at all.
            results = self._index.search(
                snapshot, normalized_query, limit, limit * self.OVERCOLLECT_FACTOR
            )
            self._maybe_refresh_index(snapshot)
            return {"query": query, "results": results}

        # First-ever call (or index not built yet): answer via fd/walk,
        # and kick off the initial index build in the background so
        # future calls become instant.
        self._maybe_refresh_index(None)

        try:
            results = await self._search_with_fd(query, limit)

            if results is None:
                results = await asyncio.to_thread(self._search_sync, query, limit)

        except OSError as error:
            raise SearchError(f"Filesystem search failed: {error}") from error

        return {"query": query, "results": results}

    def _maybe_refresh_index(self, snapshot: _IndexSnapshot | None) -> None:
        if self._index_building:
            return

        stale = (
            snapshot is None
            or (time.monotonic() - snapshot.built_at) > self.INDEX_REFRESH_INTERVAL
        )

        if not stale:
            return

        self._index_building = True

        async def _run() -> None:
            try:
                await asyncio.to_thread(self._index.build)
            finally:
                self._index_building = False

        asyncio.ensure_future(_run())

    # ------------------------------------------------------------------
    # Fast path: shell out to `fd` (used only until the index is ready)
    # ------------------------------------------------------------------

    async def _search_with_fd(
        self,
        query: str,
        limit: int,
    ) -> list[dict] | None:
        if self._fd_available is False:
            return None

        try:
            process = await asyncio.create_subprocess_exec(
                "fd",
                "--hidden",
                "--ignore-case",
                "--type", "f",
                "--type", "d",
                "--max-results", str(limit * self.OVERCOLLECT_FACTOR),
                "--exclude", ".git",
                "--exclude", "node_modules",
                "--exclude", "__pycache__",
                "--exclude", ".cache",
                "--exclude", ".venv",
                "--",
                query,
                self._home_str,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.DEVNULL,
            )
        except FileNotFoundError:
            self._fd_available = False
            return None

        try:
            stdout, _ = await asyncio.wait_for(
                process.communicate(), timeout=self.FD_TIMEOUT_SECONDS
            )
        except asyncio.TimeoutError:
            process.kill()
            return None

        if process.returncode not in (0, 1):
            self._fd_available = False
            return None

        self._fd_available = True

        normalized_query = query.casefold()
        exact_matches: list[dict] = []
        prefix_matches: list[dict] = []
        contains_matches: list[dict] = []

        for line in stdout.decode(errors="ignore").splitlines():
            if not line:
                continue

            path = Path(line)
            result_type = "folder" if line.endswith(os.sep) else "file"

            self._consider_path(
                path, result_type, normalized_query,
                exact_matches, prefix_matches, contains_matches,
            )

        return self._combine_results(exact_matches, prefix_matches, contains_matches, limit)

    # ------------------------------------------------------------------
    # Fallback path: pure-Python walk (used only if fd is unavailable
    # AND the index hasn't finished its first build yet)
    # ------------------------------------------------------------------

    def _search_sync(self, query: str, limit: int) -> list[dict]:
        normalized_query = query.casefold()

        exact_matches: list[dict] = []
        prefix_matches: list[dict] = []
        contains_matches: list[dict] = []

        visited = 0
        overcollect_target = limit * self.OVERCOLLECT_FACTOR

        for current_root, directories, files in os.walk(
            self._home, topdown=True, followlinks=False
        ):
            directories[:] = [
                d for d in directories if not self._should_skip_directory(current_root, d)
            ]

            for directory in directories:
                visited += 1
                self._consider_path(
                    Path(current_root) / directory, "folder", normalized_query,
                    exact_matches, prefix_matches, contains_matches,
                )

            for filename in files:
                visited += 1
                self._consider_path(
                    Path(current_root) / filename, "file", normalized_query,
                    exact_matches, prefix_matches, contains_matches,
                )

            total = len(exact_matches) + len(prefix_matches) + len(contains_matches)

            if total >= overcollect_target or visited > self.MAX_VISITED_ENTRIES:
                break

        return self._combine_results(exact_matches, prefix_matches, contains_matches, limit)

    def _should_skip_directory(self, current_root: str, directory: str) -> bool:
        if directory in self._SKIPPED_NAMES:
            return True
        candidate = f"{current_root}/{directory}"
        return any(
            candidate.endswith(marker) or marker in candidate
            for marker in self._SKIPPED_SUBPATH_MARKERS
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
        result = {"type": result_type, "name": name, "path": str(path)}

        if normalized_name == query:
            exact_matches.append(result)
        elif normalized_name.startswith(query):
            prefix_matches.append(result)
        elif query in normalized_name:
            contains_matches.append(result)

    def _combine_results(
        self,
        exact_matches: list[dict],
        prefix_matches: list[dict],
        contains_matches: list[dict],
        limit: int,
    ) -> list[dict]:
        exact_matches.sort(key=lambda item: item["name"].casefold())
        prefix_matches.sort(key=lambda item: item["name"].casefold())
        contains_matches.sort(key=lambda item: item["name"].casefold())
        return (exact_matches + prefix_matches + contains_matches)[:limit]

    # ------------------------------------------------------------------
    # Unrelated helpers (unchanged)
    # ------------------------------------------------------------------

    async def open_path(self, path: str) -> dict:
        target = Path(path).expanduser()

        if not target.exists():
            raise SearchError(f"Path does not exist: {target}")

        process = await asyncio.create_subprocess_exec(
            "xdg-open", str(target),
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
            start_new_session=True,
        )
        return {"path": str(target), "pid": process.pid}

    async def run_command(self, command: str) -> dict:
        command = command.strip()

        if not command:
            raise SearchError("Command cannot be empty.")

        process = await asyncio.create_subprocess_shell(
            command,
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
            start_new_session=True,
        )
        return {"command": command, "pid": process.pid}
