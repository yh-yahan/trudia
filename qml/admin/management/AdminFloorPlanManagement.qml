import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0
import "../../components"

Item {
    id: root

    property int currentFloorId: 1

    signal requestSave
    signal requestReload(int floorId)

    Component.onCompleted: {
        FloorPlanService.loadFloors();

        if (FloorPlanService.floorModel.rowCount() > 0) {
            let first = FloorPlanService.floorModel.getFloor(0);
            if (first) {
                root.currentFloorId = first.id;
                FloorPlanService.loadCanvas(first.id);
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 100
            color: Theme.background

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

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
                            topPadding: 10
                            bottomPadding: 10

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
                                let floor = FloorPlanService.floorModel.getFloor(index);
                                if (floor) {
                                    root.currentFloorId = modelData.id;
                                    FloorPlanService.loadCanvas(modelData.id);
                                }
                            }
                        }
                    }

                    Button {
                        text: qsTr("+ New Floor")

                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10

                        background: Rectangle {
                            radius: 6
                            color: Theme.background
                            border.width: 2
                            border.color: Theme.primary()
                        }

                        contentItem: Label {
                            text: qsTr("+ New Floor")
                            color: Theme.text
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: createFloorDialog.open()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: qsTr("Add Table")
                        leftPadding: 5
                        rightPadding: 5
                        topPadding: 5
                        bottomPadding: 5

                        background: Rectangle {
                            radius: 4
                            color: Theme.background
                            border.width: 2
                            border.color: Theme.primary()
                        }

                        contentItem: Label {
                            text: qsTr("Add Table")
                            color: Theme.text
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: addTableDialog.open()
                    }

                    Button {
                        text: qsTr("Add Divider")
                        leftPadding: 5
                        rightPadding: 5
                        topPadding: 5
                        bottomPadding: 5

                        background: Rectangle {
                            radius: 4
                            color: Theme.background
                            border.width: 2
                            border.color: Theme.primary()
                        }

                        contentItem: Label {
                            text: qsTr("Add Divider")
                            color: Theme.text
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            FloorPlanService.addItem({
                                "type": "wall",
                                "x": 150,
                                "y": 150,
                                "width": 150,
                                "height": 10,
                                "label": ""
                            });
                        }
                    }
                }
            }
        }

        FloorCanvas {
            id: canvas
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: FloorPlanService.canvasModel
        }
    }

    Dialog {
        id: createFloorDialog
        anchors.centerIn: Overlay.overlay
        modal: true
        width: 360
        height: 260

        property string name: ""

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 6

            Text {
                text: qsTr("Create Floor")
                font.bold: true
                font.pixelSize: Theme.fontLarge
                color: Theme.text
            }

            Label {
                text: qsTr("Floor Name")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            TextField {
                placeholderText: qsTr("Enter Floor Name")
                onTextChanged: createFloorDialog.name = text
                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                }
                color: Theme.text
                font.pixelSize: Theme.fontNormal
                placeholderTextColor: Theme.secondaryText
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                Button {
                    text: qsTr("Create Floor")
                    background: Rectangle {
                        color: Theme.primary()
                        radius: 4
                    }

                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    contentItem: Text {
                        text: qsTr("Create Floor")
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontNormal
                    }
                    onClicked: {
                        let id = FloorPlanService.createFloor(createFloorDialog.name);

                        if (id > 0) {
                            root.currentFloorId = id;
                            FloorPlanService.loadCanvas(id);
                        }

                        createFloorDialog.close()
                    }
                }
                Button {
                    text: qsTr("Cancel")
                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    background: Rectangle {
                        color: '#6b6b6b'
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("Cancel")
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontNormal
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: createFloorDialog.close()
                }
            }
        }

        background: Rectangle {
            color: Theme.background
            radius: 6
        }
    }

    Dialog {
        id: addTableDialog
        anchors.centerIn: Overlay.overlay
        modal: true
        width: 360
        height: 320

        property int seats: 4
        property string tableType: "square"
        property string label: qsTr("Table")

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 6

            Text {
                text: qsTr("Create Table")
                font.bold: true
                font.pixelSize: Theme.fontLarge
                color: Theme.text
            }

            Label {
                text: qsTr("Table Label")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            TextField {
                placeholderText: qsTr("Enter Table Label")
                text: addTableDialog.label

                onTextChanged: {
                    addTableDialog.label = text
                }

                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                }

                color: Theme.text
                font.pixelSize: Theme.fontNormal
                placeholderTextColor: Theme.secondaryText

                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10

                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Number Of Seats")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            SpinBox {
                from: 1
                to: 20
                value: 4
                onValueChanged: addTableDialog.seats = value
                font.pixelSize: Theme.fontNormal
            }

            Label {
                text: qsTr("Type Of Table")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            ComboBox {
                model: [
                    { key: "square", value: qsTr("Square Table") },
                    { key: "rectangle", value: qsTr("Rectangle Table") },
                    { key: "circle", value: qsTr("Circle Table") }
                ]

                font.pixelSize: Theme.fontNormal

                textRole: "value"
                currentIndex: 0
                Layout.fillWidth: true

                onCurrentIndexChanged: {
                    addTableDialog.tableType = model[currentIndex].key
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                Button {
                    text: qsTr("Create Table")
                    background: Rectangle {
                        color: Theme.primary()
                        radius: 4
                    }

                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    contentItem: Text {
                        text: qsTr("Create Table")
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontNormal
                    }
                    onClicked: {
                        FloorPlanService.addItem({
                            "type": "table",
                            "capacity": addTableDialog.seats,
                            "x": 100,
                            "y": 100,
                            "width": 80,
                            "height": 80,
                            "label": addTableDialog.label,
                            "metadata": JSON.stringify({
                                "table_type": addTableDialog.tableType
                            })
                        });

                        addTableDialog.close()
                    }
                }
                Button {
                    text: qsTr("Cancel")
                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    background: Rectangle {
                        color: '#6b6b6b'
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("Cancel")
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontNormal
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: addTableDialog.close()
                }
            }
        }

        background: Rectangle {
            color: Theme.background
            radius: 6
        }
    }

    Shortcut {
        sequence: StandardKey.Save

        onActivated: {
            if (root.currentFloorId > 0) {
                FloorPlanService.saveCanvas(root.currentFloorId);
            } else {
                console.warn("No floor selected, cannot save");
            }
        }
    }
}
