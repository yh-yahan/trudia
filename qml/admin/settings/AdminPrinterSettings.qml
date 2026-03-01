import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Xeno.Services 1.0

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
    property int charPerLine: 42
    property string cutMode: "Full Cut"
    property string errorMessage: ""

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
        charPerLine = data["char_per_line"] || 42
        cutMode = data["cut_mode"] || "Full Cut"
        errorMessage = ""
    }

    Component.onCompleted: loadPrinterSettings()

    ColumnLayout {
        width: parent.width
        spacing: 30

        // section title
        Text {
            text: qsTr("Printing")
            font.bold: true
            font.pixelSize: 26
            color: "white"
        }

        // printer configuration
        ColumnLayout {
            spacing: 15

            Text {
                Layout.fillWidth: true
                text: qsTr("Printer Configuration")
                font.bold: true
                color: "#c9c9c9"
                font.pointSize: 16
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                spacing: 10

                Label {
                    text: qsTr("Printer Interface")
                    color: "white"
                }

                ComboBox {
                    Layout.fillWidth: true
                    model: ["ESC/POS (Raw)"]
                    currentIndex: 0

                    onCurrentIndexChanged: {
                        root.printerInterface = model[currentIndex]
                    }

                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8
                }

                Label {
                    text: qsTr("Connection Type")
                    color: "white"
                }

                ComboBox {
                    id: connectionTypeComboBox
                    Layout.fillWidth: true
                    model: ["Network (TCP/IP)", "USB (Virtual COM)", "Serial (COM)"]
                    currentIndex: 0

                    onCurrentIndexChanged: {
                        root.connectionType = model[currentIndex]
                    }

                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    visible: connectionTypeComboBox.currentText === "Network (TCP/IP)"

                    Label {
                        text: qsTr("IP Address")
                        color: "white"
                    }

                    TextField {
                        Layout.fillWidth: true
                        placeholderText: qsTr("IP Address")
                        text: root.ipAddress
                        onTextChanged: root.ipAddress = text
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10
                        color: "white"
                        placeholderTextColor: "#b5b5b5"
                        background: Rectangle {
                            color: "#1f1f1f"
                            radius: 4
                            border.color: "#888888"
                        }
                    }

                    Label {
                        text: qsTr("Port")
                        color: "white"
                    }

                    TextField {
                        Layout.preferredWidth: 180
                        placeholderText: qsTr("Port")
                        text: root.port === 0 ? "" : root.port.toString()
                        onTextChanged: root.port = parseInt(text) || 0
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10
                        color: "white"
                        placeholderTextColor: "#b5b5b5"
                        background: Rectangle {
                            color: "#1f1f1f"
                            radius: 4
                            border.color: "#888888"
                        }
                    }
                }

                ColumnLayout {
                    spacing: 10
                    visible: connectionTypeComboBox.currentText !== "Network (TCP/IP)"

                    Label {
                        text: qsTr("COM Port")
                        color: "white"
                    }
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: qsTr("COM Port")
                        text: root.comPort
                        onTextChanged: root.comPort = text
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10
                        color: "white"
                        placeholderTextColor: "#b5b5b5"
                        background: Rectangle {
                            color: "#1f1f1f"
                            radius: 4
                            border.color: "#888888"
                        }
                    }

                    Label {
                        text: qsTr("Baud Rate")
                        color: "white"
                    }
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: qsTr("Baud Rate")
                        text: root.baudRate === 0 ? "" : root.baudRate.toString(
                                                        )
                        onTextChanged: root.baudRate = parseInt(text) || 0
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10
                        color: "white"
                        placeholderTextColor: "#b5b5b5"
                        background: Rectangle {
                            color: "#1f1f1f"
                            radius: 4
                            border.color: "#888888"
                        }
                    }

                    Label {
                        text: qsTr("Parity")
                        color: "white"
                    }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["None", "Even", "Odd", "Mark", "Space"]
                        currentIndex: 0
                        onCurrentIndexChanged: {
                            root.parity = model[currentIndex]
                        }
                        leftPadding: 12
                        rightPadding: 12
                        topPadding: 8
                        bottomPadding: 8
                    }

                    Label {
                        text: qsTr("Data Bits")
                        color: "white"
                    }
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: qsTr("Data Bits")
                        text: root.dataBits === 0 ? "" : root.dataBits.toString(
                                                        )
                        onTextChanged: root.dataBits = parseInt(text) || 0
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10
                        color: "white"
                        placeholderTextColor: "#b5b5b5"
                        background: Rectangle {
                            color: "#1f1f1f"
                            radius: 4
                            border.color: "#888888"
                        }
                    }

                    Label {
                        text: qsTr("Stop Bits")
                        color: "white"
                    }
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: qsTr("Stop Bits")
                        text: root.stopBits === 0 ? "" : root.stopBits.toString(
                                                        )
                        onTextChanged: root.stopBits = parseInt(text) || 0
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10
                        color: "white"
                        placeholderTextColor: "#b5b5b5"
                        background: Rectangle {
                            color: "#1f1f1f"
                            radius: 4
                            border.color: "#888888"
                        }
                    }

                    Label {
                        text: qsTr("Flow Control")
                        color: "white"
                    }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["None", "XON/XOFF", "RTS/CTS"]
                        currentIndex: 0
                        onCurrentIndexChanged: {
                            root.flowControl = model[currentIndex]
                        }
                        leftPadding: 12
                        rightPadding: 12
                        topPadding: 8
                        bottomPadding: 8
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
                color: "#c9c9c9"
                font.pointSize: 16
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                spacing: 10

                Label {
                    text: qsTr("Paper Width")
                    color: "white"
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

                        charPerLineComboBox.model = root.paperWidth
                                === "80mm" ? ["42", "48", "56"] : ["32", "36", "42"]

                        if (!charPerLineComboBox.model.includes(
                                    root.charPerLine.toString())) {
                            root.charPerLine = parseInt(
                                        charPerLineComboBox.model[0])
                        }
                    }

                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8
                }

                Label {
                    text: qsTr("Characters Per Line")
                    color: "white"
                }

                ComboBox {
                    id: charPerLineComboBox
                    Layout.fillWidth: true
                    model: root.paperWidth === "80mm" ? ["42", "48", "56"] : ["32", "36", "42"]
                    currentIndex: model.indexOf(root.charPerLine.toString())

                    onCurrentIndexChanged: {
                        root.charPerLine = parseInt(model[currentIndex])
                    }

                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8
                }

                Label {
                    text: qsTr("Cut Mode")
                    color: "white"
                }

                ComboBox {
                    Layout.fillWidth: true
                    model: ["Full Cut", "Partial Cut", "No Cut"]
                    currentIndex: model.indexOf(root.cutMode)

                    onCurrentIndexChanged: {
                        root.cutMode = model[currentIndex]
                    }

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
                color: "#9a7bff"
                radius: 4
            }
            contentItem: Text {
                text: qsTr("Save")
                font.bold: true
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white"
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
                    "char_per_line": root.charPerLine,
                    "cut_mode": root.cutMode
                }

                if (SettingService.savePrinterSettingMap(map)) {
                    root.errorMessage = ""
                    loadPrinterSettings()
                } else {
                    root.errorMessage = "Failed to save printer settings."
                }
            }
        }

        Text {
            text: root.errorMessage
            color: "red"
            font.bold: true
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}
