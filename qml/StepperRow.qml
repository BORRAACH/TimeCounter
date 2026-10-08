import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Label on the left, - value + on the right (caelestia's nexus StepperRow).
ConnectedRect {
    id: root

    property string label
    property int value
    property int from: 0
    property int to: 99

    signal moved(int value)

    Layout.fillWidth: true
    implicitHeight: rowLayout.implicitHeight + 24

    // Clicking anywhere on the row (outside the buttons and the value field,
    // which sit on top of this) adds 1.
    MouseArea {
        id: rowArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.value < root.to ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.value < root.to)
                root.moved(root.value + 1);
        }
    }

    // State layer
    Rectangle {
        anchors.fill: parent
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
        color: Theme.colours.onSurface || "white"
        opacity: rowArea.pressed ? 0.1 : rowArea.containsMouse ? 0.06 : 0

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    RowLayout {
        id: rowLayout

        anchors.fill: parent
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 12

        Label {
            Layout.fillWidth: true
            text: root.label
            font.pixelSize: 15
            elide: Text.ElideRight
            color: Theme.colours.onSurface || "white"
        }

        StepButton {
            text: "−"
            implicitWidth: 40
            implicitHeight: 32
            enabled: root.value > root.from
            onClicked: root.moved(Math.max(root.from, root.value - 1))
        }

        // Value: click and type a number directly, or use the buttons.
        Rectangle {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 32
            radius: 10
            color: valueInput.activeFocus ? (Theme.colours.surfaceContainerHighest || "#33362f") : "transparent"
            border.width: valueInput.activeFocus ? 2 : 0
            border.color: Theme.colours.primary || "#add28e"

            TextInput {
                id: valueInput

                function commit() {
                    const n = parseInt(text);
                    if (!isNaN(n))
                        root.moved(Math.max(root.from, Math.min(root.to, n)));
                    // Re-bind so the field always shows the accepted value
                    text = Qt.binding(() => root.value.toString());
                }

                anchors.fill: parent
                text: root.value.toString()
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: 15
                font.bold: true
                color: Theme.colours.primary || "#add28e"
                selectionColor: Theme.colours.primary || "#add28e"
                selectedTextColor: Theme.colours.onPrimary || "#1a3705"
                selectByMouse: true
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator {
                    bottom: root.from
                    top: root.to
                }
                onActiveFocusChanged: if (activeFocus) selectAll()
                onEditingFinished: commit()
            }

            HoverHandler {
                cursorShape: Qt.IBeamCursor
            }
        }

        StepButton {
            text: "+"
            implicitWidth: 40
            implicitHeight: 32
            enabled: root.value < root.to
            onClicked: root.moved(Math.min(root.to, root.value + 1))
        }
    }
}
