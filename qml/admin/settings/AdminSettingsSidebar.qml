import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

Rectangle {
    id: sidebarBackground
    width: parent.width * 0.20
    height: parent.height
    color: "#2D2D2D"

    property int selectedIndex: 0

    signal selectionChanged(int index)

    ListModel {
        id: buttonModel
        ListElement {
            text: "Restaurant"
        }

        ListElement {
            text: "Printer"
        }

        ListElement {
            text: "Tax"
        }

        ListElement {
            text: "Membership"
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
                    color: sidebarBackground.selectedIndex === index ? "#9a7bff" : "#383838"
                    radius: 4
                }

                contentItem: Text {
                    text: model.text
                    font.bold: true
                    anchors.centerIn: parent
                    color: "white"
                    font.family: "Arial"
                    font.pixelSize: 14
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
