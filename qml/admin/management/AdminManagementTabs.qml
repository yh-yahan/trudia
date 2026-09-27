import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Rectangle {
    id: root

    property int selectedIndex: 0
    signal selectionChanged(int index)

    color: Theme.background
    implicitHeight: 56

    ListModel {
        id: buttonModel
    }

    function populateModel() {
        const savedIndex = root.selectedIndex
        buttonModel.clear()
        buttonModel.append({ "text": qsTr("Menu") })
        buttonModel.append({ "text": qsTr("Inventory") })
        buttonModel.append({
            "text": SettingService.tableLayoutMode === "floor_plan"
                    ? qsTr("Floor Plan")
                    : qsTr("Table")
        })
        buttonModel.append({ "text": qsTr("Members") })
        buttonModel.append({ "text": qsTr("User") })
        if (savedIndex >= 0 && savedIndex < buttonModel.count)
            root.selectedIndex = savedIndex
    }

    Component.onCompleted: populateModel()

    Connections {
        target: SettingService
        ignoreUnknownSignals: true
        function onTableLayoutModeChanged() {
            populateModel()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            spacing: 6

            Repeater {
                model: buttonModel

                delegate: Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 72

                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus

                    background: Rectangle {
                        radius: 6
                        color: root.selectedIndex === index ? Theme.primary() : Theme.surface
                    }

                    contentItem: Text {
                        text: model.text
                        color: root.selectedIndex === index ? "white" : Theme.text
                        font.bold: true
                        font.family: "Arial"
                        font.pixelSize: Theme.fontNormal
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        root.selectedIndex = index
                        root.selectionChanged(index)
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.border
        }
    }
}
