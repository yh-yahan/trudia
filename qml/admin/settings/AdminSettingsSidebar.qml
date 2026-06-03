import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import trudia.Theme 1.0

Rectangle {
    id: sidebarBackground
    width: parent.width * 0.20
    height: parent.height
    color: Theme.background

    property int selectedIndex: 0

    signal selectionChanged(int index)

    ListModel {
        id: buttonModel
        ListElement {
            text: qsTr("Restaurant")
        }

        ListElement {
            text: qsTr("Tables")
        }

        ListElement {
            text: qsTr("Printer")
        }

        ListElement {
            text: qsTr("Tax")
        }

        ListElement {
            text: qsTr("Membership")
        }

        ListElement {
            text: qsTr("Kitchen")
        }

        ListElement {
            text: qsTr("Region & Formats")
        }

        ListElement {
            text: qsTr("Database")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: buttonModel
            delegate: Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                background: Rectangle {
                    color: sidebarBackground.selectedIndex === index ? Theme.primary() : Theme.background
                    radius: 4
                }

                contentItem: Text {
                    text: model.text
                    font.bold: true
                    anchors.centerIn: parent
                    color: sidebarBackground.selectedIndex === index ? "white" : Theme.text
                    font.family: "Arial"
                    font.pixelSize: Theme.fontNormal
                    elide: Text.ElideRight
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus

                onClicked: {
                    sidebarBackground.selectedIndex = index
                    sidebarBackground.selectionChanged(index)
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
