import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore

ApplicationWindow {
    id: window

    width: 480
    height: 640
    visible: true
    title: "Time Counter"
    color: Theme.colours.background || "#11140e"

    Settings {
        id: checkedStates

        category: "checkedStates"
    }

    ListModel {
        id: subjectsModel

        ListElement {
            name: "Fisica"
            time: 15
        }

        ListElement {
            name: "Matematica"
            time: 15
        }

        ListElement {
            name: "Quimica"
            time: 15
        }

        ListElement {
            name: "Portugues"
            time: 6
        }

        ListElement {
            name: "Computação"
            time: 6
        }

    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 16

            Repeater {
                model: subjectsModel

                delegate: ColumnLayout {
                    id: subjectDelegate

                    required property string name
                    required property int time

                    Layout.fillWidth: true
                    Layout.margins: 8
                    spacing: 4

                    Label {
                        text: subjectDelegate.name
                        font.bold: true
                        font.pixelSize: 16
                        color: Theme.colours.onBackground || "white"
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 4

                        Repeater {
                            model: subjectDelegate.time % 2

                            delegate: RoundedCheckBox {
                                property string settingsKey: subjectDelegate.name + "_1h_" + index

                                text: "1h"
                                value: 1
                                checked: checkedStates.value(settingsKey, "false") === "true"
                                onCheckedChanged: {
                                    checkedStates.setValue(settingsKey, checked);
                                    checkedStates.sync();
                                }
                            }

                        }

                        Repeater {
                            model: Math.floor(subjectDelegate.time / 2)

                            delegate: RoundedCheckBox {
                                property string settingsKey: subjectDelegate.name + "_2h_" + index

                                text: "2h"
                                value: 2
                                checked: checkedStates.value(settingsKey, "false") === "true"
                                onCheckedChanged: {
                                    checkedStates.setValue(settingsKey, checked);
                                    checkedStates.sync();
                                }
                            }

                        }

                    }

                }

            }

        }

    }

}
