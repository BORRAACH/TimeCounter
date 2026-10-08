import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Summary card styled after caelestia's dashboard/performance/StorageCard.qml.
// The -1h/+1h buttons only appear while the pointer is over the card, in the
// slot of the subject name, so the card never changes size.
Rectangle {
    id: root

    property string subject
    property int done: 0
    property int total: 1

    signal changeRequested(int hours)

    color: Theme.colours.surfaceContainer || "#1d201a"
    radius: 28

    implicitWidth: 200
    implicitHeight: layout.implicitHeight + 32

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 16
        spacing: 8

        CircularProgress {
            id: ring

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 140
            Layout.preferredHeight: 140

            value: root.total > 0 ? root.done / root.total : 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.done + "h"
                    font.pixelSize: 26
                    font.bold: true
                    color: ring.fgColour
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: "de " + root.total + "h"
                    font.pixelSize: 12
                    color: Theme.colours.onSurfaceVariant || palette.text
                }
            }
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 140
            Layout.preferredHeight: 36

            Label {
                anchors.centerIn: parent
                text: root.subject
                font.pixelSize: 16
                font.bold: true
                color: Theme.colours.onSurface || "white"
                opacity: hover.hovered ? 0 : 1

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 8
                opacity: hover.hovered ? 1 : 0
                enabled: hover.hovered

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                HourButton {
                    symbol: "remove"
                    accentRole: "error"
                    label: "−1h"
                    enabled: root.done > 0
                    onClicked: root.changeRequested(root.done - 1)
                }

                HourButton {
                    symbol: "add"
                    accentRole: "success"
                    label: "+1h"
                    enabled: root.done < root.total
                    onClicked: root.changeRequested(root.done + 1)
                }
            }
        }
    }

    HoverHandler {
        id: hover
    }
}
