import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    width: 1200
    height: 600

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

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            loadOrders()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
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
            color: Theme.text
            font.pixelSize: Theme.fontLarge
            font.bold: true
        }

        Rectangle {
            height: 2
            width: parent.width
            color: Theme.primary()
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            clip: true
            model: parent.model

            delegate: Rectangle {
                width: ListView.view.width
                color: Theme.surface
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
                            color: Theme.text
                            font.pixelSize: Theme.fontLarge
                            font.bold: true
                        }

                        Text {
                            text: modelData.order_type.toUpperCase()
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: modelData.table_name != null
                            text: "Table " + modelData.table_name
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }
                    }

                    ColumnLayout {
                        spacing: 4

                        Repeater {
                            model: modelData.items

                            ColumnLayout {
                                spacing: 2

                                Text {
                                    text: {
                                        var portion = modelData.portion_size
                                        return modelData.item_name + (portion && portion.length > 0 ? " (" + portion + ")" : "") + " x" + modelData.quantity
                                    }
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }

                                Text {
                                    visible: modelData.notes
                                             && modelData.notes.length > 0
                                    text: "- " + modelData.notes
                                    color: Theme.orange
                                    font.pixelSize: Theme.fontNormal
                                }
                            }
                        }
                    }

                    Text {
                        visible: modelData.notes && modelData.notes.length > 0
                        text: qsTr("NOTE: ") + modelData.notes
                        color: Theme.orange
                        font.pixelSize: Theme.fontNormal
                        wrapMode: Text.Wrap
                    }

                    Button {
                        Layout.fillWidth: true
                        text: actionText
                        Layout.preferredHeight: 38

                        background: Rectangle {
                            color: Theme.primary()
                            radius: 4
                        }

                        contentItem: Text {
                            text: actionText
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Theme.fontNormal
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
