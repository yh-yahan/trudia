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

    property bool floorPlanMode: false

    property int tableId: -1
    property string tableLabel: ""
    property string orderType: "dine_in"

    property int currentOrderId: -1

    property string currentOrderType: ""
    property int selectedTableId: -1
    property bool showEditOrdersList: false
    property var editOrdersList: []
    property bool allowEditAfterSend: false

    property string editingOrderNumber: ""

    property var kitchenSettings: ({})
    property string currencySymbol: SettingService.currencySymbol()

    readonly property string effectiveOrderType: floorPlanMode ? orderType : currentOrderType
    readonly property int effectiveTableId: floorPlanMode ? tableId : selectedTableId

    property real subtotal: 0
    property real total: 0
    property int totalItems: 0
    property real discount: 0

    function popPage() {
        if (!floorPlanMode) return
        if (StackView.view) {
            StackView.view.pop()
            return
        }
        var parentStack = root.parent
        while (parentStack) {
            if (parentStack instanceof StackView) {
                parentStack.pop()
                return
            }
            parentStack = parentStack.parent
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
                              "portion": payload.portion || "",
                              "notes": "",
                              "modifierKey": key,
                              "modifierLabel": payload.modifierLabel || "",
                              "modifiersJson": JSON.stringify(payload.modifiers || [])
                          })
    }

    function updateLineFromPayload(index, payload) {
        const key = payload.modifierKey || ""
        orderModel.set(index, {
            "orderItemId": orderModel.get(index).orderItemId,
            "menuItemId": payload.menuItemId,
            "name": payload.name,
            "qty": orderModel.get(index).qty,
            "price": payload.price,
            "basePrice": payload.basePrice,
            "portion": payload.portion || "",
            "notes": orderModel.get(index).notes,
            "modifierKey": key,
            "modifierLabel": payload.modifierLabel || "",
            "modifiersJson": JSON.stringify(payload.modifiers || [])
        })
    }

    function reloadOrder() {
        if (currentOrderId < 0) return
        orderModel.clear()
        var items = OrderService.getOrderItems(currentOrderId)
        for (var i = 0; i < items.length; i++) {
            const mods = items[i].modifiers || []
            const names = []
            let modifierTotal = 0
            for (var j = 0; j < mods.length; j++) {
                names.push(mods[j].name)
                modifierTotal += Number(mods[j].price_delta || 0)
            }

            const unitPrice = items[i].price + modifierTotal;

            orderModel.append({
                                  "orderItemId": items[i].id,
                                  "menuItemId": items[i].item_id,
                                  "name": items[i].item_name,
                                  "qty": items[i].quantity,
                                  "price": unitPrice,
                                  "basePrice": items[i].price,
                                  "portion": items[i].portion_size || "",
                                  "notes": items[i].notes || "",
                                  "modifierKey": modifierKeyFromList(mods),
                                  "modifierLabel": names.join(", "),
                                  "modifiersJson": JSON.stringify(mods)
                                })
        }
    }

    function changeOrderType(newType) {
        if (floorPlanMode) return
        currentOrderType = newType
    }

    Component.onCompleted: {
        recomputeMeta()
        kitchenSettings = SettingService.getKitchenSettings()
        if (kitchenSettings && kitchenSettings.hasOwnProperty("allow_edit_after_send"))
            allowEditAfterSend = kitchenSettings["allow_edit_after_send"]
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ListModel { id: orderModel }

    ModifierPickerDialog {
        id: modifierPicker
        onConfirmed: function (payload) {
            if (payload.editIndex !== undefined && payload.editIndex >= 0)
                root.updateLineFromPayload(payload.editIndex, payload)
            else
                root.addPayloadToOrder(payload)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: floorPlanMode ? 8 : 0
        spacing: 8

        // floor plan header
        Rectangle {
            visible: floorPlanMode
            Layout.fillWidth: true
            height: 64
            radius: 6
            color: Theme.surface
            border.width: 1
            border.color: Theme.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Button {
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    leftPadding: 12; rightPadding: 12
                    topPadding: 8; bottomPadding: 8
                    background: Rectangle {
                        radius: 6
                        color: Theme.background
                        border.width: 1
                        border.color: Theme.border
                    }
                    contentItem: Label {
                        text: qsTr("Back")
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: root.popPage()
                }

                ColumnLayout {
                    spacing: 2
                    Label {
                        text: {
                            switch (orderType) {
                            case "takeaway": return qsTr("Takeaway Order")
                            case "delivery": return qsTr("Delivery Order")
                            default: return tableLabel
                            }
                        }
                        font.bold: true
                        font.pixelSize: Theme.fontLarge
                        color: Theme.text
                    }
                    Label {
                        text: {
                            switch (orderType) {
                            case "takeaway": return qsTr("Takeaway")
                            case "delivery": return qsTr("Delivery")
                            default: return qsTr("Dine In")
                            }
                        }
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontNormal
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }

        // standalone mode tabs
        RowLayout {
            visible: !floorPlanMode
            Layout.fillWidth: true
            spacing: 0

            ButtonGroup { id: modeGroup; exclusive: true }

            Button {
                id: dineInBtn
                checkable: true
                ButtonGroup.group: modeGroup
                Layout.fillWidth: true
                leftPadding: 15; rightPadding: 15
                topPadding: 15; bottomPadding: 15
                checked: currentOrderType === "dine_in"
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                background: Rectangle { radius: 6; color: dineInBtn.checked ? Theme.primary() : Theme.surface }
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
                leftPadding: 15; rightPadding: 15
                topPadding: 15; bottomPadding: 15
                checked: currentOrderType === "takeaway"
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                background: Rectangle { radius: 6; color: takeawayBtn.checked ? Theme.primary() : Theme.surface }
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
                leftPadding: 15; rightPadding: 15
                topPadding: 15; bottomPadding: 15
                checked: currentOrderType === "delivery"
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                background: Rectangle { radius: 6; color: deliveryBtn.checked ? Theme.primary() : Theme.surface }
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

            // categories
            Rectangle {
                width: 220
                Layout.fillHeight: true
                radius: 6
                color: Theme.background

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
                        id: categoryListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: MenuService.categoryModel
                        clip: true
                        spacing: 4

                        delegate: Rectangle {
                            required property int id
                            required property string name
                            required property int index

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
                                onClicked: {
                                    if (floorPlanMode)
                                        categoryListView.currentIndex = index
                                    MenuService.currentCategoryId = id
                                }
                            }
                        }
                    }
                }
            }

            // menu items
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 6
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
                                        elide: Text.ElideRight
                                        width: parent.width
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
                                    text: qsTr("Add")
                                    enabled: available
                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus
                                    leftPadding: 14; rightPadding: 14
                                    topPadding: 6; bottomPadding: 6
                                    background: Rectangle {
                                        radius: 4
                                        color: available ? Theme.primary() : Theme.secondaryText
                                    }
                                    contentItem: Text {
                                        text: qsTr("Add")
                                        color: "white"
                                        font.bold: true
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

            // current order panel
            Rectangle {
                Layout.preferredWidth: floorPlanMode ? 420 : undefined
                Layout.fillWidth: !floorPlanMode
                Layout.fillHeight: true
                radius: 6
                color: Theme.background

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: floorPlanMode ? 10 : 6

                    // standalone action buttons
                    RowLayout {
                        visible: !floorPlanMode
                        Layout.fillWidth: true
                        spacing: 8

                        Button {
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            leftPadding: 12; rightPadding: 12
                            topPadding: 10; bottomPadding: 10
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
                                editingOrderNumber = -1
                                currentOrderType = ""
                                selectedTableId = -1
                                showEditOrdersList = false
                            }
                        }

                        Button {
                            visible: allowEditAfterSend
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            leftPadding: 12; rightPadding: 12
                            topPadding: 10; bottomPadding: 10
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
                            leftPadding: 12; rightPadding: 12
                            topPadding: 10; bottomPadding: 10
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
                        text: currentOrderId >= 0
                            ? qsTr("Editing Order #%1").arg(editingOrderNumber)
                            : qsTr("Current Order")
                        visible: !showEditOrdersList
                        font.bold: true
                        font.pixelSize: floorPlanMode ? Theme.fontLarge : Theme.fontNormal
                        color: Theme.text
                    }

                    // standalone table picker
                    ColumnLayout {
                        visible: !floorPlanMode && effectiveOrderType === "dine_in" && !showEditOrdersList
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
                                    enabled: effectiveOrderType === "dine_in"
                                    onClicked: selectedTableId = id
                                }
                            }

                            ScrollBar.vertical: ScrollBar { width: 4; policy: ScrollBar.AsNeeded }
                        }
                    }

                    // order lines
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
                            implicitHeight: lineCol.implicitHeight + (floorPlanMode ? 16 : 12)
                            radius: 6
                            color: Theme.surface
                            border.color: Theme.border
                            border.width: 1

                            ColumnLayout {
                                id: lineCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: floorPlanMode ? 8 : 6
                                spacing: floorPlanMode ? 6 : 4

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
                                        color: floorPlanMode ? Theme.text : Theme.secondaryText
                                        font.pixelSize: Theme.fontNormal
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            const line = orderModel.get(index)
                                            modifierPicker.openForEdit(
                                                index,
                                                line.menuItemId,
                                                line.name,
                                                line.basePrice,
                                                line.portion || "",
                                                root.parseModifiers(line)
                                            )
                                        }
                                    }
                                }

                                Label {
                                    visible: modifierLabel.length > 0
                                    text: modifierLabel
                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontSmall
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            const line = orderModel.get(index)
                                            modifierPicker.openForEdit(
                                                index,
                                                line.menuItemId,
                                                line.name,
                                                line.basePrice,
                                                line.portion || "",
                                                root.parseModifiers(line)
                                            )
                                        }
                                    }
                                }

                                RowLayout {
                                    spacing: 4

                                    Button {
                                        text: "-"
                                        enabled: qty > 1
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28
                                        padding: 0
                                        onClicked: orderModel.setProperty(index, "qty", qty - 1)
                                    }
                                    Label {
                                        text: qty
                                        Layout.preferredWidth: 24
                                        horizontalAlignment: Text.AlignHCenter
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                    }
                                    Button {
                                        text: "+"
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28
                                        padding: 0
                                        onClicked: orderModel.setProperty(index, "qty", qty + 1)
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                        visible: floorPlanMode
                                    }

                                    TextField {
                                        visible: !floorPlanMode
                                        Layout.fillWidth: true
                                        placeholderText: qsTr("Add a remark")
                                        text: notes
                                        leftPadding: 5; rightPadding: 5
                                        topPadding: 5; bottomPadding: 5
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
                                        background: Rectangle { radius: 4; color: "#ff4d4d" }
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

                    // standalone edit orders list
                    ListView {
                        visible: !floorPlanMode && showEditOrdersList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
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
                                    editingOrderNumber = modelData.display_number || modelData.id
                                    currentOrderType = modelData.type
                                    selectedTableId = modelData.table_id !== undefined && modelData.table_id !== null
                                                    ? modelData.table_id : -1
                                    reloadOrder()
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: floorPlanMode && !showEditOrdersList
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.border
                    }

                    // totals
                    ColumnLayout {
                        visible: !showEditOrdersList
                        Layout.fillWidth: true
                        spacing: 4
                        Layout.leftMargin: floorPlanMode ? 0 : 8

                        RowLayout {
                            Label {
                                text: floorPlanMode ? qsTr("Items:") : qsTr("Total Items:")
                                font.bold: true
                                font.pixelSize: Theme.fontNormal
                                color: Theme.text
                            }
                            Item { Layout.fillWidth: true; visible: floorPlanMode }
                            Label { text: totalItems; color: Theme.text; font.pixelSize: Theme.fontNormal }
                        }
                        RowLayout {
                            Label {
                                text: qsTr("Subtotal:")
                                font.bold: true
                                font.pixelSize: Theme.fontNormal
                                color: Theme.text
                            }
                            Item { Layout.fillWidth: true; visible: floorPlanMode }
                            Label { text: currencySymbol + subtotal.toFixed(2); color: Theme.text; font.pixelSize: Theme.fontNormal }
                        }
                        RowLayout {
                            Label {
                                text: qsTr("Total:")
                                font.bold: true
                                font.pixelSize: Theme.fontNormal
                                color: Theme.text
                            }
                            Item { Layout.fillWidth: true; visible: floorPlanMode }
                            Label {
                                text: currencySymbol + total.toFixed(2)
                                font.bold: true
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }
                        }
                    }

                    // place order / update button
                    Button {
                        Layout.fillWidth: true
                        visible: !showEditOrdersList
                        enabled: orderModel.count > 0
                                 && (floorPlanMode || effectiveOrderType !== "dine_in" || effectiveTableId >= 0)
                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus
                        leftPadding: 15; rightPadding: 15
                        topPadding: 15; bottomPadding: 15
                        Layout.topMargin: floorPlanMode ? 0 : 15
                        background: Rectangle { radius: 6; color: Theme.primary() }
                        contentItem: Text {
                            text: currentOrderId >= 0
                                  ? (floorPlanMode ? qsTr("Update Order") : qsTr("Edit Order"))
                                  : qsTr("Place Order")
                            color: "white"
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            if (orderModel.count === 0) return

                            var items = []
                            for (var i = 0; i < orderModel.count; i++) {
                                var e = orderModel.get(i)
                                if (floorPlanMode) {
                                    items.push({
                                                   "orderItemId": e.orderItemId,
                                                   "menuItemId": e.menuItemId,
                                                   "qty": e.qty,
                                                   "notes": e.notes,
                                                   "price": e.price,
                                                   "modifiers": root.parseModifiers(e)
                                               })
                                } else {
                                    items.push({
                                                   "orderItemId": e.orderItemId,
                                                   "menuItemId": e.menuItemId,
                                                   "qty": e.qty,
                                                   "notes": e.notes,
                                                   "price": e.price,
                                                   "modifiersJson": e.modifiersJson && e.modifiersJson.length
                                                                    ? e.modifiersJson : "[]"
                                               })
                                }
                            }

                            var options = { "notes": "" }
                            if (effectiveOrderType === "dine_in")
                                options.tableId = effectiveTableId

                            if (currentOrderId >= 0) {
                                OrderService.updateOrder(currentOrderId, effectiveOrderType, items, options)
                            } else {
                                currentOrderId = OrderService.createOrder(effectiveOrderType, items, options)
                            }

                            orderModel.clear()

                            if (floorPlanMode) {
                                root.popPage()
                            } else {
                                currentOrderType = ""
                                selectedTableId = -1
                                currentOrderId = -1
                                editingOrderNumber = -1
                            }
                        }
                    }

                    Connections {
                        target: orderModel
                        function onCountChanged() { root.recomputeMeta() }
                        function onDataChanged() { root.recomputeMeta() }
                    }
                }
            }
        }
    }
}
