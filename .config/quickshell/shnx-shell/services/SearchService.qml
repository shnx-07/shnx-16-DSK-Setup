import QtQuick
import Quickshell

QtObject {
    id: root

    property string query: ""
    property string selectedCategory: "All"

    readonly property var applications:
        DesktopEntries.applications.values

    readonly property var categories: [
        "All",
        "Internet",
        "Development",
        "Multimedia",
        "Graphics",
        "Office",
        "System",
        "Utilities"
    ]

    readonly property var filteredApplications:
        buildFilteredApplications()

    function buildFilteredApplications() {
        const normalizedQuery =
            root.query.trim().toLowerCase()

        const results =
            root.applications
                .filter(function(entry) {
                    if (!entry)
                        return false

                    if (!root.matchesCategory(entry))
                        return false

                    if (normalizedQuery.length === 0)
                        return true

                    return root.searchScore(
                        entry,
                        normalizedQuery
                    ) > 0
                })
                .map(function(entry) {
                    return {
                        entry: entry,
                        score: root.searchScore(
                            entry,
                            normalizedQuery
                        ),
                        name: entry.name || "",
                        icon: entry.icon || "",
                        comment:
                            entry.genericName
                            || entry.comment
                            || "",
                        desktopId: entry.id || "",
                        category:
                            root.displayCategory(entry)
                    }
                })

        results.sort(function(left, right) {
            if (normalizedQuery.length > 0
                    && left.score !== right.score) {
                return right.score - left.score
            }

            return left.name.localeCompare(
                right.name
            )
        })

        return results
    }

    function matchesCategory(entry) {
        if (root.selectedCategory === "All")
            return true

        const entryCategories =
            entry.categories || []

        for (let index = 0;
                index < entryCategories.length;
                index++) {
            if (root.categoryMatches(
                    root.selectedCategory,
                    String(entryCategories[index]))) {
                return true
            }
        }

        return false
    }

    function categoryMatches(
        requestedCategory,
        desktopCategory
    ) {
        switch (requestedCategory) {
        case "Internet":
            return [
                "Network",
                "WebBrowser",
                "Email",
                "InstantMessaging"
            ].includes(desktopCategory)

        case "Development":
            return [
                "Development",
                "IDE",
                "TextEditor"
            ].includes(desktopCategory)

        case "Multimedia":
            return [
                "AudioVideo",
                "Audio",
                "Video",
                "Player",
                "Recorder"
            ].includes(desktopCategory)

        case "Graphics":
            return [
                "Graphics",
                "Photography",
                "Viewer"
            ].includes(desktopCategory)

        case "Office":
            return [
                "Office",
                "WordProcessor",
                "Spreadsheet",
                "Presentation"
            ].includes(desktopCategory)

        case "System":
            return [
                "System",
                "Settings",
                "Security"
            ].includes(desktopCategory)

        case "Utilities":
            return [
                "Utility",
                "FileManager",
                "TerminalEmulator",
                "Archiving"
            ].includes(desktopCategory)
        }

        return false
    }

    function displayCategory(entry) {
        const entryCategories =
            entry.categories || []

        const orderedCategories = [
            "Internet",
            "Development",
            "Multimedia",
            "Graphics",
            "Office",
            "System",
            "Utilities"
        ]

        for (let requestedIndex = 0;
                requestedIndex < orderedCategories.length;
                requestedIndex++) {
            const requestedCategory =
                orderedCategories[requestedIndex]

            for (let entryIndex = 0;
                    entryIndex < entryCategories.length;
                    entryIndex++) {
                if (root.categoryMatches(
                        requestedCategory,
                        String(entryCategories[entryIndex]))) {
                    return requestedCategory
                }
            }
        }

        return "Other"
    }

    function searchScore(entry, normalizedQuery) {
        if (normalizedQuery.length === 0)
            return 1

        const name =
            String(entry.name || "").toLowerCase()

        const genericName =
            String(entry.genericName || "").toLowerCase()

        const comment =
            String(entry.comment || "").toLowerCase()

        const desktopId =
            String(entry.id || "").toLowerCase()

        const keywords =
            entry.keywords || []

        if (name === normalizedQuery)
            return 1000

        if (name.startsWith(normalizedQuery))
            return 700

        if (name.includes(normalizedQuery))
            return 500

        if (genericName.includes(normalizedQuery))
            return 300

        if (desktopId.includes(normalizedQuery))
            return 240

        for (let index = 0;
                index < keywords.length;
                index++) {
            const keyword =
                String(keywords[index]).toLowerCase()

            if (keyword.includes(normalizedQuery))
                return 200
        }

        if (comment.includes(normalizedQuery))
            return 100

        return root.subsequenceScore(
            name,
            normalizedQuery
        )
    }

    function subsequenceScore(text, pattern) {
        let textIndex = 0
        let patternIndex = 0
        let consecutive = 0
        let bestConsecutive = 0

        while (textIndex < text.length
                && patternIndex < pattern.length) {
            if (text[textIndex] === pattern[patternIndex]) {
                patternIndex++
                consecutive++

                bestConsecutive =
                    Math.max(
                        bestConsecutive,
                        consecutive
                    )
            } else {
                consecutive = 0
            }

            textIndex++
        }

        if (patternIndex !== pattern.length)
            return 0

        return 20
            + bestConsecutive * 4
            - Math.max(
                0,
                text.length - pattern.length
            ) * 0.1
    }

    function setQuery(value) {
        root.query = value || ""
    }

    function setCategory(value) {
        root.selectedCategory =
            value && value.length > 0
                ? value
                : "All"
    }

    function launch(entry) {
        if (entry)
            entry.execute()
    }
}
