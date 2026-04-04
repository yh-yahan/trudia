import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0

Item {
    width: 1200
    height: 600

    readonly property color bgColor: "#121212"
    readonly property color cardColor: "#1e1e1e"
    readonly property color accentColor: "#9a7bff"
    readonly property color textColor: "white"
    readonly property color noteColor: "#ffcc80"

    property var pendingOrders: []
    property var preparingOrders: []
    property var readyOrders: []

    function loadOrders() {
        pendingOrders = KitchenOrderService.getOrdersByStatus("pending")
        preparingOrders = KitchenOrderService.getOrdersByStatus("in_progress")
        readyOrders = KitchenOrderService.getOrdersByStatus("ready")
    }

    Connections {
        target: KitchenOrderService

        function onOrdersChanged() {
            loadOrders()
        }
    }

    Component.onCompleted: loadOrders()

    Rectangle {
        anchors.fill: parent
        color: bgColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        KitchenColumn {
            title: qsTr("NEW")
            model: pendingOrders
            actionText: qsTr("START")
            nextState: "in_progress"
        }

        KitchenColumn {
            title: qsTr("PREPARING")
            model: preparingOrders
            actionText: qsTr("MARK READY")
            nextState: "ready"
        }

        KitchenColumn {
            title: qsTr("READY")
            model: readyOrders
            actionText: qsTr("SERVE")
            nextState: "served"
        }
    }

    component KitchenColumn: ColumnLayout {
        property string title
        property var model
        property string actionText
        property string nextState

        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 12

        Text {
            text: title
            color: textColor
            font.pixelSize: 22
            font.bold: true
        }

        Rectangle {
            height: 2
            width: parent.width
            color: accentColor
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            clip: true
            model: parent.model

            delegate: Rectangle {
                width: ListView.view.width
                color: cardColor
                radius: 6
                implicitHeight: content.implicitHeight + 24

                ColumnLayout {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "#" + modelData.display_number
                            color: textColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            text: modelData.order_type.toUpperCase()
                            color: textColor
                            font.pixelSize: 12
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: modelData.table_number !== null
                            text: "Table " + modelData.table_number
                            color: textColor
                            font.pixelSize: 12
                        }
                    }

                    ColumnLayout {
                        spacing: 4

                        Repeater {
                            model: modelData.items

                            ColumnLayout {
                                spacing: 2

                                Text {
                                    text: modelData.item_name + " ×" + modelData.quantity
                                    color: textColor
                                    font.pixelSize: 14
                                }

                                Text {
                                    visible: modelData.notes
                                             && modelData.notes.length > 0
                                    text: "– " + modelData.notes
                                    color: noteColor
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }

                    Text {
                        visible: modelData.notes && modelData.notes.length > 0
                        text: qsTr("NOTE: ") + modelData.notes
                        color: noteColor
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                    }

                    Button {
                        Layout.fillWidth: true
                        text: actionText
                        Layout.preferredHeight: 38

                        background: Rectangle {
                            color: accentColor
                            radius: 4
                        }

                        contentItem: Text {
                            text: actionText
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            KitchenOrderService.markState(modelData.id,
                                                          nextState)
                        }
                    }
                }
            }
        }
    }
}
