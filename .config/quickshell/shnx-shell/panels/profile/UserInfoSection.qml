import QtQuick
import QtQuick.Layouts
import qs.core as Core

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

            text: root.profile.effectiveDisplayName
            color: "#f4f6f8"

            font.pixelSize: 22
            font.weight: Font.DemiBold

            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true

            text: root.profile.usernameLabel
            color: "#9faaba"

            font.pixelSize: 13
            elide: Text.ElideRight
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 5
        }

        InfoRow {
            iconText: "󰌢"
            valueText: root.profile.hostnameLabel
        }

        InfoRow {
            iconText: "󰣇"
            valueText: root.profile.distributionLabel
        }

        InfoRow {
            iconText: ""
            valueText: root.profile.sessionLabel
        }

        InfoRow {
            iconText: "󰌽"
            valueText: root.profile.kernelLabel
        }

        InfoRow {
            iconText: "󰔛"
            valueText: root.profile.uptimeLabel
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
            color: "#8793a3"

            font.pixelSize: 13
            font.family: "JetBrainsMono Nerd Font"

            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.fillWidth: true

            text: parent.valueText
            color: "#aeb7c3"

            font.pixelSize: 12

            elide: Text.ElideRight
        }
    }
}
