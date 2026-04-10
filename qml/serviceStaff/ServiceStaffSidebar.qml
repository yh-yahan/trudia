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
                    color: sidebarBackground.selectedIndex === index ? Theme.primary() : Theme.background
                }

                contentItem: Text {
                    text: model.text
                    font.bold: true
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
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
