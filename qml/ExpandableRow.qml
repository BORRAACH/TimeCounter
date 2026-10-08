import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Collapsible group: a header row that expands to reveal the rows declared
// inside it, all part of the same connected block.
ColumnLayout {
    id: root

    property string title
    property bool expanded
    default property alias content: inner.data

    Layout.fillWidth: true
    spacing: 0

    ConnectedRect {
        Layout.fillWidth: true
        implicitHeight: headerRow.implicitHeight + 32
        first: true
        last: !root.expanded

        RowLayout {
            id: headerRow

            anchors.fill: parent
            anchors.margins: 16
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            Label {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: 15
                color: Theme.colours.onSurface || "white"
            }

            Label {
                text: "expand_more"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 24
                renderType: Text.NativeRendering
                rotation: root.expanded ? 180 : 0
                color: Theme.colours.onSurfaceVariant || palette.text

                Behavior on rotation {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.34, 0.8, 0.34, 1, 1, 1]
                    }
                }
            }
        }

        // State layer
        Rectangle {
            anchors.fill: parent
            topLeftRadius: parent.topLeftRadius
            topRightRadius: parent.topRightRadius
            bottomLeftRadius: parent.bottomLeftRadius
            bottomRightRadius: parent.bottomRightRadius
            color: Theme.colours.onSurface || "white"
            opacity: tap.pressed ? 0.1 : hover.hovered ? 0.08 : 0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        HoverHandler {
            id: hover

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            id: tap

            onTapped: root.expanded = !root.expanded
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.expanded ? inner.implicitHeight + 2 : 0
        visible: Layout.preferredHeight > 0
        clip: true

        Behavior on Layout.preferredHeight {
            NumberAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.34, 0.8, 0.34, 1, 1, 1]
            }
        }

        ColumnLayout {
            id: inner

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 2
            spacing: 2
        }
    }
}
