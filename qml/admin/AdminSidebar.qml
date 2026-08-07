import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Trudia.Services 1.0
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
        ListElement { key: "takeOrder"; text: qsTr("Take Order") }
        ListElement { key: "checkout"; text: qsTr("Checkout") }
        ListElement { key: "kitchen"; text: qsTr("Kitchen") }
        ListElement { key: "analytics"; text: qsTr("Analytics") }
        ListElement { key: "taxReports"; text: qsTr("Tax Reports") }
        ListElement { key: "management"; text: qsTr("Management") }
        ListElement { key: "settings"; text: qsTr("Settings") }
    }

    ColumnLayout {
        id: sidebarLayout
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: buttonModel
            delegate: Button {
                enabled: !(model.key === "kitchen"
                    && (SettingService.kitchenMode === "none"
                    || SettingService.kitchenMode === "tickets"))
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                clip: true

                property int index: model.index

                background: Rectangle {
                    color: sidebarBackground.selectedIndex === index ? Theme.primary() : Theme.background
                }

                contentItem: Text {
                    text: model.text
                    font.bold: true
                    font.pixelSize: Theme.fontNormal
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    color: sidebarBackground.selectedIndex === index
                        ? "white"
                        : (enabled ? Theme.text : Theme.secondaryText)
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
