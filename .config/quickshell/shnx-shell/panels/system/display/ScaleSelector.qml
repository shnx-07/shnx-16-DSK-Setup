import QtQuick

import qs.theme as ShellTheme

import "../../../components/controls" as Controls

Item {
    id: root

    required property var monitor

    signal scaleSelected(
        real scale
    )

    readonly property real currentScale:
        Number(
            root.monitor
                ? root.monitor.scale
                : 1.0
        )

    implicitHeight:
        contentColumn.implicitHeight


    Column {
        id: contentColumn

        width:
            parent.width

        spacing:
            ShellTheme.Theme.spacing.small


        Row {
            width:
                parent.width

            height: 28


            Column {
                width:
                    Math.max(
                        0,
                        parent.width
                        - scaleValue.width
                        - ShellTheme.Theme.spacing.medium
                    )

                anchors.verticalCenter:
                    parent.verticalCenter

                spacing: 2


                Text {
                    text:
                        "Scale"

                    color:
                        ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.bodySmall

                    font.weight:
                        ShellTheme.Theme.typography.weightMedium
                }


                Text {
                    text:
                        "Interface size"

                    color:
                        ShellTheme.Theme.colors.on_surface_variant

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelSmall

                    opacity: 0.68
                }
            }


            Rectangle {
                id: scaleValue

                width: 58
                height: 28

                anchors.verticalCenter:
                    parent.verticalCenter

                radius:
                    ShellTheme.Theme.radius.button

                color:
                    ShellTheme.Theme.colors.surfaceContainerHigh


                Text {
                    anchors.centerIn:
                        parent

                    text:
                        Number(
                            scaleSlider.value
                        ).toFixed(2)
                        + "×"

                    color:
                        ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelSmall

                    font.weight:
                        ShellTheme.Theme.typography.weightMedium
                }
            }
        }


        Controls.Slider {
            id: scaleSlider

            width:
                parent.width

            from: 0.5
            to: 2.0
            stepSize: 0.05

            enabled:
                root.monitor
                && root.monitor.enabled

            value:
                root.currentScale

            onValueCommitted: value => {
                root.scaleSelected(value)
            }
        }


        Row {
          width: parent.width
          height: 14

          Text {
              id: minimumLabel

              text: "50%"

              color:
                  ShellTheme.Theme.colors.on_surface_variant

              font.family:
                  ShellTheme.Theme.typography.fontFamily

              font.pixelSize:
                  ShellTheme.Theme.typography.labelSmall

              opacity: 0.55
          }

          Item {
              width:
                  Math.max(
                      0,
                      parent.width
                      - minimumLabel.implicitWidth
                      - maximumLabel.implicitWidth
                  )

              height: 1
          }

          Text {
              id: maximumLabel

              text: "200%"

              color:
                  ShellTheme.Theme.colors.on_surface_variant

              font.family:
                  ShellTheme.Theme.typography.fontFamily

              font.pixelSize:
                  ShellTheme.Theme.typography.labelSmall

              opacity: 0.55
          }
      }
    }
}
