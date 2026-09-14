import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0
import "../components"

Item {
    id: root

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
    property bool allowEditAfterSend: false
    property string currencySymbol: SettingService.currencySymbol()

    function changeOrderType(newType) {
        currentOrderType = newType
    }

    function parseModifiers(line) {
        try {
            return JSON.parse(line.modifiersJson || "[]")
        } catch (e) {
            return []
        }
    }

    function modifierKeyFromList(modifiers) {
        const ids = []
        for (let i = 0; i < modifiers.length; ++i)
            ids.push(modifiers[i].id)
        ids.sort(function (a, b) { return a - b })
        return ids.join(",")
    }

    function addPayloadToOrder(payload) {
        const key = payload.modifierKey || ""
        for (var i = 0; i < orderModel.count; i++) {
            const line = orderModel.get(i)
            if (line.menuItemId === payload.menuItemId
                    && line.modifierKey === key
                    && (line.notes || "") === "") {
                orderModel.setProperty(i, "qty", line.qty + 1)
                return
            }
        }

        orderModel.append({
                              "orderItemId": -1,
                              "menuItemId": payload.menuItemId,
                              "name": payload.name,
                              "qty": 1,
                              "price": payload.price,
                              "basePrice": payload.basePrice,
                              "notes": "",
                              "modifierKey": key,
                              "modifierLabel": payload.modifierLabel || "",
                              "modifiersJson": JSON.stringify(payload.modifiers || [])
                          })
    }

    function reloadOrder() {
        if (currentOrderId < 0)
            return

        orderModel.clear()
        var items = OrderService.getOrderItems(currentOrderId)

        for (var i = 0; i < items.length; i++) {
            const mods = items[i].modifiers || []
            const names = []
            for (var j = 0; j < mods.length; j++)
                names.push(mods[j].name)

            orderModel.append({
                                  "orderItemId": items[i].id,
                                  "menuItemId": items[i].item_id,
                                  "name": items[i].item_name,
                                  "qty": items[i].quantity,
                                  "price": items[i].price,
                                  "basePrice": items[i].base_price !== undefined ? items[i].base_price : items[i].price,
                                  "notes": items[i].notes || "",
                                  "modifierKey": root.modifierKeyFromList(mods),
                                  "modifierLabel": names.join(", "),
                                  "modifiersJson": JSON.stringify(mods)
                              })
        }
    }

    function recomputeMeta() {
        var s = 0
        var items = 0
        for (var i = 0; i < orderModel.count; i++) {
            var line = orderModel.get(i)
            s += line.qty * line.price
            items += line.qty
        }
        subtotal = s
        discount = 0
        total = subtotal - discount
        totalItems = items
    }

    Component.onCompleted: {
        recomputeMeta()
        kitchenSettings = SettingService.getKitchenSettings()
        if (kitchenSettings && kitchenSettings.hasOwnProperty("allow_edit_after_send"))
            allowEditAfterSend = kitchenSettings["allow_edit_after_send"]
    }

    ModifierPickerDialog {
        id: modifierPicker
        onConfirmed: function (payload) {
            root.addPayloadToOrder(payload)
        }
    }

    ListModel {
        id: orderModel
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            ButtonGroup {
                id: modeGroup
                exclusive: true
            }

            Button {
                id: dineInBtn
                checkable: true
                ButtonGroup.group: modeGroup
                Layout.fillWidth: true
                leftPadding: 15
                rightPadding: 15
                topPadding: 15
                bottomPadding: 15
                checked: currentOrderType === "dine_in"
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                background: Rectangle {
                    radius: 6
                    color: dineInBtn.checked ? Theme.primary() : Theme.surface
                }
                contentItem: Label {
                    text: qsTr("Dine In")
                    color: dineInBtn.checked ? "white" : Theme.text
                    font.bold: true
                    font.pixelSize: Theme.fontNormal
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: changeOrderType("dine_in")
            }

            Button {
                id: takeawayBtn
                checkable: true
                ButtonGroup.group: modeGroup
                Layout.fillWidth: true
                leftPadding: 15
                rightPadding: 15
                topPadding: 15
                bottomPadding: 15
                checked: currentOrderType === "takeaway"
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                background: Rectangle {
                    radius: 6
                    color: takeawayBtn.checked ? Theme.primary() : Theme.surface
                }
                contentItem: Label {
                    text: qsTr("Takeaway")
                    color: takeawayBtn.checked ? "white" : Theme.text
                    font.bold: true
                    font.pixelSize: Theme.fontNormal
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: changeOrderType("takeaway")
            }

            Button {
                id: deliveryBtn
                checkable: true
                ButtonGroup.group: modeGroup
                Layout.fillWidth: true
                leftPadding: 15
                rightPadding: 15
                topPadding: 15
                bottomPadding: 15
                checked: currentOrderType === "delivery"
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                background: Rectangle {
                    radius: 6
                    color: deliveryBtn.checked ? Theme.primary() : Theme.surface
                }
                contentItem: Label {
                    text: qsTr("Delivery")
                    color: deliveryBtn.checked ? "white" : Theme.text
                    font.bold: true
                    font.pixelSize: Theme.fontNormal
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: changeOrderType("delivery")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

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
                        font.pixelSize: Theme.fontNormal
                        color: Theme.text
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: MenuService.categoryModel
                        clip: true

                        delegate: Rectangle {
                            required property int id
                            required property string name

                            width: ListView.view.width
                            height: 44
                            radius: 4
                            color: MenuService.currentCategoryId === id ? Theme.primary() : Theme.background

                            Text {
                                text: name
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                font.pixelSize: Theme.fontNormal
                                color: MenuService.currentCategoryId === id ? "white" : Theme.text
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: MenuService.currentCategoryId = id
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.background

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: MenuService.currentCategoryId !== -1 ? qsTr("Menu Items") : qsTr("Select a category")
                        font.bold: true
                        font.pixelSize: Theme.fontNormal
                        color: Theme.text
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: MenuService.currentCategoryId !== -1
                        model: MenuService.menuItemModel
                        clip: true
                        spacing: 4

                        delegate: Rectangle {
                            required property int id
                            required property string item
                            required property double price
                            required property string portion
                            required property bool available

                            width: ListView.view.width
                            height: 54
                            radius: 6
                            color: Theme.surface
                            border.color: Theme.border
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 10

                                Column {
                                    Layout.fillWidth: true
                                    Text {
                                        text: item
                                        color: available ? Theme.text : Theme.secondaryText
                                        font.pixelSize: Theme.fontNormal
                                    }
                                    Text {
                                        text: available
                                              ? ((portion || "") + (portion ? " · " : "") + currencySymbol + price.toFixed(2))
                                              : qsTr("Unavailable")
                                        color: available ? Theme.secondaryText : "#c62828"
                                        font.pixelSize: Theme.fontSmall
                                    }
                                }

                                Button {
                                    enabled: available
                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus
                                    leftPadding: 15
                                    rightPadding: 15
                                    topPadding: 5
                                    bottomPadding: 5
                                    background: Rectangle {
                                        color: available ? Theme.primary() : Theme.secondaryText
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: qsTr("Add")
                                        color: "white"
                                        font.pixelSize: Theme.fontNormal
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: modifierPicker.openFor(id, item, price, portion || "")
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 6
                color: Theme.background

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Button {
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            leftPadding: 12
                            rightPadding: 12
                            topPadding: 10
                            bottomPadding: 10
                            background: Rectangle { color: "#4faba1"; radius: 4 }
                            contentItem: Text {
                                text: qsTr("New Order")
                                color: "white"
                                font.pixelSize: Theme.fontNormal
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                orderModel.clear()
                                currentOrderId = -1
                                currentOrderType = ""
                                selectedTableId = -1
                                showEditOrdersList = false
                            }
                        }

                        Button {
                            visible: allowEditAfterSend
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            leftPadding: 12
                            rightPadding: 12
                            topPadding: 10
                            bottomPadding: 10
                            background: Rectangle { color: "#5F7DDC"; radius: 4 }
                            contentItem: Text {
                                text: qsTr("Edit Order")
                                color: "white"
                                font.pixelSize: Theme.fontNormal
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                editOrdersList = OrderService.getOpenOrders()
                                showEditOrdersList = true
                            }
                        }

                        Button {
                            visible: currentOrderId >= 0 && kitchenSettings
                                     && (kitchenSettings.mode == "tickets" || kitchenSettings.mode == "hybrid")
                                     && kitchenSettings.ticket_print_timing === "manual"
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            leftPadding: 12
                            rightPadding: 12
                            topPadding: 10
                            bottomPadding: 10
                            background: Rectangle { color: Theme.primary(); radius: 4 }
                            contentItem: Text {
                                text: qsTr("Print Ticket")
                                color: "white"
                                font.pixelSize: Theme.fontNormal
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                if (currentOrderId >= 0)
                                    OrderService.printKitchenTicket(currentOrderId)
                            }
                        }
                    }

                    Label {
                        text: qsTr("Current Order")
                        visible: !showEditOrdersList
                        font.pixelSize: Theme.fontNormal
                        color: Theme.text
                    }

                    ColumnLayout {
                        visible: currentOrderType === "dine_in" && !showEditOrdersList
                        spacing: 8

                        Label {
                            text: qsTr("Table")
                            color: Theme.text
                            font.bold: true
                            font.pixelSize: Theme.fontSmall
                        }

                        GridView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 98
                            clip: true
                            model: TableService.tableModel
                            cellWidth: 80
                            cellHeight: 48

                            delegate: Rectangle {
                                required property int id
                                required property string name
                                required property string status

                                width: 72
                                height: 40
                                radius: 4
                                color: status == "occupied" ? "#ff4d4d" : "#4caf50"
                                border.width: 3
                                border.color: selectedTableId === id ? Theme.primary() : Theme.background

                                Label {
                                    anchors.centerIn: parent
                                    text: name
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: currentOrderType === "dine_in"
                                    onClicked: selectedTableId = id
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                width: 4
                                policy: ScrollBar.AsNeeded
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6
                        model: orderModel
                        visible: !showEditOrdersList
                        clip: true

                        delegate: Rectangle {
                            required property int index
                            required property string name
                            required property int qty
                            required property real price
                            required property string notes
                            required property string modifierLabel

                            width: ListView.view.width
                            implicitHeight: lineCol.implicitHeight + 12
                            radius: 4
                            color: Theme.surface

                            ColumnLayout {
                                id: lineCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 6
                                spacing: 4

                                RowLayout {
                                    Label {
                                        text: name
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                    }
                                    Label {
                                        text: currencySymbol + (qty * price).toFixed(2)
                                        color: Theme.secondaryText
                                        font.pixelSize: Theme.fontNormal
                                    }
                                }

                                Label {
                                    visible: modifierLabel.length > 0
                                    text: modifierLabel
                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontSmall
                                    wrapMode: Text.WordWrap
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
                                        onClicked: orderModel.setProperty(index, "qty", qty - 1)
                                    }
                                    Label {
                                        text: qty
                                        color: Theme.text
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.preferredWidth: 24
                                        font.pixelSize: Theme.fontNormal
                                    }
                                    Button {
                                        text: "+"
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28
                                        padding: 0
                                        onClicked: orderModel.setProperty(index, "qty", qty + 1)
                                    }

                                    TextField {
                                        Layout.fillWidth: true
                                        placeholderText: qsTr("Add a remark")
                                        text: notes
                                        leftPadding: 5
                                        rightPadding: 5
                                        topPadding: 5
                                        bottomPadding: 5
                                        placeholderTextColor: Theme.secondaryText
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        background: Rectangle {
                                            color: Theme.background
                                            radius: 4
                                            border.color: Theme.border
                                            border.width: 1
                                        }
                                        onTextEdited: orderModel.setProperty(index, "notes", text)
                                    }

                                    Button {
                                        hoverEnabled: false
                                        focusPolicy: Qt.NoFocus
                                        background: Rectangle { color: "#ff4d4d"; radius: 4 }
                                        contentItem: Text {
                                            text: qsTr("Remove")
                                            color: "white"
                                            font.pixelSize: Theme.fontNormal
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: orderModel.remove(index)
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
                            required property var modelData
                            width: ListView.view.width
                            height: 75
                            radius: 4
                            color: Theme.surface

                            Column {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 2
                                Text {
                                    text: qsTr("Order #%1 (%2)").arg(modelData.display_number).arg(modelData.type)
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                }
                                Text {
                                    text: qsTr("Status: %1").arg(modelData.status)
                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontNormal
                                }
                                Text {
                                    text: modelData.table_name ? qsTr("Table: %1").arg(modelData.table_name) : ""
                                    visible: modelData.table_name !== undefined && modelData.table_name !== null
                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontNormal
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
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        visible: !showEditOrdersList

                        RowLayout {
                            Label { text: qsTr("Total Items:"); color: Theme.text; font.bold: true; font.pixelSize: Theme.fontNormal }
                            Label { text: totalItems; color: Theme.text; font.pixelSize: Theme.fontNormal }
                        }
                        RowLayout {
                            Label { text: qsTr("Subtotal:"); color: Theme.text; font.bold: true; font.pixelSize: Theme.fontNormal }
                            Label { text: currencySymbol + subtotal.toFixed(2); color: Theme.text; font.pixelSize: Theme.fontNormal }
                        }
                        RowLayout {
                            Label { text: qsTr("Total:"); color: Theme.text; font.bold: true; font.pixelSize: Theme.fontNormal }
                            Label { text: currencySymbol + total.toFixed(2); color: Theme.text; font.pixelSize: Theme.fontNormal }
                        }

                        Connections {
                            target: orderModel
                            function onCountChanged() { root.recomputeMeta() }
                            function onDataChanged() { root.recomputeMeta() }
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        visible: !showEditOrdersList
                        enabled: orderModel.count > 0
                                 && (currentOrderType !== "dine_in" || selectedTableId >= 0)
                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus
                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 15
                        bottomPadding: 15
                        Layout.topMargin: 15
                        background: Rectangle { color: Theme.primary(); radius: 4 }
                        contentItem: Text {
                            text: currentOrderId >= 0 ? qsTr("Edit Order") : qsTr("Place Order")
                            font.bold: true
                            color: "white"
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
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
                                               "notes": e.notes,
                                               "price": e.price,
                                               "modifiers": root.parseModifiers(e)
                                           })
                            }

                            var options = {
                                "tableId": currentOrderType === "dine_in" ? selectedTableId : null,
                                "notes": ""
                            }

                            if (currentOrderId >= 0) {
                                OrderService.updateOrder(currentOrderId, currentOrderType, items, options)
                            } else {
                                currentOrderId = OrderService.createOrder(currentOrderType, items, options)
                            }

                            orderModel.clear()
                            currentOrderType = ""
                            selectedTableId = -1
                            currentOrderId = -1
                        }
                    }
                }
            }
        }
    }
}
