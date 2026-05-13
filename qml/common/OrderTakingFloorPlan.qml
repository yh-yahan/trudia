import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0
import "./floor"

Item {
    id: root

    width: 800
    height: 600

    property int selectedTableId: -1
    property int currentFloorId: -1

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            // visible: FloorPlanService.floorModel.count > 1

            ButtonGroup {
                id: floorGroup
                exclusive: true
            }

            Repeater {
                model: FloorPlanService.floorModel

                delegate: Button {
                    required property int index
                    required property var modelData

                    text: modelData.name
                    checkable: true
                    ButtonGroup.group: floorGroup

                    checked: root.currentFloorId === modelData.id

                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 8
                    bottomPadding: 8

                    background: Rectangle {
                        radius: 6
                        color: checked ? Theme.primary() : Theme.surface
                    }

                    contentItem: Label {
                        text: modelData.name
                        color: checked ? "white" : Theme.text
                        font.bold: true
                        font.pixelSize: Theme.fontNormal
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus

                    onClicked: {
                        let floor = FloorPlanService.floorModel.getFloor(index)
                        if (!floor)
                            return

                        root.currentFloorId = modelData.id
                        FloorPlanService.loadCanvas(modelData.id)
                    }
                }
            }
        }

        FloorPlanView {
            id: floorView

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: FloorPlanService.canvasModel
            selectedTableId: root.selectedTableId

            onTableSelected: function (tableId) {
                root.selectedTableId = tableId
            }
        }
    }

    Component.onCompleted: {
        if (FloorPlanService.floorModel.count > 0) {
            let first = FloorPlanService.floorModel.get(0)

            currentFloorId = first.id
            FloorPlanService.loadCanvas(first.id)
        }
    }
}
