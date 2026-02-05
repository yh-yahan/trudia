import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Xeno.Services 1.0
import "../components"

Item {
    width: 800
    height: 600

    property int selectedCategoryId: -1
    property var categories: []
    property var menuItems: []
    property string currentOrderType: ""
    property var tables: []
    property int selectedTableId: -1

    property real subtotal: 0
    property real tax: 0
    property real total: 0
    property int totalItems: 0
    property real discount: 0

    function changeOrderType(newType) {
        if (currentOrderId < 0)
            return

        OrderService.updateOrderType(currentOrderId, newType)
        currentOrderType = newType
    }

    function loadCategories() {
        categories = MenuService.getAllCategory()
        if (categories.length > 0 && selectedCategoryId === -1) {
            selectedCategoryId = categories[0].id
            loadMenuItems(selectedCategoryId)
        }
    }

    function loadMenuItems(categoryId) {
        if (categoryId >= 0) {
            menuItems = MenuService.getMenuItemsByCategory(categoryId)
        } else {
            menuItems = []
        }
    }

    function loadTables() {
        tables = TableService.getAllTables()
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
        tax = 0
        discount = 0
        total = subtotal - discount + tax
        totalItems = items
    }

    Component.onCompleted: {
        loadCategories()
        loadTables()
        recomputeMeta()
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
                text: "Dine In"
                checkable: true
                ButtonGroup.group: modeGroup
                Layout.fillWidth: true
                leftPadding: 15
                rightPadding: 15
                topPadding: 15
                bottomPadding: 15

                background: Rectangle {
                    radius: 6
                    color: dineInBtn.checked ? "#9a7bff" : "#2a2a2a"
                }

                contentItem: Label {
                    text: qsTr("Dine In")
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    currentOrderType = "dine_in"
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus
            }

            Button {
                id: takeawayBtn
                text: "Takeaway"
                checkable: true
                ButtonGroup.group: modeGroup
                Layout.fillWidth: true
                leftPadding: 15
                rightPadding: 15
                topPadding: 15
                bottomPadding: 15

                background: Rectangle {
                    radius: 6
                    color: takeawayBtn.checked ? "#9a7bff" : "#2a2a2a"
                }

                contentItem: Label {
                    text: qsTr("Takeaway")
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    currentOrderType = "takeaway"
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus
            }

            Button {
                id: deliveryBtn
                text: "Delivery"
                checkable: true
                ButtonGroup.group: modeGroup
                Layout.fillWidth: true
                leftPadding: 15
                rightPadding: 15
                topPadding: 15
                bottomPadding: 15

                background: Rectangle {
                    radius: 6
                    color: deliveryBtn.checked ? "#9a7bff" : "#2a2a2a"
                }

                contentItem: Label {
                    text: qsTr("Delivery")
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    currentOrderType = "delivery"
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
                width: 280
                color: "#181818"
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: "Categories"
                        font.bold: true
                        font.pixelSize: 18
                        color: "white"
                    }

                    ListView {
                        id: categoryListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: categories
                        clip: true

                        delegate: Rectangle {
                            id: cateogryRect

                            width: parent.width
                            height: 44
                            radius: 4
                            color: ListView.isCurrentItem ? "#9a7bff" : "#1f1f1f"
                            border.color: "#2a2a2a"

                            Text {
                                visible: true
                                text: modelData.category
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                color: ListView.isCurrentItem ? "white" : "#d0d0d0"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    categoryListView.currentIndex = index
                                    selectedCategoryId = modelData.id
                                    loadMenuItems(selectedCategoryId)
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
                color: "#181818"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: selectedCategoryId !== -1 ? "Menu Items" : "Select a category"
                        font.bold: true
                        font.pixelSize: 18
                        color: "white"
                    }

                    Rectangle {
                        visible: selectedCategoryId !== -1
                        Layout.fillWidth: true
                        height: 36
                        color: "#1f1f1f"
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8

                            Text {
                                text: "Item"
                                Layout.fillWidth: true
                                color: "#b0b0b0"
                                font.bold: true
                            }
                            Text {
                                text: "Price"
                                width: 70
                                color: "#b0b0b0"
                                font.bold: true
                            }
                            Text {
                                text: "Portion"
                                width: 100
                                color: "#b0b0b0"
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
                        visible: selectedCategoryId !== -1
                        model: menuItems
                        clip: true
                        spacing: 4

                        delegate: Rectangle {
                            id: itemRect
                            height: 44
                            width: ListView.view.width
                            radius: 4
                            color: "#1f1f1f"
                            border.color: "#2a2a2a"

                            property bool isEditing: false
                            property string editedName: modelData.item
                            property string editedPrice: modelData.price.toFixed(
                                                             2)
                            property string editedPortion: modelData.portion_size
                                                           || ""
                            property bool editedAvailable: modelData.is_available

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 10

                                Text {
                                    visible: true
                                    text: modelData.item
                                    Layout.fillWidth: true
                                    color: "white"
                                }

                                Text {
                                    visible: true
                                    text: "RM " + modelData.price.toFixed(2)
                                    width: 70
                                    color: "#d0d0d0"
                                }

                                Text {
                                    visible: true
                                    text: modelData.portion_size || "-"
                                    width: 100
                                    color: "#d0d0d0"
                                }

                                Button {
                                    text: "Add"
                                    enabled: modelData.is_available
                                    background: Rectangle {
                                        color: "#9a7bff"
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
                                                        i).menuItemId === modelData.id) {
                                                orderModel.setProperty(
                                                            i, "qty",
                                                            orderModel.get(
                                                                i).qty + 1)
                                                return
                                            }
                                        }

                                        orderModel.append({
                                                              "menuItemId": obj["id"],
                                                              "name": obj["item"],
                                                              "qty": 1,
                                                              "price": obj["price"],
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
                color: "#1e1e1e"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2

                    Label {
                        text: "Current Order"
                        font.pixelSize: 18
                        color: "white"
                    }

                    // Table selection
                    ColumnLayout {
                        visible: currentOrderType === "dine_in"
                        spacing: 8

                        Label {
                            text: "Table"
                            color: "white"
                            font.bold: true
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: tables

                                delegate: Rectangle {
                                    width: 72
                                    height: 40
                                    radius: 4

                                    color: modelData.is_active ? "#ff4d4d" : "#4caf50"

                                    border.width: 3
                                    border.color: selectedTableId
                                                  === modelData.id ? "#9a7bff" : "#222"

                                    Label {
                                        anchors.centerIn: parent
                                        text: modelData.table_number
                                        color: "white"
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: currentOrderType === "dine_in"

                                        onClicked: {
                                            selectedTableId = modelData.id
                                        }
                                    }
                                }
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

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 56
                            radius: 4
                            color: "#2a2a2a"

                            property string notes: ""

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 8

                                ColumnLayout {
                                    spacing: 2

                                    Label {
                                        text: name
                                        color: "white"
                                    }
                                    Label {
                                        text: "RM " + price.toFixed(2)
                                        font.pixelSize: 12
                                        color: "#ccc"
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
                                        color: "white"
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
                                        placeholderText: "Add a remark"
                                        text: notes
                                        onTextChanged: notes = text
                                        leftPadding: 5
                                        rightPadding: 5
                                        topPadding: 5
                                        bottomPadding: 5
                                        placeholderTextColor: "#b5b5b5"
                                        background: Rectangle {
                                            color: "#1f1f1f"
                                            radius: 4
                                            border.color: "#888888"
                                            border.width: 1
                                        }
                                        color: "white"
                                        font.pixelSize: 16

                                        onTextEdited: {
                                            orderModel.setProperty(index,
                                                                   "notes",
                                                                   text)
                                        }
                                    }

                                    Button {
                                        text: "Remove"
                                        background: Rectangle {
                                            color: "#ff4d4d"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: "Remove"
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

                    ColumnLayout {
                        spacing: 4
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 8

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
                                "tax": subtotal * 0.0,
                                "total": subtotal,
                                "totalItems": totalItems,
                                "discount": 0
                            }
                        }

                        RowLayout {
                            spacing: 8
                            Label {
                                text: "Subtotal:"
                                color: "white"
                                font.bold: true
                            }
                            Label {
                                text: "RM " + subtotal.toFixed(2)
                                color: "white"
                            }
                        }

                        RowLayout {
                            spacing: 8
                            Label {
                                text: "Tax:"
                                color: "white"
                                font.bold: true
                            }
                            Label {
                                text: "RM " + tax.toFixed(2)
                                color: "white"
                            }
                        }

                        RowLayout {
                            spacing: 8
                            Label {
                                text: "Total:"
                                color: "white"
                                font.bold: true
                            }
                            Label {
                                text: "RM " + total.toFixed(2)
                                color: "white"
                            }
                        }

                        RowLayout {
                            spacing: 8
                            Label {
                                text: "Total Items:"
                                color: "white"
                                font.bold: true
                            }
                            Label {
                                text: totalItems
                                color: "white"
                            }
                        }

                        RowLayout {
                            spacing: 8
                            Label {
                                text: "Table:"
                                color: "white"
                                font.bold: true
                            }
                            Label {
                                text: (currentOrderType === "dine_in"
                                       && selectedTableId >= 0) ? (function () {
                                           for (var i = 0; i < tables.length; i++) {
                                               if (tables[i].id === selectedTableId)
                                                   return tables[i].table_number
                                           }
                                           return "-"
                                       })() : "-"
                                color: "white"
                            }
                        }

                        RowLayout {
                            spacing: 8
                            Label {
                                text: "Discount:"
                                color: "white"
                                font.bold: true
                            }
                            Label {
                                text: "RM " + discount.toFixed(2)
                                color: "white"
                            }
                        }

                        Connections {
                            target: orderModel
                            onCountChanged: recomputeMeta()
                            onDataChanged: recomputeMeta()
                        }
                    }

                    Button {
                        text: "Place Order"
                        Layout.fillWidth: true

                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 15
                        bottomPadding: 15
                        Layout.topMargin: 15
                        background: Rectangle {
                            color: "#9a7bff"
                            radius: 4
                        }
                        contentItem: Text {
                            text: qsTr("Place Order")
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
                                               "name": e.name,
                                               "qty": e.qty,
                                               "price": e.price,
                                               "notes": e.notes
                                           })
                            }

                            var orderId = OrderService.createOrder(
                                        currentOrderType, items, {
                                            "tableId": currentOrderType
                                                       === "dine_in" ? selectedTableId : null
                                        })

                            orderModel.clear()
                            currentOrderType = ""
                            selectedTableId = -1
                            loadTables()

                            dineInBtn.checked = false
                            takeawayBtn.checked = false
                            deliveryBtn.checked = false
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus
                    }
                }
            }
        }
    }
}
