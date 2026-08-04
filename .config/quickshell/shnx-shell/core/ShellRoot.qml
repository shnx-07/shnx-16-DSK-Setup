import Quickshell
import qs.core as Core
import "../bar" as Bar
import "../panels/quicksettings" as QuickSettings

Scope {
    id: root

    Bar.Bar {}

    QuickSettings.QuickSettingsDetailPanel {
        id: quickSettingsDetailPanel
    }
}
