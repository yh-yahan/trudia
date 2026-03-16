import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Xeno.Services 1.0

ScrollView {
    property var kitchenData: ({})

    Component.onCompleted: {
        kitchenData = SettingService.getKitchenSettings()

        if (!kitchenData || Object.keys(kitchenData).length === 0)
            return

        workflowCombo.currentValue = kitchenData.mode || "none"
        ticketPrintCombo.currentValue = kitchenData.ticket_print_timing
                || "order_created"
        requireReadySwitch.checked = kitchenData.require_ready_for_checkout

        allowEditSwitch.checked = kitchenData.allow_edit_after_send
    }

    anchors.fill: parent
    contentWidth: parent.width
    clip: true

    ColumnLayout {
        width: parent.width
        spacing: 30

        Label {
            text: qsTr("Kitchen Settings")
            font.pixelSize: 26
            font.bold: true
            color: "white"
        }

        ColumnLayout {
            spacing: 15

            Text {
                text: qsTr("Kitchen Workflow")
                font.bold: true
                color: "#c9c9c9"
                font.pointSize: 16
            }

            ColumnLayout {
                spacing: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Kitchen Mode")
                        color: "white"
                        Layout.preferredWidth: 230
                    }

                    ComboBox {
                        id: workflowCombo
                        Layout.preferredWidth: 240

                        model: [{
                                "value": "none",
                                "label": qsTr("No kitchen system")
                            }, {
                                "value": "kds",
                                "label": qsTr("Kitchen Display System (KDS)")
                            }, {
                                "value": "tickets",
                                "label": qsTr("Kitchen ticket printing")
                            }, {
                                "value": "hybrid",
                                "label": qsTr("KDS + ticket printing")
                            }]

                        textRole: "label"
                        valueRole: "value"
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 15
            visible: workflowCombo.currentValue === "tickets"
                     || workflowCombo.currentValue === "hybrid"

            Text {
                text: qsTr("Kitchen Ticket Printing")
                font.bold: true
                color: "#c9c9c9"
                font.pointSize: 16
            }

            ColumnLayout {
                spacing: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Print Ticket When")
                        color: "white"
                        Layout.preferredWidth: 230
                    }

                    ComboBox {
                        id: ticketPrintCombo
                        Layout.preferredWidth: 240

                        model: [{
                                "value": "order_created",
                                "label": qsTr("Order is created")
                            }, {
                                "value": "manual",
                                "label": qsTr("Manual only")
                            }]

                        textRole: "label"
                        valueRole: "value"
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 15
            visible: workflowCombo.currentValue === "kds"
                     || workflowCombo.currentValue === "hybrid"

            Text {
                text: qsTr("Checkout Rules")
                font.bold: true
                color: "#c9c9c9"
                font.pointSize: 16
            }

            ColumnLayout {
                spacing: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Require kitchen ready before checkout")
                        color: "white"
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: requireReadySwitch
                        checked: false
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 15

            Text {
                text: qsTr("Order Modification")
                font.bold: true
                color: "#c9c9c9"
                font.pointSize: 16
            }

            ColumnLayout {
                spacing: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Allow editing after sending to kitchen")
                        color: "white"
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: allowEditSwitch
                        checked: false
                    }
                }
            }
        }
    }

    background: Rectangle {
        color: "#1E1E1E"
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 20

        Button {
            text: "Save"
            width: 80
            leftPadding: 20
            rightPadding: 20
            topPadding: 10
            bottomPadding: 10

            background: Rectangle {
                color: "#9a7bff"
                radius: 4
            }

            contentItem: Text {
                text: qsTr("Save")
                font.bold: true
                anchors.centerIn: parent
                color: "white"
            }

            hoverEnabled: false
            focusPolicy: Qt.NoFocus

            onClicked: {
                var payload = {}

                payload.id = kitchenData.id || 1
                payload.mode = workflowCombo.currentValue
                payload.ticket_print_timing = ticketPrintCombo.currentValue
                payload.require_ready_for_checkout = requireReadySwitch.checked ? 1 : 0
                payload.allow_edit_after_send = allowEditSwitch.checked ? 1 : 0

                SettingService.saveKitchenSettings(payload)
            }
        }
    }
}
