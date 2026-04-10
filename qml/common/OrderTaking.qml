import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0
import "../components"

Item {
    width: 800
    height: 600

    property string currentOrderType: ""
    property int selectedTableId: -1
    property int currentOrderId: -1

    property real subtotal: 0
    property real total: 0
    property int totalItems: 0
    property real discount: 0

    property bool showEditOrdersList: false
    property var editOrdersList: []

    property var kitchenSettings: ({})
    property bool allowEditAfterSend: true

    function changeOrderType(newType) {
        currentOrderType = newType
    }

    function reloadOrder() {
        if (currentOrderId < 0)
            return
        orderModel.clear()
        var items = OrderService.getOrderItems(currentOrderId)

        for (var i = 0; i < items.length; i++) {
            orderModel.append({
                                  "orderItemId": items[i].id,
                                  "menuItemId": items[i].item_id,
                                  "name": items[i].item_name,
                                  "qty": items[i].quantity,
                                  "price": items[i].price,
                                  "notes": items[i].notes || ""
                              })
        }
    }

    function recomputeMeta() {
        var s = 0
        var items = 0

        for (var i = 0; i < orderModel.count; i++) {
            var item = orderModel.get(i)
            s += item.qty * item.price
            items += item.qty
        }

        subtotal = s
        discount = 0
        total = subtotal - discount
        totalItems = items
    }

    Component.onCompleted: {
        recomputeMeta()
        kitchenSettings = SettingService.getKitchenSettings()
        if (kitchenSettings && kitchenSettings.hasOwnProperty(
                    "allow_edit_after_send")) {
            allowEditAfterSend = kitchenSettings["allow_edit_after_send"]
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Order mode selection
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            ButtonGroup {
                id: modeGroup
                exclusive: true
            }

            Button {
                id: dineInBtn
                text: qsTr("Dine In")
                checkable: true
                ButtonGroup.group: modeGroup
                Layout.fillWidth: true
                leftPadding: 15
                rightPadding: 15
                topPadding: 15
                bottomPadding: 15
                checked: currentOrderType === "dine_in"

                background: Rectangle {
                    radius: 6
                    color: dineInBtn.checked ? Theme.primary() : Theme.surface
                }

                contentItem: Label {
                    text: qsTr("Dine In")
                    color: dineInBtn.checked ? "white" : Theme.text
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    changeOrderType("dine_in")
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus
            }

            Button {
                id: takeawayBtn
                text: qsTr("Takeaway")
                checkable: true
                ButtonGroup.group: modeGroup
                Layout.fillWidth: true
                leftPadding: 15
                rightPadding: 15
                topPadding: 15
                bottomPadding: 15
                checked: currentOrderType === "takeaway"

                background: Rectangle {
                    radius: 6
                    color: takeawayBtn.checked ? Theme.primary() : Theme.surface
                }

                contentItem: Label {
                    text: qsTr("Takeaway")
                    color: takeawayBtn.checked ? "white" : Theme.text
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    changeOrderType("takeaway")
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus
            }

            Button {
                id: deliveryBtn
                text: qsTr("Delivery")
                checkable: true
                ButtonGroup.group: modeGroup
                Layout.fillWidth: true
                leftPadding: 15
                rightPadding: 15
                topPadding: 15
                bottomPadding: 15
                checked: currentOrderType === "delivery"

                background: Rectangle {
                    radius: 6
                    color: deliveryBtn.checked ? Theme.primary() : Theme.surface
                }

                contentItem: Label {
                    text: qsTr("Delivery")
                    color: deliveryBtn.checked ? "white" : Theme.text
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    changeOrderType("delivery")
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            // Categories
            Rectangle {
                width: 220
                color: Theme.background
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: qsTr("Categories")
                        font.bold: true
                        font.pixelSize: 18
                        color: Theme.text
                    }

                    ListView {
                        id: categoryListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: MenuService.categoryModel
                        clip: true

                        delegate: Rectangle {
                            id: cateogryRect

                            width: parent.width
                            height: 44
                            radius: 4
                            color: ListView.isCurrentItem ? Theme.primary() : Theme.background

                            Text {
                                visible: true
                                text: name
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                color: categoryListView.currentIndex === index ? "white" : Theme.text
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    categoryListView.currentIndex = index
                                    MenuService.currentCategoryId = id
                                }
                            }
                        }
                    }
                }
            }

            // Menu items
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.background

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: MenuService.currentCategoryId !== -1 ? qsTr("Menu Items") : qsTr(
                                                              "Select a category")
                        font.bold: true
                        font.pixelSize: 18
                        color: Theme.text
                    }

                    Rectangle {
                        visible: MenuService.currentCategoryId !== -1
                        Layout.fillWidth: true
                        height: 36
                        color: Theme.background
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8

                            Text {
                                text: qsTr("Item")
                                Layout.fillWidth: true
                                color: Theme.secondaryText
                                font.bold: true
                            }
                            Text {
                                text: qsTr("Price")
                                width: 70
                                color: Theme.secondaryText
                                font.bold: true
                            }
                            Text {
                                text: qsTr("Portion")
                                width: 100
                                color: Theme.secondaryText
                                font.bold: true
                            }
                            Item {
                                width: 60
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: MenuService.currentCategoryId !== -1
                        model: MenuService.menuItemModel
                        clip: true
                        spacing: 4

                        delegate: Rectangle {
                            id: itemRect
                            height: 44
                            width: ListView.view.width
                            radius: 4
                            color: Theme.background

                            property bool isEditing: false
                            property string editedName: item
                            property string editedPrice: price.toFixed(
                                                             2)
                            property string editedPortion: portion
                                                           || ""
                            property bool editedAvailable: available

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 10

                                Text {
                                    visible: true
                                    text: item
                                    Layout.fillWidth: true
                                    color: Theme.text
                                }

                                Text {
                                    visible: true
                                    text: "RM " + price.toFixed(2)
                                    width: 70
                                    color: Theme.secondaryText
                                }

                                Text {
                                    visible: true
                                    text: portion || "-"
                                    width: 100
                                    color: Theme.secondaryText
                                }

                                Button {
                                    text: qsTr("Add")
                                    enabled: available
                                    background: Rectangle {
                                        color: Theme.primary()
                                        radius: 4
                                    }
                                    leftPadding: 15
                                    rightPadding: 15
                                    topPadding: 5
                                    bottomPadding: 5
                                    contentItem: Text {
                                        text: qsTr("Add")
                                        color: "white"
                                        anchors.centerIn: parent
                                    }
                                    onClicked: {
                                        var obj = modelData

                                        for (var i = 0; i < orderModel.count; i++) {
                                            if (orderModel.get(
                                                        i).menuItemId === id) {
                                                orderModel.setProperty(
                                                            i, "qty",
                                                            orderModel.get(
                                                                i).qty + 1)
                                                return
                                            }
                                        }

                                        orderModel.append({
                                                              "menuItemId": id,
                                                              "name": item,
                                                              "qty": 1,
                                                              "price": price,
                                                              "notes": ""
                                                          })
                                    }

                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus
                                }
                            }
                        }
                    }
                }
            }

            // Current order
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 6
                color: Theme.background

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // new order btn
                        Button {
                            text: qsTr("New Order")
                            leftPadding: 12
                            rightPadding: 12
                            topPadding: 10
                            bottomPadding: 10

                            background: Rectangle {
                                color: "#4faba1"
                                radius: 4
                            }

                            contentItem: Text {
                                text: qsTr("New Order")
                                anchors.centerIn: parent
                                color: "white"
                                font.bold: true
                            }

                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                orderModel.clear()
                                currentOrderId = -1
                                currentOrderType = ""
                                selectedTableId = -1
                                showEditOrdersList = false
                            }
                        }

                        // edit order btn
                        Button {
                            visible: allowEditAfterSend
                            text: qsTr("Edit Order")
                            leftPadding: 12
                            rightPadding: 12
                            topPadding: 10
                            bottomPadding: 10

                            background: Rectangle {
                                color: "#5F7DDC"
                                radius: 4
                            }

                            contentItem: Text {
                                text: qsTr("Edit Order")
                                anchors.centerIn: parent
                                color: "white"
                                font.bold: true
                            }

                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                editOrdersList = OrderService.getOpenOrders()
                                showEditOrdersList = true
                            }
                        }

                        // print ticket btn
                        Button {
                            visible: currentOrderId >= 0 && kitchenSettings
                                     && kitchenSettings.ticket_print_timing === "manual"
                            text: qsTr("Print Ticket")
                            leftPadding: 12
                            rightPadding: 12
                            topPadding: 10
                            bottomPadding: 10

                            background: Rectangle {
                                color: Theme.primary()
                                radius: 4
                            }

                            contentItem: Text {
                                text: qsTr("Print Ticket")
                                anchors.centerIn: parent
                                color: "white"
                                font.bold: true
                            }

                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                if (currentOrderId < 0)
                                    return

                                OrderService.printKitchenTicket(currentOrderId)
                            }
                        }
                    }

                    Label {
                        text: qsTr("Current Order")
                        visible: !showEditOrdersList
                        font.pixelSize: 18
                        color: Theme.text
                    }

                    // Table selection
                    ColumnLayout {
                        visible: currentOrderType === "dine_in"
                                 && !showEditOrdersList
                        spacing: 8

                        Label {
                            text: "Table"
                            color: Theme.text
                            font.bold: true
                        }

                        GridView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 98
                            clip: true

                            model: TableService.tableModel

                            cellWidth: 80
                            cellHeight: 48

                            delegate: Rectangle {
                                width: 72
                                height: 40
                                radius: 4

                                color: is_active ? "#ff4d4d" : "#4caf50"

                                border.width: 3
                                border.color: selectedTableId === id ? Theme.primary() : Theme.background

                                Label {
                                    anchors.centerIn: parent
                                    text: name
                                    color: "white"
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: currentOrderType === "dine_in"

                                    onClicked: {
                                        selectedTableId = id
                                    }
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                width: 4
                                policy: ScrollBar.AsNeeded
                            }
                        }
                    }

                    ListModel {
                        id: orderModel
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6
                        model: orderModel
                        visible: !showEditOrdersList

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 56
                            radius: 4
                            color: Theme.surface

                            property string notes: ""

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 8

                                ColumnLayout {
                                    spacing: 2

                                    Label {
                                        text: name
                                        color: Theme.text
                                    }
                                    Label {
                                        text: "RM " + price.toFixed(2)
                                        font.pixelSize: 12
                                        color: Theme.secondaryText
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                RowLayout {
                                    spacing: 4

                                    Button {
                                        text: "-"
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28
                                        padding: 0

                                        enabled: qty > 1

                                        onClicked: {
                                            orderModel.setProperty(index,
                                                                   "qty",
                                                                   qty - 1)
                                        }
                                    }
                                    Label {
                                        text: qty
                                        color: Theme.text
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.preferredWidth: 24
                                    }
                                    Button {
                                        text: "+"
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28
                                        padding: 0

                                        onClicked: {
                                            orderModel.setProperty(index,
                                                                   "qty",
                                                                   qty + 1)
                                        }
                                    }

                                    TextField {
                                        Layout.preferredWidth: 100
                                        placeholderText: qsTr("Add a remark")
                                        text: notes
                                        onTextChanged: notes = text
                                        leftPadding: 5
                                        rightPadding: 5
                                        topPadding: 5
                                        bottomPadding: 5
                                        placeholderTextColor: Theme.secondaryText
                                        background: Rectangle {
                                            color: Theme.background
                                            radius: 4
                                            border.color: Theme.border
                                            border.width: 1
                                        }
                                        color: Theme.text
                                        font.pixelSize: 16

                                        onTextEdited: {
                                            orderModel.setProperty(index,
                                                                   "notes",
                                                                   text)
                                        }
                                    }

                                    Button {
                                        text: qsTr("Remove")
                                        background: Rectangle {
                                            color: "#ff4d4d"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: qsTr("Remove")
                                            color: "white"
                                            anchors.centerIn: parent
                                        }

                                        onClicked: {
                                            orderModel.remove(index)
                                        }

                                        hoverEnabled: false
                                        focusPolicy: Qt.NoFocus
                                    }
                                }
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: showEditOrdersList
                        model: editOrdersList
                        spacing: 6

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 70
                            radius: 4
                            color: Theme.surface

                            Column {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 2

                                Text {
                                    text: "Order #" + modelData.display_number
                                          + " (" + modelData.type + ")"
                                    color: "white"
                                    font.bold: true
                                }

                                Text {
                                    text: "Status: " + modelData.status
                                    color: Theme.secondaryText
                                }

                                Text {
                                    text: modelData.table_number ? "Table: " + modelData.table_number : ""
                                    visible: modelData.table_number !== undefined && modelData.table_number !== null
                                    color: Theme.secondaryText
                                    font.pixelSize: 12
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    showEditOrdersList = false

                                    currentOrderId = modelData.id
                                    currentOrderType = modelData.type

                                    selectedTableId = modelData.table_id !== undefined
                                            && modelData.table_id !== null ? modelData.table_id : -1

                                    reloadOrder()
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 4
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 8
                        visible: !showEditOrdersList

                        function calculateMeta() {
                            var subtotal = 0
                            var totalItems = 0
                            for (var i = 0; i < orderModel.count; i++) {
                                var item = orderModel.get(i)
                                subtotal += item.qty * item.price
                                totalItems += item.qty
                            }
                            return {
                                "subtotal": subtotal,
                                "total": subtotal,
                                "totalItems": totalItems,
                                "discount": 0
                            }
                        }

                        RowLayout {
                            spacing: 8
                            Label {
                                text: qsTr("Total Items:")
                                color: Theme.text
                                font.bold: true
                            }
                            Label {
                                text: totalItems
                                color: Theme.text
                            }
                        }

                        RowLayout {
                            spacing: 8
                            Label {
                                text: qsTr("Subtotal:")
                                color: Theme.text
                                font.bold: true
                            }
                            Label {
                                text: "RM " + subtotal.toFixed(2)
                                color: Theme.text
                            }
                        }

                        RowLayout {
                            spacing: 8
                            Label {
                                text: qsTr("Total:")
                                color: Theme.text
                                font.bold: true
                            }
                            Label {
                                text: "RM " + total.toFixed(2)
                                color: Theme.text
                            }
                        }

                        Connections {
                            target: orderModel
                            onCountChanged: recomputeMeta()
                            onDataChanged: recomputeMeta()
                        }
                    }

                    Button {
                        text: currentOrderId >= 0 ? qsTr("Edit Order") : qsTr(
                                                        "Place Order")
                        Layout.fillWidth: true
                        visible: !showEditOrdersList

                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 15
                        bottomPadding: 15
                        Layout.topMargin: 15
                        background: Rectangle {
                            color: Theme.primary()
                            radius: 4
                        }
                        contentItem: Text {
                            text: currentOrderId >= 0 ? qsTr("Edit Order") : qsTr(
                                                            "Place Order")
                            font.bold: true
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: "white"
                        }

                        onClicked: {
                            if (orderModel.count === 0)
                                return
                            var items = []
                            for (var i = 0; i < orderModel.count; i++) {
                                var e = orderModel.get(i)
                                items.push({
                                               "menuItemId": e.menuItemId,
                                               "qty": e.qty,
                                               "notes": e.notes
                                           })
                            }

                            var options = {
                                "tableId": currentOrderType === "dine_in" ? selectedTableId : null,
                                "notes": ""
                            }

                            if (currentOrderId >= 0) {
                                OrderService.updateOrder(currentOrderId,
                                                         currentOrderType,
                                                         items, options)
                            } else {
                                currentOrderId = OrderService.createOrder(
                                            currentOrderType, items, options)
                            }

                            orderModel.clear()
                            currentOrderType = ""
                            selectedTableId = -1
                            currentOrderId = -1
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus
                    }
                }
            }
        }
    }
}
