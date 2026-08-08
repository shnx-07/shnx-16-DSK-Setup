import QtQuick
import QtQuick.Layouts

import qs.core as Core
import qs.theme as ShellTheme

import "../../components/visual" as Visual

Item {
    id: root

    implicitWidth: 210
    implicitHeight:
        infoColumn.implicitHeight

    readonly property var profile:
        Core.ServiceRegistry.profile

    readonly property string displayName:
        root.profile
        ? (
            root.profile.displayNameLabel
            || root.profile.effectiveDisplayName
            || root.profile.displayName
            || ""
        )
        : ""

    readonly property string username:
        root.profile
        && root.profile.usernameLabel
            ? root.profile.usernameLabel
            : ""

    ColumnLayout {
        id: infoColumn

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        spacing:
            ShellTheme.Theme.spacing.xSmall

        /*
         * --------------------------------------------------------
         * USER IDENTITY
         * --------------------------------------------------------
         */

        Text {
            Layout.fillWidth: true

            text:
                root.displayName

            color:
                ShellTheme.Theme.colors.on_surface

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.headlineSmall

            font.weight:
                Font.DemiBold

            elide:
                Text.ElideRight
        }

        Text {
            Layout.fillWidth: true

            text:
                root.username

            color:
                ShellTheme.Theme.colors.on_surface_variant

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.bodySmall

            elide:
                Text.ElideRight
        }

        Item {
            Layout.fillWidth: true

            Layout.preferredHeight:
                ShellTheme.Theme.spacing.xSmall
        }

        /*
         * --------------------------------------------------------
         * SYSTEM IDENTITY
         * --------------------------------------------------------
         */

        InfoRow {
            glyph: "󰌢"

            value:
                root.profile
                && root.profile.hostnameLabel
                    ? root.profile.hostnameLabel
                    : ""
        }

        InfoRow {
            glyph: "󰣇"

            value:
                root.profile
                && root.profile.distributionLabel
                    ? root.profile.distributionLabel
                    : ""
        }

        InfoRow {
            glyph: ""

            value:
                root.profile
                && root.profile.sessionLabel
                    ? root.profile.sessionLabel
                    : ""
        }

        InfoRow {
            glyph: "󰌽"

            value:
                root.profile
                && root.profile.kernelLabel
                    ? root.profile.kernelLabel
                    : ""
        }

        InfoRow {
            glyph: "󰔛"

            value:
                root.profile
                && root.profile.uptimeLabel
                    ? root.profile.uptimeLabel
                    : ""
        }
    }

    /*
     * ------------------------------------------------------------
     * REUSABLE INFORMATION ROW
     * ------------------------------------------------------------
     */

    component InfoRow: RowLayout {
        id: infoRow

        property string glyph: ""
        property string value: ""

        Layout.fillWidth: true

        spacing:
            ShellTheme.Theme.spacing.small

        Visual.Icon {
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18

            visible:
                infoRow.glyph.length > 0

            glyph:
                infoRow.glyph

            iconSize:
                ShellTheme.Theme.typography.bodySmall

            color:
                ShellTheme.Theme.colors.on_surface_variant
        }

        /*
         * Preserve alignment when a row intentionally has
         * no icon, such as the session label.
         */
        Item {
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18

            visible:
                infoRow.glyph.length === 0
        }

        Text {
            Layout.fillWidth: true

            text:
                infoRow.value

            color:
                ShellTheme.Theme.colors.on_surface_variant

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.labelMedium

            elide:
                Text.ElideRight
        }
    }
}
