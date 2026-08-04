import QtQuick

Column {
    id: root

    property string query: ""
    property string category: "All"

    spacing: 10

    Text {
        anchors.horizontalCenter: parent.horizontalCenter

        text: "󰅖"
        color: "#667281"

        font.pixelSize: 34
        font.family: "JetBrainsMono Nerd Font"
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter

        text: "No applications found"
        color: "#c2cad4"

        font.pixelSize: 13
        font.weight: Font.DemiBold
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter

        text: {
            if (root.query.length > 0)
                return "No results for “" + root.query + "”"

            if (root.category !== "All")
                return "No applications in " + root.category

            return "No installed applications are available"
        }

        color: "#788493"
        font.pixelSize: 10
    }
}
