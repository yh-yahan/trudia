import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

Rectangle {
    id: sidebarBackground
    width: parent.width * 0.20
    height: parent.height
    color: "#2e2e2e"

    ColumnLayout {
        id: sidebarLayout
        anchors.fill: parent
        spacing: 10

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            text: "Menu Management"
            clip: true
            anchors.margins: 10

            background: Rectangle {
                color: "#9a7bff"
            }

            contentItem: Text {
                text: qsTr("Menu Management")
                font.bold: true
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white"
                elide: Text.ElideRight
            }

            hoverEnabled: false
            focusPolicy: Qt.NoFocus
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
