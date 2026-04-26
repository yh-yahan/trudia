import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

ScrollView {
    id: root
    anchors.fill: parent
    contentWidth: parent.width

    property string printerInterface: "ESC/POS (Raw)"
    property string connectionType: "Network (TCP/IP)"
    property string ipAddress: ""
    property int port: 0
    property string comPort: ""
    property int baudRate: 0
    property string parity: ""
    property int dataBits: 0
    property int stopBits: 0
    property string flowControl: ""
    property string paperWidth: "80mm"
    property string cutMode: "Full Cut"
    property string errorMessage: ""
    property var printerModel: []

    function loadPrinter() {
        var data = SettingService.getPrinterSetting()

        if (!data || Object.keys(data).length === 0) {
            printerModel = []
            return
        }

        printerModel = [data]
    }

    function loadPrinterSettings() {
        var data = SettingService.getPrinterSetting()
        printerInterface = data["printer_interface"] || "ESC/POS (Raw)"
        connectionType = data["connection_type"] || "Network (TCP/IP)"
        ipAddress = data["ip_address"] || ""
        port = data["port"] || 0
        comPort = data["com_port"] || ""
        baudRate = data["baud_rate"] || 0
        parity = data["parity"] || ""
        dataBits = data["data_bits"] || 0
        stopBits = data["stop_bits"] || 0
        flowControl = data["flow_control"] || ""
        paperWidth = data["paper_width"] || "80mm"
        cutMode = data["cut_mode"] || "Full Cut"
        errorMessage = ""
    }

    Component.onCompleted: {
        loadPrinterSettings()
        loadPrinter()
    }

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

                model: printerModel

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
                            text: qsTr("Printer")
                            font.bold: true
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        Text {
                            text: modelData.com_port || qsTr("Unknown printer")
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        RowLayout {
                            spacing: 10
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
                                    console.log("modelData:", JSON.stringify(modelData))
                                    console.log("com_port:", modelData.com_port)
                                    USBPrinterService.testPrint(
                                                modelData.com_port)
                                }
                            }
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
                                    if (SettingService.removePrinterSetting()) {
                                        root.printerModel = []
                                        root.loadPrinterSettings()
                                    } else {
                                        root.errorMessage = qsTr(
                                                    "Failed to remove printer")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // paper and format
        ColumnLayout {
            spacing: 15

            Text {
                Layout.fillWidth: true
                text: qsTr("Paper and Format")
                font.bold: true
                color: Theme.secondaryText
                font.pixelSize: Theme.fontNormal
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                spacing: 10

                Label {
                    text: qsTr("Paper Width")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                }

                ComboBox {
                    id: paperWidthComboBox
                    Layout.fillWidth: true
                    model: ["58mm", "80mm"]
                    Component.onCompleted: {
                        var defaultIndex = model.indexOf(root.paperWidth)
                        currentIndex = defaultIndex >= 0 ? defaultIndex : 1
                    }

                    onCurrentIndexChanged: {
                        root.paperWidth = model[currentIndex]
                    }

                    font.pixelSize: Theme.fontNormal
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8
                }

                Label {
                    text: qsTr("Cut Mode")
                    color: "white"
                    font.pixelSize: Theme.fontNormal
                }

                ComboBox {
                    Layout.fillWidth: true

                    model: [{
                            "text": qsTr("Full Cut"),
                            "value": "Full Cut"
                        }, {
                            "text": qsTr("Partial Cut"),
                            "value": "Partial Cut"
                        }, {
                            "text": qsTr("No Cut"),
                            "value": "No Cut"
                        }]

                    textRole: "text"

                    currentIndex: model.findIndex(
                                      item => item.value === root.cutMode)

                    onCurrentIndexChanged: {
                        root.cutMode = model[currentIndex].value
                    }

                    font.pixelSize: Theme.fontNormal
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 20

        Button {
            text: qsTr("Save")
            width: 60
            leftPadding: 20
            rightPadding: 20
            topPadding: 10
            bottomPadding: 10
            Layout.topMargin: 10
            Layout.leftMargin: 20
            background: Rectangle {
                color: Theme.primary()
                radius: 4
            }
            contentItem: Text {
                text: qsTr("Save")
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
                var map = {
                    "printer_interface": root.printerInterface,
                    "connection_type": root.connectionType,
                    "ip_address": root.ipAddress,
                    "port": root.port,
                    "com_port": root.comPort,
                    "baud_rate": root.baudRate,
                    "parity": root.parity,
                    "data_bits": root.dataBits,
                    "stop_bits": root.stopBits,
                    "flow_control": root.flowControl,
                    "paper_width": root.paperWidth,
                    "cut_mode": root.cutMode
                }

                if (SettingService.savePrinterSettingMap(map)) {
                    root.errorMessage = ""
                    loadPrinterSettings()
                } else {
                    root.errorMessage = qsTr("Failed to save printer settings.")
                }
            }
        }

        Text {
            text: root.errorMessage
            color: "red"
            font.bold: true
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            font.pixelSize: Theme.fontNormal
        }
    }

    Popup {
        id: addPrinterPopup
        modal: true
        focus: true
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        width: 400
        height: 300
        background: Rectangle {
            color: Theme.background
            radius: 8
        }

        ColumnLayout {
            Item {
                id: printerRoot

                width: 400
                height: 300

                property string selectedPrinter: ""
                property string testStatus: ""

                ListModel {
                    id: portsModel
                }

                Component.onCompleted: {
                    var list = USBPrinterService.getAvailablePrinters()

                    portsModel.clear()

                    for (var i = 0; i < list.length; i++) {
                        portsModel.append(list[i])
                    }

                    console.log("Loaded:", portsModel.count)
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
                        Layout.preferredHeight: 150
                        Layout.preferredWidth: 130
                        clip: true

                        model: portsModel

                        delegate: RadioButton {
                            required property string name
                            required property string port

                            checked: name === printerRoot.selectedPrinter

                            onClicked: printerRoot.selectedPrinter = name

                            contentItem: Text {
                                text: "     " + name
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }
                        }
                    }

                    RowLayout {
                        spacing: 10

                        Button {
                            text: "Cancel"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: 'transparent'
                                border.color: Theme.primary()
                                border.width: 1
                                radius: 4
                            }
                            contentItem: Text {
                                text: qsTr("Cancel")
                                font.bold: true
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: Theme.primary()
                                font.pixelSize: Theme.fontNormal
                            }

                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                addPrinterPopup.close()
                            }
                        }

                        Button {
                            text: "Test Printer"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: '#5F7DDC'
                                radius: 4
                            }
                            contentItem: Text {
                                text: qsTr("Test Printer")
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
                                printerRoot.testStatus = qsTr("Testing...")
                                var success = USBPrinterService.testPrint(
                                            printerRoot.selectedPrinter)
                                printerRoot.testStatus = success ? "Success" : "Failed"
                            }
                        }

                        Button {
                            text: "Add Printer"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: Theme.primary()
                                radius: 4
                            }
                            contentItem: Text {
                                text: qsTr("Add Printer")
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
                                if (!printerRoot.selectedPrinter
                                        || printerRoot.selectedPrinter.length === 0) {
                                    printerRoot.testStatus = qsTr(
                                                "No printer selected")
                                    return
                                }

                                var map = {
                                    "connection_type": "USB",
                                    "com_port": printerRoot.selectedPrinter
                                }

                                if (SettingService.savePrinterSettingMap(map)) {
                                    addPrinterPopup.close()
                                    root.loadPrinterSettings()
                                } else {
                                    printerRoot.testStatus = qsTr(
                                                "Failed to add printer")
                                }

                                root.loadPrinter()
                            }
                        }
                    }

                    RowLayout {
                        Text {
                            text: testStatus
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
}
