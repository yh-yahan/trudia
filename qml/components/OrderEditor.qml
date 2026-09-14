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

    property int tableId: -1
    property string tableLabel: ""
    property int currentOrderId: -1
    property string orderType: "dine_in"

    property real subtotal: 0
    property real total: 0
    property int totalItems: 0
    property real discount: 0

    property var kitchenSettings: ({})
    property string currencySymbol: SettingService.currencySymbol()

    function popPage() {
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

    Component.onCompleted: {
        recomputeMeta()
        kitchenSettings = SettingService.getKitchenSettings()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ListModel {
        id: orderModel
    }

    ModifierPickerDialog {
        id: modifierPicker
        onConfirmed: function (payload) {
            root.addPayloadToOrder(payload)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Rectangle {
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
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8
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

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

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
                                    categoryListView.currentIndex = index
                                    MenuService.currentCategoryId = id
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
                                    leftPadding: 14
                                    rightPadding: 14
                                    topPadding: 6
                                    bottomPadding: 6
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

            Rectangle {
                Layout.preferredWidth: 420
                Layout.fillHeight: true
                radius: 6
                color: Theme.background

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Label {
                        text: qsTr("Current Order")
                        font.bold: true
                        font.pixelSize: Theme.fontLarge
                        color: Theme.text
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6
                        model: orderModel
                        clip: true

                        delegate: Rectangle {
                            required property int index
                            required property int menuItemId
                            required property string name
                            required property int qty
                            required property real price
                            required property string notes
                            required property string modifierLabel
                            required property string modifiersJson

                            width: ListView.view.width
                            implicitHeight: lineCol.implicitHeight + 16
                            radius: 6
                            color: Theme.surface
                            border.color: Theme.border
                            border.width: 1

                            ColumnLayout {
                                id: lineCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 8
                                spacing: 6

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
                                        color: Theme.text
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
                                        enabled: qty > 1
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28
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
                                        onClicked: orderModel.setProperty(index, "qty", qty + 1)
                                    }

                                    Item { Layout.fillWidth: true }

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

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.border
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Label { text: qsTr("Items:"); font.bold: true; font.pixelSize: Theme.fontNormal; color: Theme.text }
                            Item { Layout.fillWidth: true }
                            Label { text: totalItems; color: Theme.text; font.pixelSize: Theme.fontNormal }
                        }
                        RowLayout {
                            Label { text: qsTr("Subtotal:"); font.bold: true; font.pixelSize: Theme.fontNormal; color: Theme.text }
                            Item { Layout.fillWidth: true }
                            Label { text: currencySymbol + subtotal.toFixed(2); color: Theme.text; font.pixelSize: Theme.fontNormal }
                        }
                        RowLayout {
                            Label { text: qsTr("Total:"); font.bold: true; font.pixelSize: Theme.fontNormal; color: Theme.text }
                            Item { Layout.fillWidth: true }
                            Label { text: currencySymbol + total.toFixed(2); font.bold: true; color: Theme.text; font.pixelSize: Theme.fontNormal }
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        enabled: orderModel.count > 0
                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus
                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 15
                        bottomPadding: 15
                        background: Rectangle { radius: 6; color: Theme.primary() }
                        contentItem: Text {
                            text: currentOrderId >= 0 ? qsTr("Update Order") : qsTr("Place Order")
                            color: "white"
                            font.bold: true
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

                            var options = { "notes": "" }
                            if (orderType === "dine_in")
                                options.tableId = tableId

                            if (currentOrderId >= 0) {
                                OrderService.updateOrder(currentOrderId, orderType, items, options)
                            } else {
                                currentOrderId = OrderService.createOrder(orderType, items, options)
                            }

                            orderModel.clear()
                            root.popPage()
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
