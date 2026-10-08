import QtQuick
import QtQuick.Controls

// Page switch button, styled like caelestia's IconButton: rounded square at
// rest, circular (and filled) while its page is selected or it is pressed.
Button {
    id: btn

    property string symbol
    property bool selected
    readonly property bool round: selected || pressed

    padding: 8
    implicitWidth: 24 + padding * 2
    implicitHeight: implicitWidth
    scale: hovered ? 1.15 : 1

    ToolTip.visible: hovered
    ToolTip.delay: 500
    ToolTip.text: btn.text

    Behavior on scale {
        NumberAnimation {
            duration: 350
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.42, 1.67, 0.21, 0.9, 1, 1]
        }
    }

    contentItem: Label {
        text: btn.symbol
        font.family: "Material Symbols Rounded"
        font.pixelSize: 24
        renderType: Text.NativeRendering
        font.variableAxes: ({ "FILL": btn.selected ? 1 : 0 })
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: btn.selected ? (Theme.colours.onPrimary || "#1a3705") : (Theme.colours.onSecondaryContainer || "white")
    }

    background: Rectangle {
        radius: btn.round ? height / 2 : 16
        color: btn.selected ? (Theme.colours.primary || "#add28e") : (Theme.colours.secondaryContainer || "#3f4a3c")

        Behavior on radius {
            NumberAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.34, 0.8, 0.34, 1, 1, 1]
            }
        }

        Behavior on color {
            ColorAnimation { duration: 200 }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: btn.selected ? (Theme.colours.onPrimary || "#1a3705") : (Theme.colours.onSecondaryContainer || "white")
            opacity: btn.pressed ? 0.1 : btn.hovered ? 0.08 : 0
        }
    }
}
