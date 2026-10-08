import QtQuick

// Row of a connected group, mirrors caelestia's nexus/common/ConnectedRect:
// large outer corners on the first/last row, small ones between rows.
Rectangle {
    property bool first
    property bool last

    color: Theme.colours.surfaceContainer || "#1d201a"
    topLeftRadius: first ? 28 : 4
    topRightRadius: first ? 28 : 4
    bottomLeftRadius: last ? 28 : 4
    bottomRightRadius: last ? 28 : 4
}
