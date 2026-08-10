import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

ColumnLayout {
    id: root

    property alias text: label.text
    property alias checked: checkBox.checked
    property int value: 0

    signal toggled()

    spacing: 2

    Label {
        id: label

        Layout.alignment: Qt.AlignHCenter
        color: Theme.colours.onSurfaceVariant || palette.text
    }

    CheckBox {
        id: checkBox

        Layout.alignment: Qt.AlignHCenter
        topPadding: 1
        onToggled: root.toggled()

        // Mirrors caelestia's components/controls/StyledSwitch.qml (its only
        // checkbox/toggle style) with Appearance.* tokens inlined as numbers
        // and Colours.palette swapped for our own Theme.colours.
        indicator: Rectangle {
            id: track

            implicitHeight: 13 + 7 * 2
            implicitWidth: implicitHeight * 1.7
            x: (checkBox.width - width) / 2
            y: checkBox.topPadding + (checkBox.availableHeight - height) / 2
            radius: height / 2
            color: checkBox.checked ? (Theme.colours.primary || "#add28e") : (Theme.colours.surfaceContainerHighest || "#33362f")

            Behavior on color {
                ColorAnimation {
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                }
            }

            Rectangle {
                id: thumb

                readonly property real size: checkBox.pressed ? track.implicitHeight - 5 * 0.7 : track.implicitHeight - 5

                radius: height / 2
                color: checkBox.checked ? (Theme.colours.onPrimary || "#1a3705") : (Theme.colours.outline || "#8e9286")
                width: size
                height: track.implicitHeight - 5
                anchors.verticalCenter: parent.verticalCenter
                x: checkBox.checked ? track.width - width - 2.5 : 2.5

                Behavior on x {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                    }
                }

                Shape {
                    id: icon

                    property point start1: checkBox.checked ? Qt.point(width * 0.15, height / 2) : Qt.point(width * 0.15, height * 0.15)
                    property point end1: checkBox.checked ? Qt.point(width * 0.4, height * 0.7) : Qt.point(width * 0.85, height * 0.85)
                    property point start2: checkBox.checked ? Qt.point(width * 0.4, height * 0.7) : Qt.point(width * 0.15, height * 0.85)
                    property point end2: checkBox.checked ? Qt.point(width * 0.85, height * 0.2) : Qt.point(width * 0.85, height * 0.15)

                    anchors.centerIn: parent
                    width: height
                    height: parent.height - 8
                    preferredRendererType: Shape.CurveRenderer
                    asynchronous: true

                    ShapePath {
                        strokeWidth: 2
                        strokeColor: checkBox.checked ? (Theme.colours.primary || "#add28e") : (Theme.colours.surfaceContainerHighest || "#33362f")
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        startX: icon.start1.x
                        startY: icon.start1.y

                        PathLine {
                            x: icon.end1.x
                            y: icon.end1.y
                        }
                        PathMove {
                            x: icon.start2.x
                            y: icon.start2.y
                        }
                        PathLine {
                            x: icon.end2.x
                            y: icon.end2.y
                        }

                        Behavior on strokeColor {
                            ColorAnimation {
                                duration: 400
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                            }
                        }
                    }

                    Behavior on start1 {
                        PropertyAnimation {
                            duration: 400
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                        }
                    }
                    Behavior on end1 {
                        PropertyAnimation {
                            duration: 400
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                        }
                    }
                    Behavior on start2 {
                        PropertyAnimation {
                            duration: 400
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                        }
                    }
                    Behavior on end2 {
                        PropertyAnimation {
                            duration: 400
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                        }
                    }
                }
            }
        }
    }
}
