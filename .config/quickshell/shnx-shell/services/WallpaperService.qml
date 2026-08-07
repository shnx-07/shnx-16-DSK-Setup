
import QtQuick
import qs.core as Core

QtObject {
    id: root

    /*
     * Wallpaper library state.
     *
     * Every entry can contain:
     *
     * {
     *   id: "...",
     *   path: "/home/.../wallpaper.jpg",
     *   name: "wallpaper.jpg",
     *   type: "static" | "gif" | "video",
     *   preview: "/home/.../.cache/.../preview.png",
     *   sourceFolder: "/home/.../Pictures/Wallpapers",
     *   extension: ".jpg",
     *   size: 123456,
     *   modified: 123456789
     * }
     *
     * The carousel must use preview, never the original media file.
     */
    property var library: []

    /*
     * User wallpaper folders.
     *
     * Actual media stays outside ~/.config.
     */
    property var sourceFolders: [
        "~/Pictures/Wallpapers"
    ]

    /*
     * Carousel selection and actual desktop wallpaper are deliberately
     * separate states.
     */
    property var selectedWallpaper: null
    property var currentWallpaper: null
    property var previousWallpaper: null

    /*
     * Backend operation state.
     */
    property bool loading: false
    property bool refreshing: false
    property bool applying: false
    property bool previewsLoading: false

    /*
     * Each apply request remembers the wallpaper it belongs to.
     *
     * This keeps the apply result correct even when the user continues
     * browsing the carousel while the backend is changing the desktop.
     */
    property string pendingApplyRequestId: ""
    property var pendingApplyWallpaper: null

    property string pendingScanRequestId: ""
    property string pendingRefreshRequestId: ""
    property string pendingPreviewsRequestId: ""

    property string lastError: ""
    property string lastApplyError: ""
    property string lastPreviewError: ""

    /*
     * Carousel preview size.
     *
     * These are backend cache dimensions, not necessarily the exact
     * rendered card size.
     */
    property int previewWidth: 640
    property int previewHeight: 360
    property int previewConcurrency: 2

    /*
     * Desktop wallpaper transition preference.
     *
     * This is only a policy value sent to wallpaper.py.
     *
     * QML does NOT choose the concrete random transition.
     * Python owns:
     *
     *   - random selection
     *   - immediate-repeat avoidance
     *   - actual awww transition execution
     *
     * Shared motion/ files remain responsible only for QML UI motion.
     */
    property string transitionMode: "random"

    readonly property bool backendAvailable:
        Core.ServiceRegistry.backend
        && Core.ServiceRegistry.backend.online

    readonly property int wallpaperCount:
        library ? library.length : 0

    readonly property bool hasWallpapers:
        wallpaperCount > 0

    readonly property bool hasSelection:
        selectedWallpaper !== null

    readonly property bool hasCurrentWallpaper:
        currentWallpaper !== null


    /*
     * Signals consumed later by UI and ThemeService.
     */
    signal libraryChangedByBackend()
    signal previewsChanged()

    signal selectionChanged(var wallpaper)

    signal wallpaperApplyStarted(var wallpaper)
    signal wallpaperApplied(var wallpaper)
    signal wallpaperApplyFailed(
        var wallpaper,
        string errorMessage
    )

    signal backendUnavailable()


    /*
     * ------------------------------------------------------------
     * Selection
     * ------------------------------------------------------------
     */

    function selectWallpaper(wallpaper) {
        if (!wallpaper)
            return false

        if (selectedWallpaper === wallpaper)
            return true

        selectedWallpaper = wallpaper

        selectionChanged(
            wallpaper
        )

        return true
    }


    function applySelectedWallpaper() {
        if (!selectedWallpaper)
            return false

        return applyWallpaper(
            selectedWallpaper
        )
    }


    /*
     * ------------------------------------------------------------
     * Wallpaper apply
     * ------------------------------------------------------------
     */

    function applyWallpaper(wallpaper) {
        if (!wallpaper)
            return false

        if (applying)
            return false

        if (!backendAvailable) {
            lastApplyError =
                "Wallpaper backend is unavailable."

            backendUnavailable()

            wallpaperApplyFailed(
                wallpaper,
                lastApplyError
            )

            return false
        }

        const path =
            wallpaper.path !== undefined
                ? wallpaper.path
                : ""

        if (!path || path.length === 0) {
            lastApplyError =
                "Wallpaper has no valid file path."

            wallpaperApplyFailed(
                wallpaper,
                lastApplyError
            )

            return false
        }

        lastApplyError = ""
        applying = true

        /*
         * Keep the last confirmed working wallpaper until the backend
         * confirms the new wallpaper has actually been applied.
         */
        previousWallpaper =
            currentWallpaper

        /*
         * Keep the exact wallpaper tied to this backend request.
         *
         * selectedWallpaper may change while the request is in flight
         * because carousel browsing remains available during apply.
         */
        pendingApplyWallpaper =
            wallpaper

        wallpaperApplyStarted(
            wallpaper
        )

        pendingApplyRequestId =
            Core.ServiceRegistry.backend.sendCommand(
                "wallpaper.apply",
                {
                    path: path,
                    transition: transitionMode
                }
            )

        if (!pendingApplyRequestId
                || pendingApplyRequestId.length === 0) {

            applying = false
            pendingApplyWallpaper = null

            lastApplyError =
                "Could not send wallpaper apply request."

            wallpaperApplyFailed(
                wallpaper,
                lastApplyError
            )

            return false
        }

        return true
    }


    /*
     * ------------------------------------------------------------
     * Library scan
     * ------------------------------------------------------------
     */

    function scanLibrary() {
        if (loading)
            return false

        if (!backendAvailable) {
            lastError =
                "Wallpaper backend is unavailable."

            backendUnavailable()

            return false
        }

        loading = true
        lastError = ""

        pendingScanRequestId =
            Core.ServiceRegistry.backend.sendCommand(
                "wallpaper.scan",
                {
                    folders: sourceFolders
                }
            )

        if (!pendingScanRequestId
                || pendingScanRequestId.length === 0) {

            loading = false

            lastError =
                "Could not send wallpaper scan request."

            return false
        }

        return true
    }


    /*
     * ------------------------------------------------------------
     * Library refresh
     * ------------------------------------------------------------
     */

    function refreshLibrary() {
        if (refreshing)
            return false

        if (!backendAvailable) {
            lastError =
                "Wallpaper backend is unavailable."

            backendUnavailable()

            return false
        }

        refreshing = true
        lastError = ""

        pendingRefreshRequestId =
            Core.ServiceRegistry.backend.sendCommand(
                "wallpaper.refresh",
                {
                    folders: sourceFolders
                }
            )

        if (!pendingRefreshRequestId
                || pendingRefreshRequestId.length === 0) {

            refreshing = false

            lastError =
                "Could not send wallpaper refresh request."

            return false
        }

        return true
    }


    /*
     * ------------------------------------------------------------
     * Preview loading
     * ------------------------------------------------------------
     */

    function requestLibraryPreviews() {
        if (!library || library.length === 0)
            return false

        if (previewsLoading)
            return false

        if (!backendAvailable) {
            lastPreviewError =
                "Wallpaper backend is unavailable."

            backendUnavailable()

            return false
        }

        const requests = []

        for (let index = 0;
             index < library.length;
             index++) {

            const wallpaper =
                library[index]

            if (!wallpaper)
                continue

            if (!wallpaper.path)
                continue

            /*
             * If this entry already has a preview, we can skip asking
             * the backend for it again during this QML lifetime.
             *
             * Backend cache validation still protects us after rescans.
             */
            if (wallpaper.preview
                    && wallpaper.preview.length > 0) {
                continue
            }

            requests.push({
                path: wallpaper.path,
                type: wallpaper.type
            })
        }

        if (requests.length === 0) {
            previewsChanged()
            return true
        }

        previewsLoading = true
        lastPreviewError = ""

        pendingPreviewsRequestId =
            Core.ServiceRegistry.backend.sendCommand(
                "wallpaper.previews",
                {
                    wallpapers: requests,
                    width: previewWidth,
                    height: previewHeight,
                    concurrency: previewConcurrency
                }
            )

        if (!pendingPreviewsRequestId
                || pendingPreviewsRequestId.length === 0) {

            previewsLoading = false

            lastPreviewError =
                "Could not send wallpaper preview request."

            return false
        }

        return true
    }


    /*
     * ------------------------------------------------------------
     * Lookup helpers
     * ------------------------------------------------------------
     */

    function wallpaperByPath(path) {
        if (!path || !library)
            return null

        for (let index = 0;
             index < library.length;
             index++) {

            const wallpaper =
                library[index]

            if (wallpaper
                    && wallpaper.path === path) {

                return wallpaper
            }
        }

        return null
    }


    function libraryIndexByPath(path) {
        if (!path || !library)
            return -1

        for (let index = 0;
             index < library.length;
             index++) {

            const wallpaper =
                library[index]

            if (wallpaper
                    && wallpaper.path === path) {

                return index
            }
        }

        return -1
    }


    /*
     * Merge backend preview results into library entries.
     *
     * We create new JS objects instead of mutating the original object
     * in place. This ensures QML observers reliably see the change.
     */
    function mergePreviewResults(results) {
        if (!results || results.length === 0)
            return

        const updatedLibrary =
            library.slice()

        let changed = false

        for (let resultIndex = 0;
             resultIndex < results.length;
             resultIndex++) {

            const result =
                results[resultIndex]

            if (!result)
                continue

            if (result.success !== true)
                continue

            if (!result.path
                    || !result.preview) {
                continue
            }

            const libraryIndex =
                libraryIndexByPath(
                    result.path
                )

            if (libraryIndex < 0)
                continue

            const oldWallpaper =
                updatedLibrary[libraryIndex]

            const updatedWallpaper = {}

            for (const key in oldWallpaper)
                updatedWallpaper[key] =
                    oldWallpaper[key]

            updatedWallpaper.preview =
                result.preview

            updatedWallpaper.previewCached =
                result.cached === true

            updatedLibrary[libraryIndex] =
                updatedWallpaper

            changed = true
        }

        if (!changed)
            return

        library =
            updatedLibrary

        /*
         * Reconnect selected/current references to the newly-created
         * library objects.
         */
        if (selectedWallpaper
                && selectedWallpaper.path) {

            const selected =
                wallpaperByPath(
                    selectedWallpaper.path
                )

            if (selected)
                selectedWallpaper =
                    selected
        }

        if (currentWallpaper
                && currentWallpaper.path) {

            const current =
                wallpaperByPath(
                    currentWallpaper.path
                )

            if (current)
                currentWallpaper =
                    current
        }

        previewsChanged()
        libraryChangedByBackend()
    }


    /*
     * ------------------------------------------------------------
     * Backend connections
     * ------------------------------------------------------------
     */

    property Connections backendConnections: Connections {
        target: Core.ServiceRegistry.backend

        function onOnlineChanged() {
            if (
                Core.ServiceRegistry.backend.online
                && root.library.length === 0
                && !root.loading
                && !root.refreshing
            ) {
                console.log(
                    "[WallpaperService] Backend online, scanning wallpaper library"
                )

                root.scanLibrary()
            }
        }


        function onResponseReceived(
            command,
            requestId,
            payload
        ) {
            if (command === "wallpaper.scan") {
                root.handleScanResponse(
                    requestId,
                    payload
                )

                return
            }

            if (command === "wallpaper.refresh") {
                root.handleRefreshResponse(
                    requestId,
                    payload
                )

                return
            }

            if (command === "wallpaper.previews") {
                root.handlePreviewsResponse(
                    requestId,
                    payload
                )

                return
            }

            if (command === "wallpaper.apply") {
                root.handleApplyResponse(
                    requestId,
                    payload
                )
            }
        }
    }


    /*
     * ------------------------------------------------------------
     * Scan response
     * ------------------------------------------------------------
     */

    function handleScanResponse(
        requestId,
        payload
    ) {
        if (requestId
                !== pendingScanRequestId) {

            return
        }

        pendingScanRequestId = ""
        loading = false

        if (!payload) {
            lastError =
                "Wallpaper scan returned no data."

            return
        }

        if (payload.wallpapers !== undefined)
            library = payload.wallpapers

        if (payload.folders !== undefined)
            sourceFolders = payload.folders

        if (payload.current !== undefined
                && payload.current) {

            const currentPath =
                payload.current.path !== undefined
                    ? payload.current.path
                    : payload.current

            const current =
                wallpaperByPath(
                    currentPath
                )

            currentWallpaper =
                current
                    ? current
                    : payload.current

            if (!selectedWallpaper)
                selectedWallpaper =
                    currentWallpaper
        }

        /*
         * First wallpaper becomes initial carousel selection when there
         * is no currently-applied wallpaper known to this service.
         */
        if (!selectedWallpaper
                && library.length > 0) {

            selectedWallpaper =
                library[0]

            selectionChanged(
                selectedWallpaper
            )
        }

        console.log(
            "[WallpaperService] Loaded",
            root.library.length,
            "wallpapers"
        )

        libraryChangedByBackend()

        /*
         * Scan stays lightweight. Preview generation begins only after
         * metadata is available.
         */
        requestLibraryPreviews()
    }


    /*
     * ------------------------------------------------------------
     * Refresh response
     * ------------------------------------------------------------
     */

    function handleRefreshResponse(
        requestId,
        payload
    ) {
        if (requestId
                !== pendingRefreshRequestId) {

            return
        }

        pendingRefreshRequestId = ""
        refreshing = false

        if (!payload) {
            lastError =
                "Wallpaper refresh returned no data."

            return
        }

        const selectedPath =
            selectedWallpaper
                && selectedWallpaper.path
                ? selectedWallpaper.path
                : ""

        const currentPath =
            currentWallpaper
                && currentWallpaper.path
                ? currentWallpaper.path
                : ""

        if (payload.wallpapers !== undefined)
            library = payload.wallpapers

        if (payload.folders !== undefined)
            sourceFolders = payload.folders

        if (selectedPath.length > 0) {
            const selected =
                wallpaperByPath(
                    selectedPath
                )

            selectedWallpaper =
                selected
                    ? selected
                    : null
        }

        if (currentPath.length > 0) {
            const current =
                wallpaperByPath(
                    currentPath
                )

            if (current)
                currentWallpaper =
                    current
        }

        if (!selectedWallpaper
                && library.length > 0) {

            selectedWallpaper =
                library[0]

            selectionChanged(
                selectedWallpaper
            )
        }

        libraryChangedByBackend()

        requestLibraryPreviews()
    }


    /*
     * ------------------------------------------------------------
     * Preview response
     * ------------------------------------------------------------
     */

    function handlePreviewsResponse(
        requestId,
        payload
    ) {
        if (requestId
                !== pendingPreviewsRequestId) {

            return
        }

        pendingPreviewsRequestId = ""
        previewsLoading = false

        if (!payload) {
            lastPreviewError =
                "Wallpaper preview request returned no data."

            return
        }

        const results =
            payload.previews !== undefined
                ? payload.previews
                : []

        let failedCount = 0

        for (let index = 0;
             index < results.length;
             index++) {

            if (!results[index]
                    || results[index].success !== true) {

                failedCount += 1
            }
        }

        if (failedCount > 0) {
            lastPreviewError =
                failedCount
                + " wallpaper preview(s) could not be generated."
        } else {
            lastPreviewError = ""
        }

        mergePreviewResults(
            results
        )

        console.log(
            "[WallpaperService] Loaded previews for",
            results.length - failedCount,
            "wallpapers"
        )
    }


    /*
     * ------------------------------------------------------------
     * Apply response
     * ------------------------------------------------------------
     */

    function handleApplyResponse(
        requestId,
        payload
    ) {
        if (requestId
                !== pendingApplyRequestId) {

            return
        }

        /*
         * Capture the wallpaper tied to this exact request before
         * clearing the pending state.
         */
        const requestedWallpaper =
            pendingApplyWallpaper

        pendingApplyRequestId = ""
        pendingApplyWallpaper = null
        applying = false

        if (!payload) {
            lastApplyError =
                "Wallpaper backend returned no result."

            wallpaperApplyFailed(
                requestedWallpaper,
                lastApplyError
            )

            return
        }

        if (payload.success !== true) {
            lastApplyError =
                payload.error !== undefined
                    ? String(payload.error)
                    : "Wallpaper application failed."

            /*
             * currentWallpaper intentionally remains unchanged.
             * Backend owns actual desktop rollback.
             */
            wallpaperApplyFailed(
                requestedWallpaper,
                lastApplyError
            )

            return
        }

        const appliedPath =
            payload.path !== undefined
                ? payload.path
                : (
                    requestedWallpaper
                        ? requestedWallpaper.path
                        : ""
                )

        const appliedWallpaper =
            wallpaperByPath(
                appliedPath
            )

        currentWallpaper =
            appliedWallpaper
                ? appliedWallpaper
                : requestedWallpaper

        /*
         * Keep existing first-pass behavior:
         * after a successful apply the carousel selection returns to
         * the confirmed current wallpaper.
         *
         * We can revisit this later during carousel UX polish.
         */
        selectedWallpaper =
            currentWallpaper

        previousWallpaper = null
        lastApplyError = ""

        /*
         * Successful wallpaper boundary.
         *
         * ThemeService / Matugen will later connect here.
         * WallpaperService itself never modifies Theme.
         */
        wallpaperApplied(
            currentWallpaper
        )
    }
}


