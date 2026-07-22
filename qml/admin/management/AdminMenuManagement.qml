import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0
import "../../components"

Item {
    width: 800
    height: 600

    property string currencySymbol: SettingService.currencySymbol()

    ConfirmationDialog {
        id: confirmationDialog
        anchors.centerIn: parent
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

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
                    id: categoryListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: MenuService.categoryModel
                    clip: true

                    delegate: Rectangle {
                        id: categoryRect

                        required property int id
                        required property string name
                        required property int index

                        property bool isEditing: false
                        property string editedCategory: name
                        property string originalCategory: name

                        width: categoryListView.width
                        height: 44
                        radius: 4
                        color: MenuService.currentCategoryId === id ? Theme.primary(
                                                                          ) : Theme.background

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
                                font.pixelSize: Theme.fontNormal
                                onTriggered: {
                                    categoryRect.originalCategory = name
                                    categoryRect.editedCategory = name
                                    categoryRect.isEditing = true

                                    editField.forceActiveFocus()
                                    editField.selectAll()
                                }
                            }

                            MenuItem {
                                text: qsTr("Delete")
                                font.pixelSize: Theme.fontNormal
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
                            visible: !categoryRect.isEditing
                            text: name
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            font.pixelSize: Theme.fontNormal
                            color: MenuService.currentCategoryId === id ? "white" : Theme.text
                        }

                        TextField {
                            id: editField
                            visible: categoryRect.isEditing
                            text: categoryRect.editedCategory

                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            width: parent.width - 24

                            color: Theme.text
                            selectByMouse: true
                            focus: true

                            font.pixelSize: Theme.fontNormal

                            background: Rectangle {
                                color: Theme.background
                                radius: 4
                                border.color: Theme.primary()
                            }

                            onTextChanged: categoryRect.editedCategory = text

                            onActiveFocusChanged: {
                                if (!activeFocus && categoryRect.isEditing) {
                                    categoryRect.commitEdit()
                                }
                            }

                            Keys.onPressed: event => {
                                                if (event.key === Qt.Key_Return
                                                    || event.key === Qt.Key_Enter) {
                                                    categoryRect.commitEdit()
                                                    event.accepted = true
                                                } else if (event.key === Qt.Key_Escape) {
                                                    categoryRect.cancelEdit()
                                                    event.accepted = true
                                                }
                                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            enabled: !categoryRect.isEditing

                            onClicked: function (mouse) {
                                if (mouse.button === Qt.RightButton) {
                                    categoryMenu.popup(categoryRect)
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
                        font.pixelSize: Theme.fontNormal
                        color: Theme.text
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10
                        placeholderTextColor: Theme.secondaryText

                        background: Rectangle {
                            color: Theme.background
                            radius: 4
                            border.color: Theme.border
                            border.width: 1
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
                            color: Theme.primary()
                            radius: 4
                        }
                        contentItem: Text {
                            text: qsTr("Add Category")
                            color: "white"
                            font.bold: true
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontNormal
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
            color: Theme.background

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: MenuService.currentCategoryId !== -1 ? qsTr("Menu Items") : qsTr(
                                                                     "Select a category")
                    font.bold: true
                    font.pixelSize: Theme.fontNormal
                    color: Theme.text
                }

                Rectangle {
                    visible: MenuService.currentCategoryId !== -1
                    Layout.fillWidth: true
                    height: 40
                    color: Theme.background
                    radius: 6

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            text: qsTr("Item")
                            font.bold: true
                            color: Theme.secondaryText
                            Layout.fillWidth: true
                            font.pixelSize: Theme.fontSmall
                        }

                        Text {
                            text: qsTr("Price")
                            font.bold: true
                            color: Theme.secondaryText
                            Layout.preferredWidth: 90
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Theme.fontSmall
                        }

                        Text {
                            text: qsTr("Portion")
                            font.bold: true
                            color: Theme.secondaryText
                            Layout.preferredWidth: 120
                            font.pixelSize: Theme.fontSmall
                        }

                        Text {
                            text: qsTr("Available")
                            font.bold: true
                            color: Theme.secondaryText
                            Layout.preferredWidth: 100
                            font.pixelSize: Theme.fontSmall
                        }

                        Text {
                            text: qsTr("Taxable")
                            font.bold: true
                            color: Theme.secondaryText
                            Layout.preferredWidth: 100
                            font.pixelSize: Theme.fontSmall
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
                        color: Theme.background
                        border.color: Theme.surface

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
                                    color: Theme.text
                                    placeholderText: qsTr("Item Name")
                                    font.pixelSize: Theme.fontNormal
                                    placeholderTextColor: Theme.secondaryText
                                    background: Rectangle {
                                        color: Theme.background
                                        radius: 4
                                        border.color: Theme.border
                                    }

                                    onTextChanged: itemRect.editedName = text
                                }

                                Text {
                                    visible: !itemRect.isEditing
                                    text: item
                                    color: Theme.text
                                    elide: Text.ElideRight
                                    font.pixelSize: Theme.fontNormal
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
                                    color: Theme.text
                                    placeholderText: qsTr("Price")
                                    font.pixelSize: Theme.fontNormal
                                    placeholderTextColor: Theme.secondaryText
                                    background: Rectangle {
                                        color: Theme.background
                                        radius: 4
                                        border.color: Theme.border
                                    }

                                    onTextChanged: itemRect.editedPrice = text
                                }

                                Text {
                                    visible: !itemRect.isEditing
                                    text: currencySymbol + price.toFixed(2)
                                    horizontalAlignment: Text.AlignRight
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontNormal
                                }
                            }

                            Item {
                                Layout.preferredWidth: 120
                                height: 24

                                TextField {
                                    visible: itemRect.isEditing
                                    text: itemRect.editedPortion
                                    anchors.fill: parent
                                    color: Theme.text
                                    placeholderText: qsTr("Portion")
                                    font.pixelSize: Theme.fontNormal
                                    placeholderTextColor: Theme.secondaryText
                                    background: Rectangle {
                                        color: Theme.background
                                        radius: 4
                                        border.color: Theme.border
                                        border.width: 1
                                    }

                                    onTextChanged: itemRect.editedPortion = text
                                }

                                Text {
                                    visible: !itemRect.isEditing
                                    text: portion || "-"
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontNormal
                                }
                            }

                            CheckBox {
                                Layout.preferredWidth: 100
                                checked: itemRect.isEditing ? itemRect.editedAvailable : available
                                enabled: itemRect.isEditing
                                onCheckedChanged: itemRect.editedAvailable = checked
                                font.pixelSize: Theme.fontNormal
                            }

                            CheckBox {
                                Layout.preferredWidth: 100
                                checked: itemRect.isEditing ? itemRect.editedTaxable : taxable
                                enabled: itemRect.isEditing
                                onCheckedChanged: itemRect.editedTaxable = checked
                                font.pixelSize: Theme.fontNormal
                            }

                            Button {
                                text: itemRect.isEditing ? qsTr("Save") : qsTr(
                                                               "Edit")
                                background: Rectangle {
                                    color: Theme.primary()
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
                                    font.pixelSize: Theme.fontNormal
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
                                    font.pixelSize: Theme.fontNormal
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
                            font.pixelSize: Theme.fontNormal
                            color: Theme.text
                            placeholderTextColor: Theme.secondaryText
                            padding: 10
                            background: Rectangle {
                                color: Theme.background
                                radius: 4
                                border.color: Theme.border
                                border.width: 1
                            }
                        }

                        TextField {
                            id: newItemPrice
                            placeholderText: qsTr("Price")
                            width: 200
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            height: 40
                            font.pixelSize: Theme.fontNormal
                            color: Theme.text
                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 10
                            bottomPadding: 10
                            placeholderTextColor: Theme.secondaryText
                            background: Rectangle {
                                color: Theme.background
                                radius: 4
                                border.color: Theme.border
                                border.width: 1
                            }
                        }

                        TextField {
                            id: newItemPortion
                            placeholderText: qsTr("Portion (optional)")
                            width: 150
                            height: 40
                            font.pixelSize: Theme.fontNormal
                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 10
                            bottomPadding: 10
                            color: Theme.text
                            placeholderTextColor: Theme.secondaryText
                            background: Rectangle {
                                color: Theme.background
                                radius: 4
                                border.color: Theme.border
                                border.width: 1
                            }
                        }

                        CheckBox {
                            id: newItemAvailable
                            text: qsTr("Available")
                            checked: true
                            font.pixelSize: Theme.fontNormal
                            Layout.alignment: Qt.AlignVCenter
                            contentItem: Text {
                                text: qsTr("Available")
                                color: Theme.text
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: Theme.fontNormal
                            }
                        }

                        CheckBox {
                            id: newItemTaxable
                            text: qsTr("Taxable")
                            checked: true
                            font.pixelSize: Theme.fontNormal
                            Layout.alignment: Qt.AlignVCenter
                            contentItem: Text {
                                text: qsTr("Taxable")
                                color: Theme.text
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: Theme.fontNormal
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
                            color: Theme.primary()
                            radius: 4
                        }
                        contentItem: Text {
                            text: qsTr("Add Menu Item")
                            color: "white"
                            font.bold: true
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontNormal
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

                            MenuService.addMenuItem(
                                        itemNameTrimmed,
                                        MenuService.currentCategoryId, price,
                                        newItemAvailable.checked,
                                        newItemTaxable.checked, portionTrimmed)

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
