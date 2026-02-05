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

    ColumnLayout {
        id: sidebarLayout
        anchors.fill: parent
        spacing: 0

        Button {
            id: orderBtn
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            text: "Take Order"
            clip: true

            property int index: 0

            background: Rectangle {
                color: sidebarBackground.selectedIndex === orderBtn.index ? "#9a7bff" : "#121212"
            }

            contentItem: Text {
                text: qsTr("Take Order")
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

        Button {
            id: menuBtn
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            text: "Menu Management"
            clip: true

            property int index: 1

            background: Rectangle {
                color: sidebarBackground.selectedIndex === menuBtn.index ? "#9a7bff" : "#121212"
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

            onClicked: {
                sidebarBackground.selectedIndex = index
                sidebarBackground.selectionChanged(index)
            }

            hoverEnabled: false
            focusPolicy: Qt.NoFocus
        }

        Button {
            id: tableBtn
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            text: "Table Management"
            clip: true

            property int index: 2

            background: Rectangle {
                color: sidebarBackground.selectedIndex === tableBtn.index ? "#9a7bff" : "#121212"
            }

            contentItem: Text {
                text: qsTr("Table Management")
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

        Item {
            Layout.fillHeight: true
        }
    }
}
