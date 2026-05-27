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

            if (Number(item.table_id) === Number(root.selectedTableId)) {
                return {
                    "canvasItem": item
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
                        checked: root.currentFloorId
                                 < 0 ? index === 0 : root.currentFloorId === modelData.id

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
                                                                        ).canvasItem.capacity
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

                            Button {
                                text: qsTr("Create Reservation")

                                Layout.fillWidth: true

                                leftPadding: 12
                                rightPadding: 12
                                topPadding: 12
                                bottomPadding: 12

                                background: Rectangle {
                                    radius: 6
                                    color: "#4faba1"
                                }

                                contentItem: Label {
                                    text: qsTr("Create Reservation")

                                    color: "white"

                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal

                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus

                                onClicked: {
                                    reservationDialog.open()
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

    Dialog {
        id: reservationDialog

        anchors.centerIn: Overlay.overlay
        modal: true
        width: 580
        height: 520

        property date selectedDate: new Date()

        background: Rectangle {
            color: Theme.background
            radius: 6
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 16
            width: parent.width

            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 6

                Text {
                    text: qsTr("Create Reservation")
                    font.bold: true
                    font.pixelSize: Theme.fontLarge
                    color: Theme.text
                }

                Label {
                    text: qsTr("Customer Name")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                }

                TextField {
                    id: customerNameField
                    Layout.fillWidth: true

                    placeholderText: qsTr("Enter Customer Name")

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
                }

                Label {
                    text: qsTr("Customer Phone")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                }

                TextField {
                    id: customerPhoneField
                    Layout.fillWidth: true

                    placeholderText: qsTr("Enter Customer Phone")

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
                }

                Label {
                    text: qsTr("Number Of Guests")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                }

                SpinBox {
                    id: paxSpinBox
                    from: 1
                    to: 100
                    value: 2
                    font.pixelSize: Theme.fontNormal
                }

                Label {
                    text: qsTr("Reservation Date")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                    Layout.bottomMargin: 15
                }

                DatePicker {
                    id: reservationDatePicker
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Reservation Time")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                    Layout.topMargin: 15
                    Layout.bottomMargin: 15
                }

                TimePicker {
                    id: reservationTimePicker
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Duration (minutes)")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                    Layout.topMargin: 15
                }

                SpinBox {
                    id: durationSpinBox
                    from: 30
                    to: 300
                    stepSize: 30
                    value: 90
                    editable: true
                    font.pixelSize: Theme.fontNormal
                }

                Label {
                    text: qsTr("Notes")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                }

                TextArea {
                    id: notesField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80

                    placeholderText: qsTr("Enter notes")

                    background: Rectangle {
                        color: Theme.surface
                        radius: 4
                    }

                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                    placeholderTextColor: Theme.secondaryText
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8
                    Layout.topMargin: 15
                    Layout.bottomMargin: 15

                    Button {
                        text: qsTr("Cancel")

                        background: Rectangle {
                            color: "#6b6b6b"
                            radius: 4
                        }

                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 5
                        bottomPadding: 5

                        contentItem: Text {
                            text: qsTr("Cancel")
                            color: "white"
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontNormal
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: reservationDialog.close()
                    }

                    Button {
                        text: qsTr("Create Reservation")

                        background: Rectangle {
                            color: Theme.primary()
                            radius: 4
                        }

                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 5
                        bottomPadding: 5

                        contentItem: Text {
                            text: qsTr("Create Reservation")
                            color: "white"
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontNormal
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            const date = reservationDatePicker.selectedDate
                            const hour = reservationTimePicker.hour
                            const minute = reservationTimePicker.minute

                            const reservationDateTime = new Date(date.getFullYear(
                                                                     ),
                                                                 date.getMonth(
                                                                     ),
                                                                 date.getDate(
                                                                     ),
                                                                 reservationTimePicker.hour,
                                                                 reservationTimePicker.minute,
                                                                 0)

                            const success = ReservationService.createReservation({
                                                                                     "customerName": customerNameField.text,
                                                                                     "customerPhone": customerPhoneField.text,
                                                                                     "pax": paxSpinBox.value,
                                                                                     "tableId": root.selectedTableId,
                                                                                     "reservationDateTime": reservationDateTime,
                                                                                     "durationMinutes": durationSpinBox.value,
                                                                                     "status": "booked",
                                                                                     "notes": notesField.text
                                                                                 })

                            if (!success) {
                                console.log("Reservation conflict")
                                return
                            }

                            reservationDialog.close()
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

            tableId: root.orderTable ? root.orderTable.canvasItem.table_id : -1

            tableLabel: root.orderTable ? root.orderTable.canvasItem.label : ""
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
