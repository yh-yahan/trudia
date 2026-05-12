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
    }

    function populateModel() {
        buttonModel.clear()

        buttonModel.append({
                               "text": qsTr("Menu")
                           })

        buttonModel.append({
                               "text": SettingService.tableLayoutMode
                                       === "floor_plan" ? qsTr("Floor Plan") : qsTr(
                                                              "Table")
                           })

        buttonModel.append({
                               "text": qsTr("User")
                           })
    }

    Component.onCompleted: populateModel()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: buttonModel
            delegate: Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                background: Rectangle {
                    color: sidebarBackground.selectedIndex === index ? Theme.primary(
                                                                           ) : Theme.surface
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
