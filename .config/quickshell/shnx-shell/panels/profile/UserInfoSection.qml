import QtQuick
import QtQuick.Layouts
import qs.core as Core
import qs.theme as ShellTheme

Item {
    id: root

    implicitWidth: 210
    implicitHeight: infoColumn.implicitHeight

    readonly property var profile:
        Core.ServiceRegistry.profile

    ColumnLayout {
        id: infoColumn

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        spacing: 5


        Text {
            Layout.fillWidth: true

            text: (root.profile && (root.profile.displayNameLabel || root.profile.effectiveDisplayName || root.profile.displayName)) ? (root.profile.displayNameLabel || root.profile.effectiveDisplayName || root.profile.displayName) : ""
            color: ShellTheme.Theme.colors.on_surface

            font.pixelSize: ShellTheme.Theme.typography.headlineSmall
            font.weight: Font.DemiBold

            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true

            text: (root.profile && root.profile.usernameLabel) ? root.profile.usernameLabel : ""
            color: ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize: ShellTheme.Theme.typography.bodySmall
            elide: Text.ElideRight
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 5
        }

        InfoRow {
            iconText: "󰌢"
            valueText: (root.profile && root.profile.hostnameLabel) ? root.profile.hostnameLabel : ""
        }

        InfoRow {
            iconText: "󰣇"
            valueText: (root.profile && root.profile.distributionLabel) ? root.profile.distributionLabel : ""
        }

        InfoRow {
            iconText: ""
            valueText: (root.profile && root.profile.sessionLabel) ? root.profile.sessionLabel : ""
        }

        InfoRow {
            iconText: "󰌽"
            valueText: (root.profile && root.profile.kernelLabel) ? root.profile.kernelLabel : ""
        }

        InfoRow {
            iconText: "󰔛"
            valueText: (root.profile && root.profile.uptimeLabel) ? root.profile.uptimeLabel : ""
        }
    }

    component InfoRow: RowLayout {
        property string iconText: ""
        property string valueText: ""

        Layout.fillWidth: true
        spacing: 8

        Text {
            Layout.preferredWidth: 18

            text: parent.iconText
            color: ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize: ShellTheme.Theme.typography.bodySmall
            font.family: "JetBrainsMono Nerd Font"

            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.fillWidth: true

            text: parent.valueText
            color: ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize: ShellTheme.Theme.typography.labelMedium

            elide: Text.ElideRight
        }
    }
}
