import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Xeno.Services 1.0

Item {
    width: 1200
    height: 700

    property var sessions: []
    property var selectedSession: null
    property var checkoutDetails: []

    property bool canCheckout: false

    function reloadSessions() {
        sessions = CheckoutService.getActiveOrdersForCheckout()
        selectedSession = null
        checkoutDetails = []
    }

    function normalizeStatus(status) {
        if (!status)
            return ""
        return (status + "").trim().toLowerCase()
    }

    function isOrderServed(order) {
        return normalizeStatus(order ? order.status : "") === "served"
    }

    function sessionIsFullyServed(details) {
        if (!details || details.length === 0)
            return false
        for (var i = 0; i < details.length; i++) {
            if (!isOrderServed(details[i])) {
                return false
            }
        }
        return true
    }

    Component.onCompleted: {
        reloadSessions()
    }

    onCheckoutDetailsChanged: {
        canCheckout = sessionIsFullyServed(checkoutDetails)
    }

    RowLayout {
        anchors.fill: parent
        spacing: 6

        ListView {
            Layout.preferredWidth: 420
            Layout.fillHeight: true
            model: sessions
            spacing: 10

            delegate: Rectangle {
                width: parent.width
                height: 72
                radius: 6
                color: selectedSession === modelData ? "#2a2a2a" : "#1e1e1e"
                border.color: selectedSession === modelData ? "#9a7bff" : "transparent"
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (selectedSession === modelData) {
                            checkoutDetails = []
                        }
                        selectedSession = modelData
                        checkoutDetails = CheckoutService.getCheckoutDetails(
                                    modelData.id)
                    }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    Text {
                        text: "#" + modelData.display_number
                        color: "white"
                        font.bold: true
                    }
                    Text {
                        text: modelData.table_id ? "Table "
                                                   + modelData.table_id : modelData.order_type
                        color: "#cccccc"
                        font.pixelSize: 12
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 6
            color: "#1e1e1e"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                Text {
                    visible: selectedSession !== null
                    text: selectedSession ? "Order #" + selectedSession.display_number : ""
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 120
                    model: checkoutDetails
                    spacing: 16
                    clip: true

                    delegate: Column {
                        spacing: 8
                        width: parent.width

                        RowLayout {
                            spacing: 12
                            width: parent.width

                            Text {
                                text: "Order " + modelData.display_number
                                color: "#bbbbff"
                                font.bold: true
                                font.pixelSize: 16
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: !isOrderServed(modelData)
                                text: qsTr("PENDING")
                                color: "#ffaa66"
                                font.bold: true
                                font.pixelSize: 15
                            }

                            Text {
                                visible: isOrderServed(modelData)
                                text: qsTr("SERVED")
                                color: "#88ffaa"
                                font.bold: true
                                font.pixelSize: 15
                            }
                        }

                        Repeater {
                            model: modelData.items
                            delegate: Row {
                                spacing: 12
                                width: parent ? parent.width : 0

                                Text {
                                    text: modelData.item_name + " ×" + modelData.quantity
                                    color: isOrderServed(
                                               modelData.parentModelData) ? "white" : "#888888"
                                    font.pixelSize: 16
                                }

                                Text {
                                    visible: modelData.notes
                                             && modelData.notes.length > 0
                                    text: "(" + modelData.notes + ")"
                                    color: isOrderServed(
                                               modelData.parentModelData) ? "#ffdd99" : "#aa8844"
                                    font.pixelSize: 15
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                    spacing: 12

                    Column {
                        visible: selectedSession !== null
                        spacing: 6

                        Text {
                            text: qsTr("Subtotal: RM") + selectedSession.subtotal.toFixed(
                                      2)
                            color: "white"
                            font.pixelSize: 15
                        }
                        Text {
                            text: qsTr("Tax: RM") + selectedSession.tax.toFixed(2)
                            color: "white"
                            font.pixelSize: 15
                        }
                        Text {
                            text: qsTr("Total: RM") + selectedSession.total.toFixed(2)
                            color: "white"
                            font.bold: true
                            font.pixelSize: 18
                        }
                    }

                    Button {
                        visible: selectedSession !== null
                        text: qsTr("Checkout")
                        Layout.alignment: Qt.AlignHCenter

                        enabled: canCheckout

                        background: Rectangle {
                            radius: 6
                            color: enabled ? "#7a5be0" : "#444444"
                        }

                        contentItem: Text {
                            text: qsTr("Checkout")
                            color: "white"
                            font.bold: true
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            if (!selectedSession)
                                return
                            if (CheckoutService.markOrderPaid(
                                        selectedSession.id)) {
                                var printed = CheckoutService.printReceipt(
                                            selectedSession.id)
                                if (!printed) {
                                    console.log("Receipt printing failed for #"
                                                + selectedSession.display_number)
                                }
                                reloadSessions()
                            }
                        }
                    }
                }
            }
        }
    }
}
