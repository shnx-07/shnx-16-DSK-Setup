import QtQuick

import qs.theme as ShellTheme
import "../../components/controls" as Controls

Item {
    id: root

    /*
     * Nullable on purpose. This lets the new module exist safely before
     * ServiceRegistry wiring is added.
     */
    property var searchService: null
    property string mode: "universal"

    property int selectedIndex: -1

    signal closeRequested()
    signal resultLaunched(var result)

    readonly property var appResults: {
        if (!root.searchService)
            return []

        const source = root.searchService.filteredApplications || []
        const limit = Math.min(source.length, 8)
        const mapped = []

        for (let index = 0; index < limit; index++) {
            const item = source[index]

            mapped.push({
                type: "application",
                name: item.name || "",
                comment: item.comment || "",
                icon: item.icon || "",
                entry: item.entry,
                score: item.score || 0
            })
        }

        return mapped
    }
    
    readonly property var fileResults: {
        if (!root.searchService)
            return []

        const source =
            root.searchService.filesystemResults || []

        const mapped = []

        for (let index = 0;
                index < source.length;
                index++) {
            const item = source[index]

            mapped.push({
                type: item.type || "file",
                name: item.name || "",
                comment: item.path || "",
                path: item.path || "",
                icon:
                    item.type === "folder"
                        ? "folder"
                        : "text-x-generic"
            })
        }

        return mapped
    }
    

    readonly property var visibleResults: {
        if (root.mode === "command")
            return []

        const combined = []

        for (let index = 0;
                index < root.appResults.length;
                index++) {
            combined.push(
                root.appResults[index]
            )
        }

        for (let index = 0;
                index < root.fileResults.length;
                index++) {
            combined.push(
                root.fileResults[index]
            )
        }

        return combined
    }
    onVisibleResultsChanged:
        normalizeSelection()

    onModeChanged: {
        selectedIndex = -1
        searchField.clear()
        Qt.callLater(searchField.activate)
    }

    Column {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Controls.SearchField {
            id: searchField

            width: parent.width
            captureHorizontalNavigation: false
            captureVerticalNavigation: true

            leadingGlyph:
                root.mode === "command"
                    ? "󰆍"
                    : "󰍉"

            placeholderText:
              root.mode === "command"
                  ? "Type a command..."
                  : "Search apps, files and folders..."
            onTextChanged: {
                if (root.searchService
                        && root.searchService.setQuery)
                    root.searchService.setQuery(text)

                root.selectedIndex = -1
            }

            onMoveUpRequested:
                root.moveSelection(-1)

            onMoveDownRequested:
                root.moveSelection(1)

            onSubmitted:
                root.activateSelected()

            onEscapeRequested:
                root.closeRequested()

            onCleared: {
                if (root.searchService
                        && root.searchService.setQuery)
                    root.searchService.setQuery("")

                root.selectedIndex = -1
            }
        }

        onVisibleChanged: {
            if (visible)
                searchField.forceInputFocus()
        }

        Rectangle {
            width: parent.width
            height: 1
            color: ShellTheme.Theme.colors.outlineVariant
        }

        Row {
            width: parent.width
            height: 18

            Text {
                text:
                    root.mode === "command"
                        ? "Commands"
                        : searchField.text.length > 0
                            ? "Applications"
                            : "Applications"

                color: ShellTheme.Theme.colors.on_surface_variant
                font.pixelSize: ShellTheme.Theme.typography.labelSmall
                font.weight: Font.DemiBold
            }

            Item {
                width: Math.max(0, parent.width - resultCount.width - 90)
                height: 1
            }

            Text {
                id: resultCount
                text:
                    root.visibleResults.length > 0
                        ? String(root.visibleResults.length)
                        : ""
                color: ShellTheme.Theme.colors.on_surface_variant
                font.pixelSize: ShellTheme.Theme.typography.labelSmall
            }
        }

        SearchResults {
            id: searchResults

            width: parent.width
            height:
                Math.max(
                    0,
                    parent.height
                    - searchField.height
                    - 12
                    - 1
                    - 12
                    - 18
                )

            results: root.visibleResults
            selectedIndex: root.selectedIndex
            query: searchField.text
            mode: root.mode

            onSelectionRequested: function(index) {
                root.selectedIndex = index
            }

            onResultActivated: function(index, result) {
                root.selectedIndex = index
                root.activateSelected()
            }
        }
    }

    function activate() {
        searchField.activate()
    }

    function clear() {
        searchField.clear()
        selectedIndex = -1
    }

    function moveSelection(direction) {
        const count = root.visibleResults.length

        if (count <= 0) {
            selectedIndex = -1
            return
        }

        if (selectedIndex < 0) {
            selectedIndex = direction < 0
                ? count - 1
                : 0
            return
        }

        selectedIndex =
            (selectedIndex + direction + count) % count
    }

    function normalizeSelection() {
        const count = root.visibleResults.length

        if (count <= 0) {
            selectedIndex = -1
            return
        }

        if (selectedIndex >= count)
            selectedIndex = count - 1
    }

    function activateSelected() {
      /*
      * Command mode
      */
      if (root.mode === "command") {
          const command =
              String(searchField.text || "").trim()

          if (command.length === 0)
              return

          if (
              root.searchService
              && root.searchService.runCommand
          ) {
              root.searchService.runCommand(
                  command
              )

              root.closeRequested()
          }

          return
      }

      /*
      * Universal search mode
      */
      const count =
          root.visibleResults.length

      if (count <= 0)
          return

      const index =
          selectedIndex >= 0
              ? selectedIndex
              : 0

      const result =
          root.visibleResults[index]

      if (!result)
          return

      /*
      * Application
      */
      if (
          result.type === "application"
          && result.entry
          && root.searchService
          && root.searchService.launch
      ) {
          root.searchService.launch(
              result.entry
          )

          root.resultLaunched(result)
          root.closeRequested()
          return
      }

      /*
      * File / folder
      */
      if (
          (
              result.type === "file"
              || result.type === "folder"
          )
          && result.path
          && root.searchService
          && root.searchService.openPath
      ) {
          root.searchService.openPath(
              result.path
          )

          root.resultLaunched(result)
          root.closeRequested()
      }
  }
}
