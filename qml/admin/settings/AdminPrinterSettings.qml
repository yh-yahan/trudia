import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

ScrollView {
    id: root
    anchors.fill: parent
    contentWidth: parent.width

    property string role: "receipt"
    property string paperWidth: "58"
    property string cutMode: "full"
    property string errorMessage: ""
    property var printers: []

    function loadPrinters() {
        printers = SettingService.getPrinters() || []
    }

    Component.onCompleted: loadPrinters()

    ColumnLayout {
        width: parent.width
        spacing: 30

        // section title
        Text {
            text: qsTr("Printing")
            font.bold: true
            font.pixelSize: Theme.fontLarge
            color: Theme.text
        }

        // printers
        ColumnLayout {
            spacing: 15

            Text {
                Layout.fillWidth: true
                text: qsTr("Printers")
                font.bold: true
                color: Theme.secondaryText
                font.pixelSize: Theme.fontNormal
            }

            // add printer
            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                spacing: 10

                Button {
                    text: qsTr("+ Add Printer")
                    leftPadding: 8
                    rightPadding: 8
                    topPadding: 8
                    bottomPadding: 8
                    background: Rectangle {
                        color: '#6c7ddd'
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("+ Add Printer")
                        font.bold: true
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                        font.pixelSize: Theme.fontNormal
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: {
                        printerRoot.isEditMode = false
                        printerRoot.editingPrinterId = -1
                        printerRoot.selectedPrinter = ""
                        printerRoot.role = "receipt"
                        printerRoot.paperWidth = 58
                        printerRoot.cutMode = "none"
                        printerRoot.testStatus = ""

                        addPrinterPopup.open()
                    }
                }
            }

            // printers list
            ListView {
                width: parent.width
                height: contentHeight
                spacing: 12
                clip: false
                interactive: false

                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight

                model: printers

                delegate: Rectangle {
                    width: ListView.view.width
                    height: contentColumn.implicitHeight + 24
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 8
                    anchors.bottomMargin: 8
                    color: Theme.surface

                    ColumnLayout {
                        id: contentColumn
                        anchors.fill: parent
                        anchors.topMargin: 12
                        anchors.bottomMargin: 12
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 6

                        Text {
                            text: {
                                switch (modelData.role) {
                                case "receipt":
                                    return qsTr("Receipt Printer")
                                case "kitchen":
                                    return qsTr("Kitchen Printer")
                                case "both":
                                    return qsTr("Receipt + Kitchen Printer")
                                default:
                                    return qsTr("Printer")
                                }
                            }
                            font.bold: true
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        Text {
                            text: modelData.system_name
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        RowLayout {
                            spacing: 10

                            Button {
                                text: "Edit"
                                topPadding: 6
                                bottomPadding: 6
                                leftPadding: 12
                                rightPadding: 12

                                background: Rectangle {
                                    color: '#ebac00'
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: qsTr("Edit")
                                    font.bold: true
                                    anchors.centerIn: parent
                                    color: "white"
                                    font.pixelSize: Theme.fontNormal
                                }

                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus

                                onClicked: {
                                    printerRoot.loadPrinterForEdit(modelData)
                                    addPrinterPopup.open()
                                }
                            }

                            // test btn
                            Button {
                                text: "Test"
                                topPadding: 6
                                bottomPadding: 6
                                leftPadding: 12
                                rightPadding: 12
                                font.pointSize: 10
                                background: Rectangle {
                                    color: '#4faba1'
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: qsTr("Test")
                                    font.bold: true
                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: "white"
                                    font.pixelSize: Theme.fontNormal
                                }
                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus
                                onClicked: {
                                    console.log("system_name: ", modelData.system_name)
                                    WindowsPrinterService.testPrint(modelData)
                                }
                            }

                            // remove btn
                            Button {
                                text: "Remove"
                                topPadding: 6
                                bottomPadding: 6
                                leftPadding: 12
                                rightPadding: 12
                                font.pointSize: 10
                                background: Rectangle {
                                    color: '#e53935'
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: qsTr("Remove")
                                    font.bold: true
                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: "white"
                                    font.pixelSize: Theme.fontNormal
                                }
                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus
                                onClicked: {
                                    if (SettingService.removePrinter(modelData.id)) {
                                        loadPrinters()
                                    } else {
                                        errorMessage = qsTr("Failed to remove printer")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: addPrinterPopup
        modal: true
        focus: true
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        width: 400
        height: 500

        background: Rectangle {
            color: Theme.background
            radius: 8
        }

        ColumnLayout {
            Item {
                id: printerRoot

                width: 400
                height: 500

                property string selectedPrinter: ""
                property string testStatus: ""

                property string role: "receipt"
                property int paperWidth: 58
                property string cutMode: "none"

                property bool isEditMode: false
                property int editingPrinterId: -1

                function loadPrinterForEdit(printer) {
                    isEditMode = true
                    editingPrinterId = printer.id

                    selectedPrinter = printer.system_name
                    role = printer.role
                    paperWidth = printer.paper_width
                    cutMode = printer.cut_mode

                    testStatus = ""
                }

                ListModel {
                    id: portsModel
                }

                Component.onCompleted: {
                    var list = WindowsPrinterService.getAvailablePrinters()

                    portsModel.clear()
                    for (var i = 0; i < list.length; i++) {
                        portsModel.append(list[i])
                    }
                }

                ColumnLayout {
                    spacing: 10

                    Text {
                        text: qsTr("Printers")
                        color: Theme.text
                        font.bold: true
                        font.pixelSize: Theme.fontNormal
                    }

                    Text {
                        text: portsModel.count === 0 ? qsTr("No printers found") : qsTr(
                                                           "Select a printer")
                        color: Theme.secondaryText
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        clip: true

                        model: portsModel

                        delegate: RadioButton {
                            required property string system_name

                            checked: system_name === printerRoot.selectedPrinter

                            onClicked: printerRoot.selectedPrinter = system_name

                            contentItem: Text {
                                text: "     " + system_name
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }
                        }
                    }

                    Text {
                        text: qsTr("Role")
                        color: Theme.secondaryText
                    }

                    ComboBox {
                        Layout.fillWidth: true
                        font.pixelSize: Theme.fontNormal

                        model: [{
                                "value": "receipt",
                                "label": qsTr("Receipt")
                            }, {
                                "value": "kitchen",
                                "label": qsTr("Kitchen Ticket")
                            }, {
                                "value": "both",
                                "label": qsTr("Receipt + Kitchen Ticket")
                            }]

                        textRole: "label"
                        valueRole: "value"

                        currentValue: printerRoot.role
                        onActivated: printerRoot.role = currentValue
                    }

                    Text {
                        text: qsTr("Paper Width")
                        color: Theme.secondaryText
                    }

                    ComboBox {
                        Layout.fillWidth: true
                        font.pixelSize: Theme.fontNormal

                        model: [{
                                "value": 58,
                                "label": "58 mm"
                            }, {
                                "value": 80,
                                "label": "80 mm"
                            }]

                        textRole: "label"
                        valueRole: "value"

                        currentValue: printerRoot.paperWidth
                        onActivated: printerRoot.paperWidth = currentValue
                    }

                    Text {
                        text: qsTr("Cut Mode")
                        color: Theme.secondaryText
                    }

                    ComboBox {
                        Layout.fillWidth: true
                        font.pixelSize: Theme.fontNormal

                        model: [{
                                "value": "full",
                                "label": qsTr("Full Cut")
                            }, {
                                "value": "partial",
                                "label": qsTr("Partial Cut")
                            }, {
                                "value": "none",
                                "label": qsTr("None")
                            }]

                        textRole: "label"
                        valueRole: "value"

                        currentValue: printerRoot.cutMode
                        onActivated: printerRoot.cutMode = currentValue
                    }

                    RowLayout {
                        spacing: 10
                        Layout.topMargin: 15

                        Button {
                            text: "Cancel"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "transparent"
                                border.color: Theme.primary()
                                border.width: 1
                                radius: 4
                            }

                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus

                            contentItem: Text {
                                text: qsTr("Cancel")
                                color: Theme.primary()
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: Theme.fontNormal
                            }

                            onClicked: addPrinterPopup.close()
                        }

                        Button {
                            text: "Test Printer"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "#5F7DDC"
                                radius: 4
                            }

                            contentItem: Text {
                                text: qsTr("Test Printer")
                                color: "white"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: Theme.fontNormal
                            }

                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                printerRoot.testStatus = qsTr("Testing...")

                                var success = WindowsPrinterService.testPrint({
                                    "system_name": printerRoot.selectedPrinter,
                                    "role": printerRoot.role,
                                    "paper_width": printerRoot.paperWidth,
                                    "cut_mode": printerRoot.cutMode
                                })

                                printerRoot.testStatus = success ? "Success" : "Failed"
                            }
                        }

                        Button {
                            text: printerRoot.isEditMode ? qsTr("Save Changes") : qsTr("Add Printer")
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: Theme.primary()
                                radius: 4
                            }

                            contentItem: Text {
                                text: printerRoot.isEditMode ? qsTr("Save Changes") : qsTr("Add Printer")
                                color: "white"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: Theme.fontNormal
                            }

                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                if (!printerRoot.selectedPrinter
                                        || printerRoot.selectedPrinter.length === 0) {
                                    printerRoot.testStatus = qsTr("No printer selected")
                                    return
                                }

                                var map = {
                                    "name": printerRoot.selectedPrinter,
                                    "system_name": printerRoot.selectedPrinter,
                                    "role": printerRoot.role,
                                    "paper_width": printerRoot.paperWidth,
                                    "cut_mode": printerRoot.cutMode
                                }

                                var success

                                map["id"] = printerRoot.isEditMode ? printerRoot.editingPrinterId : 0
                                success = SettingService.savePrinter(map)

                                if (success) {
                                    addPrinterPopup.close()
                                    root.loadPrinters()
                                } else {
                                    printerRoot.testStatus = qsTr(
                                        printerRoot.isEditMode ? "Failed to update printer"
                                                            : "Failed to add printer")
                                }
                            }
                        }
                    }

                    Text {
                        text: printerRoot.testStatus
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Theme.fontNormal

                        color: printerRoot.testStatus.indexOf("Success")
                               !== -1 ? "lightgreen" : (printerRoot.testStatus
                                                        === "Testing..." ? "orange" : "red")
                    }
                }
            }
        }
    }
}
