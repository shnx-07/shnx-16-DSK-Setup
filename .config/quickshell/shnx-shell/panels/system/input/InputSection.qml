import QtQuick

import qs.core as Core
import qs.theme as ShellTheme

import "../../../components/layout" as Layout

Item {
    id: root

    readonly property var inputService:
        Core.ServiceRegistry.input

    implicitHeight:
        contentColumn.implicitHeight

    Column {
        id: contentColumn

        width:
            parent.width

        spacing:
            ShellTheme.Theme.spacing.large

        Column {
            width:
                parent.width

            spacing: 3

            Text {
                text:
                    "Input"

                color:
                    ShellTheme.Theme.colors.on_surface

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.titleMedium

                font.weight:
                    ShellTheme.Theme.typography.weightSemiBold
            }

            Text {
                width:
                    parent.width

                text:
                    root.inputService.ready
                        ? "Pointer and acceleration settings"
                        : "Loading input settings…"

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodySmall

                opacity: 0.72
            }
        }

        PointerSensitivity {
            width:
                parent.width

            inputService:
                root.inputService
        }

        Layout.Divider {
            width:
                parent.width
        }

        AccelerationSelector {
            width:
                parent.width

            inputService:
                root.inputService
        }
    }

    Component.onCompleted: {
        if (
            root.inputService
            && !root.inputService.ready
        ) {
            root.inputService.refresh()
        }
    }
}
