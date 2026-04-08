import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import "../../components"

Item {
    width: 800
    height: 600

    ConfirmationDialog {
        id: confirmationDialog
        anchors.centerIn: parent
    }

    Rectangle {
        anchors.fill: parent
        color: "#121212"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            width: 220
            color: "#181818"
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: qsTr("Categories")
                    font.bold: true
                    font.pixelSize: 18
                    color: "white"
                }

                ListView {
                    id: categoryListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: MenuService.categoryModel
                    clip: true

                    delegate: Rectangle {
                        id: itemRect

                        required property int id
                        required property string name
                        required property int index

                        property bool isEditing: false
                        property string editedCategory: name
                        property string originalCategory: name

                        width: parent.width
                        height: 44
                        radius: 4
                        color: MenuService.currentCategoryId === id ? "#9a7bff" : "#1f1f1f"
                        border.color: "#2a2a2a"

                        function commitEdit() {
                            var newName = editedCategory.trim()
                            if (newName.length === 0
                                    || newName === originalCategory) {
                                isEditing = false
                                return
                            }

                            var success = MenuService.renameCategory(id,
                                                                     newName)
                            console.log("renameCategory success:", success)

                            isEditing = false
                        }

                        function cancelEdit() {
                            editedCategory = originalCategory
                            isEditing = false
                        }

                        Menu {
                            id: categoryMenu

                            MenuItem {
                                text: qsTr("Rename")
                                onTriggered: {
                                    itemRect.originalCategory = name
                                    itemRect.editedCategory = name
                                    itemRect.isEditing = true

                                    editField.forceActiveFocus()
                                    editField.selectAll()
                                }
                            }

                            MenuItem {
                                text: qsTr("Delete")
                                onTriggered: {
                                    confirmationDialog.title = qsTr(
                                                "Delete Category")
                                    confirmationDialog.message = qsTr(
                                                'Are you sure you want to delete "%1"? All menu items within "%1" will be deleted.').arg(
                                                name)

                                    confirmationDialog.confirmCallback = function (confirmed) {
                                        if (confirmed) {
                                            MenuService.removeCategory(id)
                                        }
                                    }

                                    confirmationDialog.open()
                                }
                            }
                        }

                        Text {
                            visible: !itemRect.isEditing
                            text: name
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            color: MenuService.currentCategoryId === id ? "white" : "#d0d0d0"
                        }

                        TextField {
                            id: editField
                            visible: itemRect.isEditing
                            text: itemRect.editedCategory

                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            width: parent.width - 24

                            color: "white"
                            selectByMouse: true
                            focus: true

                            background: Rectangle {
                                color: "#292929"
                                radius: 4
                                border.color: "#9a7bff"
                            }

                            onTextChanged: itemRect.editedCategory = text

                            onActiveFocusChanged: {
                                if (!activeFocus && itemRect.isEditing) {
                                    itemRect.commitEdit()
                                }
                            }

                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    itemRect.commitEdit()
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Escape) {
                                    itemRect.cancelEdit()
                                    event.accepted = true
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            enabled: !itemRect.isEditing

                            onClicked: function (mouse) {
                                if (mouse.button === Qt.RightButton) {
                                    categoryMenu.popup(itemRect)
                                } else {
                                    MenuService.currentCategoryId = id
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    spacing: 8

                    TextField {
                        id: newCategoryField
                        placeholderText: qsTr("New category name")
                        Layout.fillWidth: true
                        height: 40
                        font.pixelSize: 14
                        color: "white"
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10
                        placeholderTextColor: "#b5b5b5"

                        background: Rectangle {
                            color: "#1f1f1f"
                            radius: 4
                            border.color: "#888888"
                            border.width: 1
                        }

                        Component.onCompleted: {
                            if (itemRect.isEditing)
                                forceActiveFocus()
                        }

                        onActiveFocusChanged: {
                            background.border.color = activeFocus ? "#9a7bff" : "#888888"
                            background.color = activeFocus ? "#292929" : "#1f1f1f"
                        }
                    }

                    Button {
                        text: qsTr("Add Category")
                        Layout.fillWidth: true
                        Layout.topMargin: 15
                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 15
                        bottomPadding: 15
                        background: Rectangle {
                            color: "#9a7bff"
                            radius: 4
                        }
                        contentItem: Text {
                            text: qsTr("Add Category")
                            color: "white"
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            if (newCategoryField.text.length === 0)
                                return
                            var success = MenuService.addCategory(
                                        newCategoryField.text)
                            if (success) {
                                newCategoryField.text = ""
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#181818"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: MenuService.currentCategoryId !== -1 ? qsTr("Menu Items") : qsTr(
                                                          "Select a category")
                    font.bold: true
                    font.pixelSize: 18
                    color: "white"
                }

                Rectangle {
                    visible: MenuService.currentCategoryId !== -1
                    Layout.fillWidth: true
                    height: 40
                    color: "#1f1f1f"
                    radius: 6

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            text: qsTr("Item")
                            font.bold: true
                            color: "#b0b0b0"
                            Layout.fillWidth: true
                        }

                        Text {
                            text: qsTr("Price")
                            font.bold: true
                            color: "#b0b0b0"
                            Layout.preferredWidth: 90
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            text: qsTr("Portion")
                            font.bold: true
                            color: "#b0b0b0"
                            Layout.preferredWidth: 120
                        }

                        Text {
                            text: qsTr("Available")
                            font.bold: true
                            color: "#b0b0b0"
                            Layout.preferredWidth: 100
                        }

                        Text {
                            text: qsTr("Taxable")
                            font.bold: true
                            color: "#b0b0b0"
                            Layout.preferredWidth: 100
                        }

                        Item {
                            Layout.preferredWidth: 160
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
                        color: "#1f1f1f"
                        border.color: "#2a2a2a"

                        required property int id
                        required property string item
                        required property double price
                        required property string portion
                        required property bool available
                        required property bool taxable

                        property bool isEditing: false
                        property string editedName: item
                        property string editedPrice: price.toFixed(2)
                        property string editedPortion: portion || ""
                        property bool editedAvailable: available
                        property bool editedTaxable: taxable

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            Item {
                                Layout.fillWidth: true
                                height: 24

                                TextField {
                                    visible: itemRect.isEditing
                                    text: itemRect.editedName
                                    anchors.fill: parent
                                    color: "white"
                                    placeholderText: qsTr("Item Name")
                                    font.pixelSize: 14
                                    placeholderTextColor: "#b5b5b5"
                                    background: Rectangle {
                                        color: "#292929"
                                        radius: 4
                                        border.color: "#888888"
                                    }

                                    onTextChanged: itemRect.editedName = text
                                }

                                Text {
                                    visible: !itemRect.isEditing
                                    text: item
                                    color: "white"
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                }
                            }

                            Item {
                                Layout.preferredWidth: 90
                                height: 24

                                TextField {
                                    visible: itemRect.isEditing
                                    text: itemRect.editedPrice
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignRight
                                    color: "white"
                                    placeholderText: qsTr("Price")
                                    font.pixelSize: 14
                                    placeholderTextColor: "#b5b5b5"
                                    background: Rectangle {
                                        color: "#292929"
                                        radius: 4
                                        border.color: "#888888"
                                    }

                                    onTextChanged: itemRect.editedPrice = text
                                }

                                Text {
                                    visible: !itemRect.isEditing
                                    text: price.toFixed(2)
                                    horizontalAlignment: Text.AlignRight
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    color: "#d0d0d0"
                                }
                            }

                            Item {
                                Layout.preferredWidth: 120
                                height: 24

                                TextField {
                                    visible: itemRect.isEditing
                                    text: itemRect.editedPortion
                                    anchors.fill: parent
                                    color: "white"
                                    placeholderText: qsTr("Portion")
                                    font.pixelSize: 14
                                    placeholderTextColor: "#b5b5b5"
                                    background: Rectangle {
                                        color: "#1f1f1f"
                                        radius: 4
                                        border.color: "#888888"
                                        border.width: 1
                                    }

                                    onTextChanged: itemRect.editedPortion = text
                                }

                                Text {
                                    visible: !itemRect.isEditing
                                    text: portion || "-"
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    color: "#d0d0d0"
                                }
                            }

                            CheckBox {
                                Layout.preferredWidth: 100
                                checked: itemRect.isEditing ? itemRect.editedAvailable : available
                                enabled: itemRect.isEditing
                                onCheckedChanged: itemRect.editedAvailable = checked
                            }

                            CheckBox {
                                Layout.preferredWidth: 100
                                checked: itemRect.isEditing ? itemRect.editedTaxable : taxable
                                enabled: itemRect.isEditing
                                onCheckedChanged: itemRect.editedTaxable = checked
                            }

                            Button {
                                text: itemRect.isEditing ? qsTr("Save") : qsTr(
                                                               "Edit")
                                background: Rectangle {
                                    color: "#9a7bff"
                                    radius: 4
                                }
                                leftPadding: 15
                                rightPadding: 15
                                topPadding: 5
                                bottomPadding: 5
                                contentItem: Text {
                                    text: itemRect.isEditing ? qsTr("Save") : qsTr(
                                                                   "Edit")
                                    color: "white"
                                    anchors.centerIn: parent
                                }
                                onClicked: {
                                    if (itemRect.isEditing) {
                                        var itemNameTrimmed = itemRect.editedName.trim()
                                        var portionTrimmed = itemRect.editedPortion.trim()
                                        var priceVal = parseFloat(
                                                    itemRect.editedPrice)

                                        if (itemNameTrimmed.length === 0) {
                                            console.warn("Item name cannot be empty")
                                            return
                                        }

                                        if (isNaN(priceVal) || priceVal < 0) {
                                            priceVal = 0.00
                                            itemRect.editedPrice = priceVal
                                        }
                                        var success = MenuService.editMenuItem(
                                                    id, itemNameTrimmed,
                                                    MenuService.currentCategoryId,
                                                    priceVal,
                                                    itemRect.editedAvailable,
                                                    itemRect.editedTaxable,
                                                    portionTrimmed)

                                        if (success) {
                                            itemRect.isEditing = false
                                        }
                                    } else {
                                        itemRect.isEditing = true
                                    }
                                }

                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus
                            }

                            Button {
                                text: qsTr("Delete")
                                leftPadding: 15
                                rightPadding: 15
                                topPadding: 5
                                bottomPadding: 5
                                background: Rectangle {
                                    color: "red"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: qsTr("Delete")
                                    color: "white"
                                    anchors.centerIn: parent
                                }
                                onClicked: {
                                    confirmationDialog.title = qsTr(
                                                "Delete Item")
                                    confirmationDialog.message = qsTr(
                                                'Are you sure you want to delete "%1"?').arg(
                                                item)
                                    confirmationDialog.confirmCallback = function (confirmed) {
                                        if (confirmed) {
                                            MenuService.removeMenuItem(id)
                                        }
                                    }
                                    confirmationDialog.open()
                                }
                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus
                            }
                        }
                    }
                }

                ColumnLayout {
                    visible: MenuService.currentCategoryId !== -1
                    Layout.fillWidth: true
                    spacing: 8

                    RowLayout {
                        spacing: 8

                        TextField {
                            id: newItemName
                            placeholderText: qsTr("Item name")
                            Layout.fillWidth: true
                            height: 40
                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 10
                            bottomPadding: 10
                            font.pixelSize: 14
                            color: "white"
                            placeholderTextColor: "#b5b5b5"
                            padding: 10
                            background: Rectangle {
                                color: "#1f1f1f"
                                radius: 4
                                border.color: "#888888"
                                border.width: 1
                            }
                            onActiveFocusChanged: {
                                background.border.color = activeFocus ? "#9a7bff" : "#888888"
                                background.color = activeFocus ? "#292929" : "#1f1f1f"
                            }
                        }

                        TextField {
                            id: newItemPrice
                            placeholderText: qsTr("Price")
                            width: 200
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            height: 40
                            font.pixelSize: 14
                            color: "white"
                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 10
                            bottomPadding: 10
                            placeholderTextColor: "#b5b5b5"
                            background: Rectangle {
                                color: "#1f1f1f"
                                radius: 4
                                border.color: "#888888"
                                border.width: 1
                            }
                            onActiveFocusChanged: {
                                background.border.color = activeFocus ? "#9a7bff" : "#888888"
                                background.color = activeFocus ? "#292929" : "#1f1f1f"
                            }
                        }

                        TextField {
                            id: newItemPortion
                            placeholderText: qsTr("Portion (optional)")
                            width: 150
                            height: 40
                            font.pixelSize: 14
                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 10
                            bottomPadding: 10
                            color: "white"
                            placeholderTextColor: "#b5b5b5"
                            background: Rectangle {
                                color: "#1f1f1f"
                                radius: 4
                                border.color: "#888888"
                                border.width: 1
                            }
                            onActiveFocusChanged: {
                                background.border.color = activeFocus ? "#9a7bff" : "#888888"
                                background.color = activeFocus ? "#292929" : "#1f1f1f"
                            }
                        }

                        CheckBox {
                            id: newItemAvailable
                            text: qsTr("Available")
                            checked: true
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter
                            contentItem: Text {
                                text: qsTr("Available")
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        CheckBox {
                            id: newItemTaxable
                            text: qsTr("Taxable")
                            checked: true
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter
                            contentItem: Text {
                                text: qsTr("Taxable")
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Button {
                        text: qsTr("Add Menu Item")
                        Layout.fillWidth: true
                        Layout.topMargin: 15
                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 15
                        bottomPadding: 15
                        background: Rectangle {
                            color: "#9a7bff"
                            radius: 4
                        }
                        contentItem: Text {
                            text: qsTr("Add Menu Item")
                            color: "white"
                            font.bold: true
                            anchors.centerIn: parent
                        }
                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus
                        onClicked: {
                            var itemNameTrimmed = newItemName.text.trim()
                            var portionTrimmed = newItemPortion.text.trim()

                            if (itemNameTrimmed.length === 0
                                    || newItemPrice.text.length === 0
                                    || MenuService.currentCategoryId === -1) {
                                console.warn("Item name, price, and category are required")
                                return
                            }

                            var price = parseFloat(newItemPrice.text)
                            if (isNaN(price) || price < 0) {
                                price = 0.00
                            }

                            MenuService.addMenuItem(itemNameTrimmed,
                                                    MenuService.currentCategoryId, price,
                                                    newItemAvailable.checked,
                                                    newItemTaxable.checked,
                                                    portionTrimmed)

                            newItemName.text = ""
                            newItemPrice.text = ""
                            newItemPortion.text = ""
                            newItemAvailable.checked = true
                            newItemTaxable.checked = true
                        }
                    }
                }
            }
        }
    }
}
