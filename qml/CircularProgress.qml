import QtQuick
import QtQuick.Shapes

// Mirrors caelestia's components/controls/CircularProgress.qml (without the
// wavy variant, which needs a C++ type) using plain QtQuick.Shapes.
Item {
    id: root

    property real value: 0
    property int startAngle: -225
    property int sweepAngle: 270
    property int strokeWidth: 10
    property int spacing: 6
    // Colour blended along error -> tertiary -> primary -> success. Each stop
    // sits at 0, 1/3, 2/3 and 1; between two stops the neighbours are mixed
    // linearly (at a stop its own colour has weight 1, the other 0).
    readonly property var roles: ["error", "tertiary", "primary", "success"]
    readonly property var fallbacks: ({
        error: ["#ffb4ab", "#93000a"],
        tertiary: ["#a2cfd5", "#204d55"],
        primary: ["#add28e", "#2f4f1e"],
        success: ["#8bd6a0", "#0d5228"]
    })

    function roleColour(role, container) {
        return Theme.colours[container ? role + "Container" : role] || fallbacks[role][container ? 1 : 0];
    }

    function blended(progress, container) {
        const segments = roles.length - 1;
        const pos = Math.max(0, Math.min(1, progress)) * segments;
        const i = Math.min(segments - 1, Math.floor(pos));
        const t = pos - i;
        const from = Qt.color(roleColour(roles[i], container));
        const to = Qt.color(roleColour(roles[i + 1], container));
        return Qt.rgba(from.r + (to.r - from.r) * t, from.g + (to.g - from.g) * t, from.b + (to.b - from.b) * t, from.a + (to.a - from.a) * t);
    }

    // Driven by the animated clampedVal so colour and arc move together.
    property color fgColour: blended(clampedVal, false)
    property color bgColour: blended(clampedVal, true)

    readonly property real size: Math.min(width, height)
    readonly property real arcRadius: (size - strokeWidth) / 2
    // Not readonly so the Behavior can animate it.
    property real clampedVal: Math.max(1 / 360, Math.min(1, isNaN(value) ? 0 : value))
    readonly property real gapAngle: ((spacing + strokeWidth) / (arcRadius || 1)) * (180 / Math.PI)

    Behavior on clampedVal {
        NumberAnimation {
            duration: 400
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        asynchronous: true

        // Remaining track
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.bgColour
            strokeWidth: Math.min(1, remainingArc.sweepAngle) * root.strokeWidth
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                id: remainingArc

                radiusX: root.arcRadius
                radiusY: root.arcRadius
                centerX: root.width / 2
                centerY: root.height / 2
                startAngle: root.startAngle + root.clampedVal * root.sweepAngle + root.gapAngle
                sweepAngle: Math.max(1 / 360, root.sweepAngle * (1 - root.clampedVal) - root.gapAngle)
            }
        }

        // Progress
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.fgColour
            strokeWidth: root.strokeWidth
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                centerX: root.width / 2
                centerY: root.height / 2
                startAngle: root.startAngle
                sweepAngle: root.sweepAngle * root.clampedVal
            }
        }
    }
}
