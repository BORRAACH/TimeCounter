import QtQuick
import QtQuick.Controls

// Icon-only +/- button. On click the icon morphs into its label ("+1h" /
// "-1h") for a moment, widening the button, then goes back to the icon.
Button {
    id: btn

    property string symbol      // Material Symbols ligature: "add" / "remove"
    property string label       // text shown while flashing: "+1h" / "−1h"
    property string accentRole: "success"   // colour role flashed on click: "success" / "error"
    property bool flashing

    readonly property color accentColour: Theme.colours[accentRole] || (accentRole === "error" ? "#ffb4ab" : "#8bd6a0")
    readonly property color onAccentColour: Theme.colours["on" + accentRole.charAt(0).toUpperCase() + accentRole.slice(1)] || (accentRole === "error" ? "#690005" : "#003919")
    readonly property color restColour: Theme.colours.secondaryContainer || "#3f4a3c"
    readonly property color onRestColour: Theme.colours.onSecondaryContainer || "white"
    readonly property color currentOnColour: flashing ? onAccentColour : onRestColour

    implicitWidth: flashing ? 72 : 44
    implicitHeight: 36
    opacity: enabled ? 1 : 0.4

    onClicked: {
        flashing = true;
        flashTimer.restart();
    }

    Timer {
        id: flashTimer

        interval: 450
        onTriggered: btn.flashing = false
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 150
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.42, 1.67, 0.21, 0.9, 1, 1]
        }
    }

    contentItem: Item {
        Label {
            anchors.centerIn: parent
            text: btn.symbol
            font.family: "Material Symbols Rounded"
            font.pixelSize: 22
            renderType: Text.NativeRendering
            color: Theme.colours.onSecondaryContainer || "white"
            opacity: btn.flashing ? 0 : 1
            scale: btn.flashing ? 0.4 : 1

            Behavior on opacity {
                NumberAnimation { duration: 75 }
            }

            Behavior on scale {
                NumberAnimation { duration: 125; easing.type: Easing.OutBack }
            }
        }

        Label {
            anchors.centerIn: parent
            text: btn.label
            font.pixelSize: 15
            font.bold: true
            color: btn.onAccentColour
            opacity: btn.flashing ? 1 : 0
            scale: btn.flashing ? 1 : 0.4

            Behavior on opacity {
                NumberAnimation { duration: 75 }
            }

            Behavior on scale {
                NumberAnimation { duration: 125; easing.type: Easing.OutBack }
            }
        }
    }

    background: Rectangle {
        radius: height / 2
        color: btn.flashing ? btn.accentColour : btn.restColour

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: btn.currentOnColour
            opacity: btn.pressed ? 0.12 : btn.hovered ? 0.08 : 0
        }
    }
}
