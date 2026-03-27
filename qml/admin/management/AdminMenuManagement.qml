import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Xeno.Services 1.0
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

    property int selectedCategoryId: -1
    property var categories: []
    property var menuItems: []

    function loadCategories() {
        categories = MenuService.getAllCategories()
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

    Component.onCompleted: loadCategories()

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
                    model: categories
                    clip: true

                    delegate: Rectangle {
                        id: itemRect

                        property bool isEditing: false
                        property string editedCategory: modelData.category
                        property string originalCategory: modelData.category

                        width: parent.width
                        height: 44
                        radius: 4
                        color: ListView.isCurrentItem ? "#9a7bff" : "#1f1f1f"
                        border.color: "#2a2a2a"

                        function commitEdit() {
                            var newName = editedCategory.trim()
                            if (newName.length === 0
                                    || newName === originalCategory) {
                                isEditing = false
                                return
                            }
                            var success = MenuService.renameCategory(
                                        modelData.id, newName)
                            console.log("renameCategory success:", success,
                                        "new name:", newName)
                            if (success) {
                                loadCategories()
                            }
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
                                    categoryListView.currentIndex = index
                                    itemRect.originalCategory = modelData.category
                                    itemRect.editedCategory = modelData.category
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
                                                modelData.category)

                                    confirmationDialog.confirmCallback = function (confirmed) {
                                        if (confirmed) {
                                            MenuService.removeCategory(
                                                        modelData.id)
                                            loadCategories()
                                        }
                                    }
                                    confirmationDialog.open()
                                }
                            }
                        }

                        Text {
                            visible: !itemRect.isEditing
                            text: modelData.category
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            color: ListView.isCurrentItem ? "white" : "#d0d0d0"
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

                            onFocusChanged: {
                                if (focus)
                                    selectAll()
                            }

                            Keys.onReturnPressed: {
                                itemRect.commitEdit()
                                event.accepted = true
                            }

                            Keys.onEscapePressed: {
                                itemRect.cancelEdit()
                                event.accepted = true
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
                                    categoryListView.currentIndex = index
                                    selectedCategoryId = modelData.id
                                    loadMenuItems(selectedCategoryId)
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
                                loadCategories()
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
                    text: selectedCategoryId !== -1 ? qsTr("Menu Items") : qsTr(
                                                          "Select a category")
                    font.bold: true
                    font.pixelSize: 18
                    color: "white"
                }

                Rectangle {
                    visible: selectedCategoryId !== -1
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
                        property string editedPrice: modelData.price.toFixed(2)
                        property string editedPortion: modelData.portion_size
                                                       || ""
                        property bool editedAvailable: modelData.is_available
                        property bool editedTaxable: modelData.is_taxable

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
                                    text: modelData.item
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
                                    text: modelData.price.toFixed(2)
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
                                    text: modelData.portion_size || "-"
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    color: "#d0d0d0"
                                }
                            }

                            CheckBox {
                                Layout.preferredWidth: 100
                                checked: itemRect.isEditing ? itemRect.editedAvailable : modelData.is_available
                                enabled: itemRect.isEditing
                                onCheckedChanged: itemRect.editedAvailable = checked
                            }

                            CheckBox {
                                Layout.preferredWidth: 100
                                checked: itemRect.isEditing ? itemRect.editedTaxable : modelData.is_taxable
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
                                                    modelData.id,
                                                    itemNameTrimmed,
                                                    selectedCategoryId,
                                                    priceVal,
                                                    itemRect.editedAvailable,
                                                    itemRect.editedTaxable,
                                                    portionTrimmed)

                                        if (success) {
                                            loadMenuItems(selectedCategoryId)
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
                                                modelData.item)
                                    confirmationDialog.confirmCallback = function (confirmed) {
                                        if (confirmed) {
                                            MenuService.removeMenuItem(
                                                        modelData.id)
                                            loadMenuItems(selectedCategoryId)
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
                    visible: selectedCategoryId !== -1
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
                                    || selectedCategoryId === -1) {
                                console.warn("Item name, price, and category are required")
                                return
                            }

                            var price = parseFloat(newItemPrice.text)
                            if (isNaN(price) || price < 0) {
                                price = 0.00
                            }

                            MenuService.addMenuItem(itemNameTrimmed,
                                                    selectedCategoryId, price,
                                                    newItemAvailable.checked,
                                                    newItemTaxable.checked,
                                                    portionTrimmed)

                            newItemName.text = ""
                            newItemPrice.text = ""
                            newItemPortion.text = ""
                            newItemAvailable.checked = true
                            newItemTaxable.checked = true

                            loadMenuItems(selectedCategoryId)
                        }
                    }
                }
            }
        }
    }
}
