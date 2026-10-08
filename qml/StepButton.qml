import QtQuick
import QtQuick.Controls

Button {
    id: btn

    implicitWidth: 64
    implicitHeight: 36
    opacity: enabled ? 1 : 0.4

    contentItem: Label {
        text: btn.text
        font.pixelSize: btn.font.pixelSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Theme.colours.onSecondaryContainer || "white"
    }

    background: Rectangle {
        radius: height / 2
        color: Theme.colours.secondaryContainer || "#3f4a3c"

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Theme.colours.onSecondaryContainer || "white"
            opacity: btn.pressed ? 0.12 : btn.hovered ? 0.08 : 0
        }
    }
}
