import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    id: root

    width: 800
    height: 600

    property int tableId: -1
    property string tableLabel: ""

    property int currentOrderId: -1

    property real subtotal: 0
    property real total: 0
    property int totalItems: 0
    property real discount: 0

    property var kitchenSettings: ({})
    property string currencySymbol: SettingService.currencySymbol()

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
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ListModel {
        id: orderModel
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
                    text: qsTr("Back")

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

                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus

                    onClicked: {
                        if (StackView.view) {
                            StackView.view.pop()
                        } else {
                            var parentStack = root.parent
                            while (parentStack) {
                                if (parentStack instanceof StackView) {
                                    parentStack.pop()
                                    return
                                }
                                parentStack = parentStack.parent
                            }
                        }
                    }
                }

                ColumnLayout {
                    spacing: 2

                    Label {
                        text: tableLabel

                        font.bold: true
                        font.pixelSize: Theme.fontLarge

                        color: Theme.text
                    }

                    Label {
                        text: qsTr("Dine In")

                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontNormal
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            // category
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
                            width: ListView.view.width
                            height: 44

                            radius: 4

                            color: MenuService.currentCategoryId === id
                                   ? Theme.primary()
                                   : Theme.background

                            Text {
                                text: name

                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12

                                font.pixelSize: Theme.fontNormal

                                color: MenuService.currentCategoryId === id
                                       ? "white"
                                       : Theme.text
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
                        text: MenuService.currentCategoryId !== -1
                              ? qsTr("Menu Items")
                              : qsTr("Select a category")

                        font.bold: true
                        font.pixelSize: Theme.fontNormal

                        color: Theme.text
                    }

                    Rectangle {
                        visible: MenuService.currentCategoryId !== -1

                        Layout.fillWidth: true
                        height: 36

                        radius: 4
                        color: Theme.background

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8

                            Text {
                                text: qsTr("Item")

                                Layout.fillWidth: true

                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontSmall
                                font.bold: true
                            }

                            Text {
                                text: qsTr("Price")

                                width: 80

                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontSmall
                                font.bold: true
                            }

                            Item {
                                width: 70
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
                            width: ListView.view.width
                            height: 50

                            radius: 4
                            color: Theme.background

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 10

                                Text {
                                    text: item

                                    Layout.fillWidth: true

                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }

                                Text {
                                    text: currencySymbol + price.toFixed(2)

                                    width: 80

                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontNormal
                                }

                                Button {
                                    text: qsTr("Add")

                                    enabled: available

                                    background: Rectangle {
                                        radius: 4
                                        color: Theme.primary()
                                    }

                                    leftPadding: 14
                                    rightPadding: 14
                                    topPadding: 6
                                    bottomPadding: 6

                                    contentItem: Text {
                                        text: qsTr("Add")

                                        color: "white"
                                        font.bold: true
                                        font.pixelSize: Theme.fontNormal

                                        anchors.centerIn: parent
                                    }

                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus

                                    onClicked: {
                                        for (var i = 0; i < orderModel.count; i++) {
                                            if (orderModel.get(i).menuItemId === id) {
                                                orderModel.setProperty(
                                                            i,
                                                            "qty",
                                                            orderModel.get(i).qty + 1)

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
                                }
                            }
                        }
                    }
                }
            }

            // order
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
                            width: ListView.view.width
                            height: 64

                            radius: 4
                            color: Theme.background

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8

                                ColumnLayout {
                                    spacing: 2

                                    Label {
                                        text: name

                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                    }

                                    Label {
                                        text: currencySymbol + price.toFixed(2)

                                        color: Theme.secondaryText
                                        font.pixelSize: Theme.fontNormal
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                RowLayout {
                                    spacing: 4

                                    Button {
                                        text: "-"

                                        enabled: qty > 1

                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28

                                        onClicked: {
                                            orderModel.setProperty(
                                                        index,
                                                        "qty",
                                                        qty - 1)
                                        }
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

                                        onClicked: {
                                            orderModel.setProperty(
                                                        index,
                                                        "qty",
                                                        qty + 1)
                                        }
                                    }

                                    Button {
                                        text: qsTr("Remove")

                                        background: Rectangle {
                                            radius: 4
                                            color: "#ff4d4d"
                                        }

                                        contentItem: Text {
                                            text: qsTr("Remove")

                                            color: "white"
                                            font.pixelSize: Theme.fontNormal

                                            anchors.centerIn: parent
                                        }

                                        hoverEnabled: false
                                        focusPolicy: Qt.NoFocus

                                        onClicked: {
                                            orderModel.remove(index)
                                        }
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
                            Label {
                                text: qsTr("Items:")

                                font.bold: true
                                font.pixelSize: Theme.fontNormal

                                color: Theme.text
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Label {
                                text: totalItems

                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }
                        }

                        RowLayout {
                            Label {
                                text: qsTr("Subtotal:")

                                font.bold: true
                                font.pixelSize: Theme.fontNormal

                                color: Theme.text
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Label {
                                text: currencySymbol + subtotal.toFixed(2)

                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }
                        }

                        RowLayout {
                            Label {
                                text: qsTr("Total:")

                                font.bold: true
                                font.pixelSize: Theme.fontNormal

                                color: Theme.text
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Label {
                                text: currencySymbol + total.toFixed(2)

                                font.bold: true
                                font.pixelSize: Theme.fontNormal

                                color: Theme.text
                            }
                        }
                    }

                    Button {
                        text: currentOrderId >= 0
                              ? qsTr("Update Order")
                              : qsTr("Place Order")

                        Layout.fillWidth: true

                        enabled: orderModel.count > 0

                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 15
                        bottomPadding: 15

                        background: Rectangle {
                            radius: 6
                            color: Theme.primary()
                        }

                        contentItem: Text {
                            text: currentOrderId >= 0
                                  ? qsTr("Update Order")
                                  : qsTr("Place Order")

                            color: "white"

                            font.bold: true
                            font.pixelSize: Theme.fontNormal

                            anchors.centerIn: parent
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

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
                                "tableId": tableId,
                                "notes": ""
                            }

                            if (currentOrderId >= 0) {
                                OrderService.updateOrder(
                                            currentOrderId,
                                            "dine_in",
                                            items,
                                            options)
                            } else {
                                currentOrderId = OrderService.createOrder(
                                            "dine_in",
                                            items,
                                            options)
                            }

                            orderModel.clear()

                            if (StackView.view) {
                                StackView.view.pop()
                            } else {
                                var parentStack = root.parent
                                while (parentStack) {
                                    if (parentStack instanceof StackView) {
                                        parentStack.pop()
                                        return
                                    }
                                    parentStack = parentStack.parent
                                }
                            }
                        }
                    }

                    Connections {
                        target: orderModel

                        function onCountChanged() {
                            recomputeMeta()
                        }

                        function onDataChanged() {
                            recomputeMeta()
                        }
                    }
                }
            }
        }
    }
}
