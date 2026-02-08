import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: kitchenDisplay
    anchors.fill: parent

    // Dark theme palette
    readonly property color bgColor: "#121212"
    readonly property color cardBg: "#1e1e1e"
    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: "#cccccc"
    readonly property color accent: "#9a7bff"
    readonly property color readyGreen: "#4caf50"
    readonly property color borderColor: "#333333"

    Rectangle {
        anchors.fill: parent
        color: bgColor
    }

    // Main layout - three columns
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Column 1: New Orders
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Text {
                text: "NEW"
                font.pixelSize: 28
                font.bold: true
                color: accent
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Flow {
                    width: parent.width
                    spacing: 16
                    padding: 8

                    Repeater {
                        model: newOrdersModel
                        delegate: orderCard
                    }
                }
            }
        }

        // Column 2: Preparing
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Text {
                text: "PREPARING"
                font.pixelSize: 28
                font.bold: true
                color: accent
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Flow {
                    width: parent.width
                    spacing: 16
                    padding: 8

                    Repeater {
                        model: preparingOrdersModel
                        delegate: orderCard
                    }
                }
            }
        }

        // Column 3: Ready
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Text {
                text: "READY"
                font.pixelSize: 28
                font.bold: true
                color: accent
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Flow {
                    width: parent.width
                    spacing: 16
                    padding: 8

                    Repeater {
                        model: readyOrdersModel
                        delegate: orderCard
                    }
                }
            }
        }
    }

    // Reusable Order Card Component
    Component {
        id: orderCard

        Rectangle {
            width: 360
            height: childrenRect.height + 32
            radius: 12
            color: cardBg
            border.color: borderColor
            border.width: 1

            ColumnLayout {
                width: parent.width - 32
                x: 16
                y: 16
                spacing: 12

                // Header row: Order # + type
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: "#" + model.orderNumber
                        font.pixelSize: 26
                        font.bold: true
                        color: textPrimary
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: borderColor
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: model.type
                        font.pixelSize: 18
                        font.bold: true
                        color: model.type === "Dine-in" ? "#ff9800" : "#2196f3"
                    }
                }

                // Table / Pickup info
                Text {
                    text: model.tableOrPickup
                    font.pixelSize: 20
                    font.bold: true
                    color: textPrimary
                    Layout.fillWidth: true
                }

                // Items list
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: model.items

                        Text {
                            text: modelData.quantity + " × " + modelData.name
                            font.pixelSize: 17
                            color: textPrimary
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }

                // Modifiers & Notes
                ColumnLayout {
                    visible: model.modifiers.length > 0 || model.notes !== ""
                    spacing: 4
                    Layout.topMargin: 4
                    Layout.bottomMargin: 8

                    Repeater {
                        model: model.modifiers
                        delegate: Text {
                            text: "• " + modelData
                            font.pixelSize: 15
                            color: textSecondary
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }

                    Text {
                        visible: model.notes !== ""
                        text: "Note: " + model.notes
                        font.pixelSize: 15
                        color: "#ffeb3b"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }

                // Action Button
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    text: {
                        // Simple context-based text (you can improve with property or signal later)
                        if (parent.parent.parent.parent.parent === newOrdersColumn)
                            return "START"
                        if (parent.parent.parent.parent.parent === preparingOrdersColumn)
                            return "COMPLETE"
                        return "SERVED / PICKED UP"
                    }
                    font.pixelSize: 18
                    font.bold: true

                    background: Rectangle {
                        radius: 8
                        color: {
                            if (parent.text === "SERVED / PICKED UP")
                                return readyGreen
                            return accent
                        }
                        opacity: parent.pressed ? 0.8 : 1.0
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#000000"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("Action clicked for order #" + model.orderNumber)
                        // In real app: move order between models or emit signal
                    }
                }
            }
        }
    }

    // ───────────────────────────────────────────────
    // Dummy data models (hardcoded for now)
    // ───────────────────────────────────────────────
    ListModel {
        id: newOrdersModel
        ListElement {
            orderNumber: "124"
            type: "Dine-in"
            tableOrPickup: "Table 12"
            items: [
                ListElement {
                    quantity: 2
                    name: "Margherita Pizza"
                },
                ListElement {
                    quantity: 1
                    name: "Caesar Salad"
                },
                ListElement {
                    quantity: 1
                    name: "Garlic Bread"
                }
            ]
            modifiers: ["No olives", "Extra cheese on pizza"]
            notes: "Allergic to nuts - please be careful"
        }
        ListElement {
            orderNumber: "125"
            type: "Takeaway"
            tableOrPickup: "Pickup #3"
            items: [
                ListElement {
                    quantity: 1
                    name: "Beef Burger"
                },
                ListElement {
                    quantity: 1
                    name: "Fries"
                },
                ListElement {
                    quantity: 1
                    name: "Coke Zero"
                }
            ]
            modifiers: ["Medium done", "No mayo"]
            notes: ""
        }
    }

    ListModel {
        id: preparingOrdersModel
        ListElement {
            orderNumber: "119"
            type: "Dine-in"
            tableOrPickup: "Table 7"
            items: [
                ListElement {
                    quantity: 3
                    name: "Pasta Carbonara"
                },
                ListElement {
                    quantity: 2
                    name: "Tiramisu"
                }
            ]
            modifiers: ["One without pancetta"]
            notes: "Table is in a hurry"
        }
    }

    ListModel {
        id: readyOrdersModel
        ListElement {
            orderNumber: "117"
            type: "Dine-in"
            tableOrPickup: "Table 4"
            items: [
                ListElement {
                    quantity: 2
                    name: "Grilled Salmon"
                },
                ListElement {
                    quantity: 2
                    name: "Mashed Potatoes"
                }
            ]
            modifiers: []
            notes: ""
        }
        ListElement {
            orderNumber: "122"
            type: "Takeaway"
            tableOrPickup: "Pickup #1"
            items: [
                ListElement {
                    quantity: 1
                    name: "Chicken Shawarma Wrap"
                },
                ListElement {
                    quantity: 1
                    name: "Falafel Wrap"
                }
            ]
            modifiers: ["Extra tahini"]
            notes: ""
        }
    }
}
