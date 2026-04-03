import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Trudia.Services 1.0

Rectangle {
    id: sidebarBackground
    width: parent.width * 0.20
    height: parent.height
    color: "#121212"

    property int selectedIndex: 0
    property string kitchenMode: "none"

    Component.onCompleted: {
        const settings = SettingService.getKitchenSettings()
        kitchenMode = settings.mode || "none"
    }

    signal selectionChanged(int index)

    ListModel {
        id: buttonModel
        ListElement {
            text: qsTr("Take Order")
        }
        ListElement {
            text: qsTr("Checkout")
        }
        ListElement {
            text: qsTr("Kitchen")
        }
        ListElement {
            text: qsTr("Analytics")
        }
        ListElement {
            text: qsTr("Management")
        }
        ListElement {
            text: qsTr("Settings")
        }
    }

    ColumnLayout {
        id: sidebarLayout
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: buttonModel
            delegate: Button {
                enabled: !(model.text === "Kitchen"
                           && (sidebarBackground.kitchenMode === "none"
                               || sidebarBackground.kitchenMode === "tickets"))
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
                    color: enabled ? "white" : "#888888"
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
