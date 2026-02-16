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
    property bool hasUnservedOrders: sessionHasUnservedOrders(checkoutDetails)

    function reloadSessions() {
        sessions = CheckoutService.getActiveOrdersForCheckout()
        selectedSession = null
        checkoutDetails = []
    }

    function sessionHasUnservedOrders(details) {
        if (!details || details.length === 0)
            return false

        for (var i = 0; i < details.length; i++) {
            if (details[i].status !== "served") {
                return true
            }
        }

        return false
    }

    Component.onCompleted: {
        reloadSessions()
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
                        color: "#aaaaaa"
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
                spacing: 12

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
                    Layout.minimumHeight: 100
                    model: checkoutDetails
                    spacing: 12
                    clip: true

                    delegate: Column {
                        spacing: 6

                        Text {
                            text: "Order " + modelData.display_number
                            color: "#9a7bff"
                            font.bold: true
                        }

                        Repeater {
                            model: modelData.items
                            delegate: Row {
                                spacing: 8

                                Text {
                                    text: modelData.item_name + " ×" + modelData.quantity
                                    color: modelData.item_status === "served" ? "white" : "#aaaaaa"
                                    font.pixelSize: 16
                                }

                                Text {
                                    visible: modelData.notes
                                             && modelData.notes.length > 0
                                    text: "(" + modelData.notes + ")"
                                    color: "#ffcc80"
                                    font.pixelSize: 16
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                    spacing: 12
                    Rectangle {
                        visible: selectedSession && hasUnservedOrders
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? 160 : 0
                        Layout.minimumHeight: visible ? 120 : 0
                        radius: 4
                        color: "#332222"
                        border.color: "#ff8080"
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Text {
                                text: "Cannot checkout yet"
                                color: "#ff8080"
                                font.bold: true
                            }

                            Text {
                                text: "The following items are not served:"
                                color: "#ffcccc"
                                font.pixelSize: 12
                            }

                            Repeater {
                                model: checkoutDetails
                                delegate: Repeater {
                                    model: modelData.items
                                    delegate: Text {
                                        visible: modelData.order_status !== "served"
                                        text: "• " + modelData.item_name + " ×" + modelData.quantity
                                        color: "#ffcccc"
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        visible: selectedSession !== null
                        spacing: 4

                        Text {
                            text: "Subtotal: RM" + selectedSession.subtotal.toFixed(
                                      2)
                            color: "white"
                        }
                        Text {
                            text: "Tax: RM" + selectedSession.tax.toFixed(2)
                            color: "white"
                        }
                        Text {
                            text: "Total: RM" + selectedSession.total.toFixed(2)
                            color: "white"
                            font.bold: true
                            font.pixelSize: 16
                        }
                    }

                    Button {
                        visible: selectedSession !== null
                        text: qsTr("Checkout")
                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 15
                        bottomPadding: 15
                        enabled: selectedSession && !hasUnservedOrders

                        background: Rectangle {
                            radius: 4
                            color: enabled ? "#9a7bff" : "#444"
                        }

                        contentItem: Text {
                            text: qsTr("Checkout")
                            font.bold: true
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: "white"
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
                                    console.log("Failed to print receipt for order #"
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
