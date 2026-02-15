import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

Rectangle {
    id: sidebarBackground
    width: parent.width * 0.20
    height: parent.height
    color: "#121212"

    property int selectedIndex: 0

    signal selectionChanged(int index)

    ListModel {
        id: buttonModel
        ListElement {
            text: "Take Order"
        }
        ListElement {
            text: "Checkout"
        }
        ListElement {
            text: "Kitchen"
        }
        ListElement {
            text: "Menu Management"
        }
        ListElement {
            text: "Table Management"
        }
        ListElement {
            text: "Settings"
        }
    }

    ColumnLayout {
        id: sidebarLayout
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: buttonModel
            delegate: Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                clip: true

                property int index: model.index

                background: Rectangle {
                    color: sidebarBackground.selectedIndex === index ? "#9a7bff" : "#121212"
                }

                contentItem: Text {
                    text: model.text
                    font.bold: true
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    elide: Text.ElideRight
                }

                onClicked: {
                    sidebarBackground.selectedIndex = index
                    sidebarBackground.selectionChanged(index)
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
