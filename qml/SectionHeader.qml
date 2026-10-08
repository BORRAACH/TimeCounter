import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Mirrors caelestia's nexus/common/SectionHeader.
Label {
    Layout.fillWidth: true
    Layout.leftMargin: 8
    Layout.topMargin: 12
    Layout.bottomMargin: 2

    color: Theme.colours.onSurfaceVariant || palette.text
    font.pixelSize: 13
    font.bold: true
    elide: Text.ElideRight
}
