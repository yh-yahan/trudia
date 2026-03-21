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
    property string cutMode: "Full Cut"
    property string errorMessage: ""
    property var printerModel: []

    function loadPrinter() {
        var data = SettingService.getPrinterSetting();

        if (!data || Object.keys(data).length === 0) {
            printerModel = [];
            return;
        }

        printerModel = [data];
    }

    function loadPrinterSettings() {
        var data = SettingService.getPrinterSetting();
        printerInterface = data["printer_interface"] || "ESC/POS (Raw)";
        connectionType = data["connection_type"] || "Network (TCP/IP)";
        ipAddress = data["ip_address"] || "";
        port = data["port"] || 0;
        comPort = data["com_port"] || "";
        baudRate = data["baud_rate"] || 0;
        parity = data["parity"] || "";
        dataBits = data["data_bits"] || 0;
        stopBits = data["stop_bits"] || 0;
        flowControl = data["flow_control"] || "";
        paperWidth = data["paper_width"] || "80mm";
        cutMode = data["cut_mode"] || "Full Cut";
        errorMessage = "";
    }

    Component.onCompleted: {
        loadPrinterSettings();
        loadPrinter();
    }

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

        // printers
        ColumnLayout {
            spacing: 15

            Text {
                Layout.fillWidth: true
                text: qsTr("Printers")
                font.bold: true
                color: "#c9c9c9"
                font.pointSize: 16
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
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: {
                        addPrinterPopup.open();
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

                    ColumnLayout {
                        id: contentColumn
                        anchors.fill: parent
                        anchors.topMargin: 12
                        anchors.bottomMargin: 12
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 6

                        Text {
                            text: "Printer"
                            font.bold: true
                            color: "white"
                        }

                        Text {
                            text: {
                                if (modelData.connection_type === "USB")
                                    return "USB - " + modelData.com_port;

                                if (modelData.connection_type === "Network")
                                    return "Network - " + modelData.ip_address + ":" + modelData.port;

                                if (modelData.connection_type === "Serial")
                                    return "Serial - " + modelData.com_port;

                                return "Unknown";
                            }
                            color: "#aaaaaa"
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
                                    color: '#5aa2be'
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: qsTr("Test")
                                    font.bold: true
                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: "white"
                                }
                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus
                                onClicked: {
                                    UsbPrinterManager.testPrint(modelData.com_port);
                                }
                            }
                            Button {
                                text: "Edit"
                                topPadding: 6
                                bottomPadding: 6
                                leftPadding: 12
                                rightPadding: 12
                                font.pointSize: 10
                                background: Rectangle {
                                    color: '#c553a1'
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: qsTr("Edit")
                                    font.bold: true
                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: "white"
                                }
                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus
                                onClicked: {}
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
                        var defaultIndex = model.indexOf(root.paperWidth);
                        currentIndex = defaultIndex >= 0 ? defaultIndex : 1;
                    }

                    onCurrentIndexChanged: {
                        root.paperWidth = model[currentIndex];
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
                        root.cutMode = model[currentIndex];
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
                    "cut_mode": root.cutMode
                };

                if (SettingService.savePrinterSettingMap(map)) {
                    root.errorMessage = "";
                    loadPrinterSettings();
                } else {
                    root.errorMessage = "Failed to save printer settings.";
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

    Popup {
        id: addPrinterPopup
        modal: true
        focus: true
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        width: 400
        height: 300
        background: Rectangle {
            color: "#2b2b2b"
            radius: 8
        }

        property string connectionType: "USB"
        property int step: 0 // 0 = select type, 1 = configure

        onOpened: {
            step = 0;
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            ColumnLayout {
                visible: addPrinterPopup.step === 0

                Text {
                    text: qsTr("Add Printer")
                    font.bold: true
                    font.pixelSize: 22
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: qsTr("Select Connection Type:")
                    color: "white"
                    font.pointSize: 14
                }

                ColumnLayout {
                    id: connectionTypeGroup
                    spacing: 10

                    RadioButton {
                        id: usbRadio
                        text: qsTr("USB")
                        checked: true
                        contentItem: Text {
                            text: qsTr("     USB")
                            color: "white"
                        }
                        onClicked: addPrinterPopup.connectionType = "USB"
                    }
                }

                // next button
                RowLayout {
                    Button {
                        text: qsTr("Next")
                        width: 80
                        leftPadding: 12
                        rightPadding: 12
                        topPadding: 12
                        bottomPadding: 12
                        Layout.topMargin: 15
                        Layout.fillWidth: true
                        font.bold: true
                        background: Rectangle {
                            color: "#9a7bff"
                            radius: 4
                        }
                        contentItem: Text {
                            text: qsTr("Next")
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.centerIn: parent
                            color: "white"
                        }
                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus
                        onClicked: {
                            addPrinterPopup.step = 1;
                        }
                    }
                }
            }

            Loader {
                id: printerStepLoader
                visible: addPrinterPopup.step === 1
                sourceComponent: {
                    if (addPrinterPopup.connectionType === "USB")
                        return usbComponent;
                    if (addPrinterPopup.connectionType === "Network")
                        return networkComponent;
                    if (addPrinterPopup.connectionType === "Serial")
                        return serialComponent;
                    return null;
                }
            }
        }

        Component {
            id: usbComponent

            Item {
                width: 400
                height: 300

                property string selectedPort: ""
                property string testStatus: ""

                ListModel {
                    id: portsModel
                }

                Component.onCompleted: {
                    var list = USBPrinterService.getAvailablePrinters();

                    portsModel.clear();

                    for (var i = 0; i < list.length; i++) {
                        portsModel.append(list[i]);
                    }

                    console.log("Loaded:", portsModel.count);
                }

                ColumnLayout {
                    spacing: 10

                    Text {
                        text: "USB Printers"
                        color: "white"
                        font.bold: true
                    }

                    Text {
                        text: portsModel.count === 0 ? "No printers found" : "Select a printer"
                        color: "lightgray"
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        clip: true

                        model: portsModel

                        delegate: RadioButton {
                            required property string name
                            required property string port

                            checked: port === selectedPort

                            onClicked: selectedPort = port

                            contentItem: Text {
                                text: "     " + name + " (" + port + ")"
                                color: "white"
                            }
                        }
                    }

                    RowLayout {
                        spacing: 10

                        Button {
                            text: "Back"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: 'transparent'
                                border.color: "#9a7bff"
                                border.width: 1
                                radius: 4
                            }
                            contentItem: Text {
                                text: qsTr("Back")
                                font.bold: true
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "#9a7bff"
                            }

                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            onClicked: addPrinterPopup.step = 0
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
                            }
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                testStatus = "Testing...";
                                var success = USBPrinterService.testPrint(selectedPort);
                                testStatus = success ? "Success" : "Failed";
                            }
                        }

                        Button {
                            text: "Add Printer"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: '#9a7bff'
                                radius: 4
                            }
                            contentItem: Text {
                                text: qsTr("Add Printer")
                                font.bold: true
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                if (!selectedPort || selectedPort.length === 0) {
                                    testStatus = "No printer selected";
                                    return;
                                }

                                var map = {
                                    "connection_type": "USB",
                                    "com_port": selectedPort
                                };

                                if (SettingService.savePrinterSettingMap(map)) {
                                    addPrinterPopup.close();
                                    root.loadPrinterSettings();
                                } else {
                                    testStatus = "Failed to save";
                                }

                                root.loadPrinter();
                            }
                        }
                    }

                    RowLayout {
                        Text {
                            text: testStatus
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter

                            color: testStatus.indexOf("Success") !== -1 ? "lightgreen" : (testStatus === "Testing..." ? "orange" : "red")
                        }
                    }
                }
            }
        }
    }
}
