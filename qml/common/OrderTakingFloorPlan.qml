import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0
import "../components"
import "./floor"

Item {
    id: root

    width: 800
    height: 600

    property int selectedTableId: -1
    property int currentFloorId: -1
    property var orderTable: null

    function selectedTable() {
        if (root.selectedTableId < 0)
            return null

        const model = FloorPlanService.canvasModel

        if (!model || model.rowCount() === 0)
            return null

        for (var i = 0; i < model.rowCount(); i++) {
            const item = model.get(i)

            if (!item)
                continue

            const metadata = item.metadata ? JSON.parse(item.metadata) : {}

            if (Number(metadata.table_id) === Number(root.selectedTableId)) {
                return {
                    "canvasItem": item,
                    "metadata": metadata
                }
            }
        }

        return null
    }

    Connections {
        target: FloorPlanService.floorModel

        function onModelReset() {
            if (FloorPlanService.floorModel.rowCount() <= 0)
                return

            const first = FloorPlanService.floorModel.getFloor(0)

            root.currentFloorId = first.id

            FloorPlanService.loadCanvas(first.id)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: floorPlanComponent
    }

    Component {
        id: floorPlanComponent

        ColumnLayout {
            anchors.fill: parent
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

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
                        checked: root.currentFloorId < 0
                            ? index === 0
                            : root.currentFloorId === modelData.id

                        ButtonGroup.group: floorGroup

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
                            let floor = FloorPlanService.floorModel.getFloor(
                                    index)

                            if (!floor)
                                return

                            root.currentFloorId = modelData.id
                            root.selectedTableId = -1

                            FloorPlanService.loadCanvas(modelData.id)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    radius: 6
                    color: Theme.background

                    border.width: 1
                    border.color: Theme.border

                    clip: true

                    Flickable {
                        anchors.fill: parent

                        contentWidth: 1600
                        contentHeight: 1200

                        clip: true

                        boundsBehavior: Flickable.StopAtBounds

                        FloorPlanView {
                            id: floorView

                            width: 1600
                            height: 1200

                            model: FloorPlanService.canvasModel
                            selectedTableId: root.selectedTableId

                            onTableSelected: function (tableId) {
                                root.selectedTableId = tableId
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 320
                    Layout.fillHeight: true

                    radius: 6
                    color: Theme.surface

                    border.width: 1
                    border.color: Theme.border

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16

                        spacing: 12

                        Label {
                            text: qsTr("Table Session")

                            font.bold: true
                            font.pixelSize: Theme.fontLarge

                            color: Theme.text
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Theme.border
                        }

                        ColumnLayout {
                            visible: root.selectedTableId < 0

                            Layout.fillWidth: true
                            spacing: 12

                            Label {
                                text: qsTr("Select a table for dine in")

                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontNormal
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: Theme.border
                            }

                            Label {
                                text: qsTr("Quick Orders")

                                color: Theme.text
                                font.bold: true
                                font.pixelSize: Theme.fontNormal
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Button {
                                    Layout.fillWidth: true

                                    leftPadding: 12
                                    rightPadding: 12
                                    topPadding: 12
                                    bottomPadding: 12

                                    background: Rectangle {
                                        radius: 6
                                        color: "#5bb8d6"
                                    }

                                    contentItem: Label {
                                        text: qsTr("Takeaway")

                                        color: "white"

                                        font.bold: true
                                        font.pixelSize: Theme.fontNormal

                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus

                                    onClicked: {
                                        root.orderTable = null

                                        stackView.push(orderEditorComponent, {
                                            "orderType": "takeaway"
                                        })
                                    }
                                }

                                Button {
                                    Layout.fillWidth: true

                                    leftPadding: 12
                                    rightPadding: 12
                                    topPadding: 12
                                    bottomPadding: 12

                                    background: Rectangle {
                                        radius: 6
                                        color: "#e3a34f"
                                    }

                                    contentItem: Label {
                                        text: qsTr("Delivery")

                                        color: "white"

                                        font.bold: true
                                        font.pixelSize: Theme.fontNormal

                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus

                                    onClicked: {
                                        root.orderTable = null

                                        stackView.push(orderEditorComponent, {
                                            "orderType": "delivery"
                                        })
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            visible: root.selectedTableId >= 0

                            Layout.fillWidth: true
                            spacing: 12

                            Label {
                                text: selectedTable(
                                          ) ? selectedTable(
                                                  ).canvasItem.label : qsTr(
                                                  "Unknown Table")

                                color: Theme.text
                                font.bold: true
                                font.pixelSize: Theme.fontLarge
                            }

                            Label {
                                text: qsTr(
                                          "Capacity: ") + (selectedTable(
                                                               ) ? (selectedTable(
                                                                        ).metadata.capacity
                                                                    ?? 0) : 0)

                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontNormal
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: Theme.border
                            }

                            Button {
                                text: qsTr("Create Dine-In Order")

                                Layout.fillWidth: true

                                leftPadding: 12
                                rightPadding: 12
                                topPadding: 12
                                bottomPadding: 12

                                background: Rectangle {
                                    radius: 6
                                    color: Theme.primary()
                                }

                                contentItem: Label {
                                    text: qsTr("Create Dine-In Order")

                                    color: "white"

                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal

                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus

                                onClicked: {
                                    root.orderTable = selectedTable()

                                    stackView.push(orderEditorComponent, {
                                        "orderType": "dine_in"
                                    })
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }

    Component {
        id: orderEditorComponent

        OrderEditor {
            anchors.fill: parent

            orderType: properties.orderType ?? "dine_in"

            tableId: root.orderTable
                ? root.orderTable.metadata.table_id
                : -1

            tableLabel: root.orderTable
                ? root.orderTable.canvasItem.label
                : ""
        }
    }

    Component.onCompleted: {
        FloorPlanService.loadFloors()

        Qt.callLater(function () {
            if (FloorPlanService.floorModel.count <= 0)
                return

            const first = FloorPlanService.floorModel.get(0)

            root.currentFloorId = first.id

            FloorPlanService.loadCanvas(first.id)
        })
    }
}
