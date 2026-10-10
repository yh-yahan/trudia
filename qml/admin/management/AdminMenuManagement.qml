import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0
import "../../components"

Item {
    id: root

    width: 1100
    height: 720

    property string currencySymbol: SettingService.currencySymbol()
    property int currentItemId: -1
    property string currentItemName: ""

    function formatMoney(value) {
        const number = Number(value)
        if (isNaN(number))
            return currencySymbol + "0.00"
        return currencySymbol + number.toFixed(2)
    }

    function formatDelta(delta) {
        const number = Number(delta)
        if (isNaN(number) || number === 0)
            return qsTr("No charge")
        const sign = number > 0 ? "+" : "-"
        return sign + currencySymbol + Math.abs(number).toFixed(2)
    }

    function parsePrice(text) {
        const value = parseFloat(text)
        if (isNaN(value) || value < 0)
            return 0
        return value
    }

    function parseDelta(text) {
        const trimmed = String(text).trim()
        if (trimmed.length === 0)
            return 0
        const value = parseFloat(trimmed)
        if (isNaN(value))
            return 0
        return value
    }

    function clearItemSelection() {
        currentItemId = -1
        currentItemName = ""
        editName.text = ""
        editPrice.text = ""
        editPortion.text = ""
        editAvailable.checked = true
        editTaxable.checked = true
        if (ModifiersService.currentMenuId !== undefined)
            ModifiersService.currentMenuId = -1
    }

    function selectItem(itemId, name, price, portion, available, taxable) {
        currentItemId = itemId
        currentItemName = name
        editName.text = name
        editPrice.text = Number(price).toFixed(2)
        editPortion.text = portion || ""
        editAvailable.checked = available
        editTaxable.checked = taxable
        ModifiersService.currentMenuId = itemId
        if (ModifiersService.reloadForMenu)
            ModifiersService.reloadForMenu(itemId)
        else if (ModifiersService.menuModifierModel)
            ModifiersService.menuModifierModel.loadGroupsForMenu(itemId)
    }

    function groupAlreadyAttached(groupId) {
        const model = ModifiersService.menuModifierModel
        if (!model)
            return false
        for (let i = 0; i < model.rowCount(); ++i) {
            if (model.data(model.index(i, 0), 257) === groupId)
                return true
        }
        return false
    }

    property int stockUseItemId: -1

    Loader {
        id: stockUseLoader

        anchors.fill: parent
        visible: stockUseItemId !== -1
        active: stockUseItemId !== -1
        source: "./StockUse.qml"

        z: 9999

        onLoaded: {
            item.menuItemId = stockUseItemId
            item.menuItemName = root.currentItemName
            item.menuItemPrice = root.parsePrice(editPrice.text)
            item.menuItemPortion = editPortion.text
            item.menuItemAvailable = editAvailable.checked

            item.closed.connect(function () {
                stockUseItemId = -1
            })
        }
    }

    ConfirmationDialog {
        id: confirmationDialog
        anchors.centerIn: parent
    }

    ConfirmationDialog {
        id: modifierConfirmationDialog

        property int menuItemId: -1
        property int groupId: -1

        title: qsTr("Remove Modifier Group")
        message: qsTr("Removing this group will also delete its associated modifier rules from inventory recipes. Are you sure you want to continue?")
        type: "delete"

        confirmCallback: function(confirmed) {
            if (!confirmed)
                return

            ModifiersService.detachGroupFromMenu(menuItemId, groupId)

            if (ModifiersService.reloadForMenu)
                ModifiersService.reloadForMenu(menuItemId)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: Theme.background

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 12

                Text {
                    text: qsTr("Menu")
                    color: Theme.text
                    font.bold: true
                    font.pixelSize: Theme.fontNormal + 2
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Modifier groups")
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    leftPadding: 14
                    rightPadding: 14
                    topPadding: 8
                    bottomPadding: 8
                    background: Rectangle {
                        color: Theme.surface
                        radius: 6
                        border.color: Theme.border
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: modifierLibrary.open()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Categories
            Rectangle {
                Layout.preferredWidth: 240
                Layout.fillHeight: true
                color: Theme.background

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

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
                        spacing: 6

                        delegate: Rectangle {
                            id: categoryRect

                            required property int id
                            required property string name
                            required property int index

                            property bool isEditing: false
                            property string editedCategory: name
                            property string originalCategory: name
                            property bool selected: MenuService.currentCategoryId === id

                            width: categoryListView.width
                            height: 44
                            radius: 8
                            color: selected ? Theme.primary() : Theme.surface

                            function commitEdit() {
                                const newName = editedCategory.trim()
                                if (newName.length === 0 || newName === originalCategory) {
                                    isEditing = false
                                    editedCategory = originalCategory
                                    return
                                }
                                MenuService.renameCategory(id, newName)
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
                                        confirmationDialog.title = qsTr("Delete Category")
                                        confirmationDialog.message = qsTr('Are you sure you want to delete "%1"? All menu items within "%1" will be deleted.').arg(name)
                                        confirmationDialog.confirmCallback = function (confirmed) {
                                            if (confirmed) {
                                                if (MenuService.currentCategoryId === id)
                                                    root.clearItemSelection()
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
                                elide: Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 12
                                font.pixelSize: Theme.fontNormal
                                color: categoryRect.selected ? "white" : Theme.text
                            }

                            TextField {
                                id: editField
                                visible: categoryRect.isEditing
                                text: categoryRect.editedCategory
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 8
                                color: Theme.text
                                selectByMouse: true
                                font.pixelSize: Theme.fontNormal
                                background: Rectangle {
                                    color: Theme.background
                                    radius: 6
                                    border.color: Theme.primary()
                                }
                                onTextChanged: categoryRect.editedCategory = text
                                onActiveFocusChanged: {
                                    if (!activeFocus && categoryRect.isEditing)
                                        categoryRect.commitEdit()
                                }
                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
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
                                        root.clearItemSelection()
                                    }
                                }
                                onPressAndHold: categoryMenu.popup(categoryRect)
                            }
                        }
                    }

                    TextField {
                        id: newCategoryField
                        placeholderText: qsTr("New category name")
                        Layout.fillWidth: true
                        implicitHeight: 40
                        font.pixelSize: Theme.fontNormal
                        color: Theme.text
                        leftPadding: 10
                        rightPadding: 10
                        placeholderTextColor: Theme.secondaryText
                        onAccepted: addCategoryButton.clicked()
                        background: Rectangle {
                            color: Theme.background
                            radius: 8
                            border.color: Theme.border
                            border.width: 1
                        }
                    }

                    Button {
                        id: addCategoryButton
                        Layout.fillWidth: true
                        implicitHeight: 42
                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus
                        background: Rectangle {
                            color: Theme.primary()
                            radius: 8
                        }
                        contentItem: Text {
                            text: qsTr("Add category")
                            color: "white"
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            const name = newCategoryField.text.trim()
                            if (name.length === 0)
                                return
                            if (MenuService.addCategory(name))
                                newCategoryField.text = ""
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: Theme.border
            }

            // Items
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.background

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Text {
                        text: MenuService.currentCategoryId !== -1 ? qsTr("Menu items") : qsTr("Select a category")
                        font.bold: true
                        font.pixelSize: Theme.fontNormal
                        color: Theme.text
                    }

                    ListView {
                        id: itemListView
                        visible: MenuService.currentCategoryId !== -1
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: MenuService.menuItemModel
                        clip: true
                        spacing: 6

                        delegate: Rectangle {
                            id: itemCard

                            required property int id
                            required property string item
                            required property double price
                            required property string portion
                            required property bool available
                            required property bool taxable

                            property bool selected: root.currentItemId === id

                            width: itemListView.width
                            height: 58
                            radius: 8
                            color: selected ? Theme.surface : Theme.background
                            border.width: 1
                            border.color: selected ? Theme.primary() : Theme.border

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: item
                                        color: Theme.text
                                        elide: Text.ElideRight
                                        font.pixelSize: Theme.fontNormal
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: {
                                            let bits = []
                                            bits.push(portion && portion.length ? portion : qsTr("No portion"))
                                            if (!available)
                                                bits.push(qsTr("Hidden"))
                                            if (!taxable)
                                                bits.push(qsTr("Non-taxable"))
                                            return bits.join(" · ")
                                        }
                                        color: Theme.secondaryText
                                        font.pixelSize: Theme.fontSmall
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                Text {
                                    text: root.formatMoney(price)
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.selectItem(id, item, price, portion, available, taxable)
                            }
                        }
                    }

                    Text {
                        visible: MenuService.currentCategoryId !== -1 && itemListView.count === 0
                        text: qsTr("No items in this category yet.")
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontNormal
                    }

                    Rectangle {
                        visible: MenuService.currentCategoryId !== -1
                        Layout.fillWidth: true
                        implicitHeight: newItemColumn.implicitHeight + 16
                        radius: 10
                        color: Theme.surface
                        border.color: Theme.border
                        border.width: 1

                        ColumnLayout {
                            id: newItemColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 8
                            spacing: 8

                            RowLayout {
                                spacing: 8

                                TextField {
                                    id: newItemName
                                    placeholderText: qsTr("Item name")
                                    Layout.fillWidth: true
                                    implicitHeight: 38
                                    font.pixelSize: Theme.fontNormal
                                    color: Theme.text
                                    leftPadding: 10
                                    rightPadding: 10
                                    placeholderTextColor: Theme.secondaryText
                                    background: Rectangle {
                                        color: Theme.background
                                        radius: 6
                                        border.color: Theme.border
                                    }
                                }

                                TextField {
                                    id: newItemPrice
                                    placeholderText: qsTr("Price")
                                    Layout.preferredWidth: 90
                                    implicitHeight: 38
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    font.pixelSize: Theme.fontNormal
                                    color: Theme.text
                                    leftPadding: 10
                                    rightPadding: 10
                                    placeholderTextColor: Theme.secondaryText
                                    background: Rectangle {
                                        color: Theme.background
                                        radius: 6
                                        border.color: Theme.border
                                    }
                                }

                                TextField {
                                    id: newItemPortion
                                    placeholderText: qsTr("Portion")
                                    Layout.preferredWidth: 100
                                    implicitHeight: 38
                                    font.pixelSize: Theme.fontNormal
                                    color: Theme.text
                                    leftPadding: 10
                                    rightPadding: 10
                                    placeholderTextColor: Theme.secondaryText
                                    background: Rectangle {
                                        color: Theme.background
                                        radius: 6
                                        border.color: Theme.border
                                    }
                                }
                            }

                            RowLayout {
                                spacing: 12

                                CheckBox {
                                    id: newItemAvailable
                                    checked: true
                                    font.pixelSize: Theme.fontNormal
                                    contentItem: Text {
                                        text: qsTr("Available")
                                        color: Theme.text
                                        leftPadding: 24
                                        font.pixelSize: Theme.fontNormal
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                CheckBox {
                                    id: newItemTaxable
                                    checked: true
                                    font.pixelSize: Theme.fontNormal
                                    contentItem: Text {
                                        text: qsTr("Taxable")
                                        color: Theme.text
                                        leftPadding: 24
                                        font.pixelSize: Theme.fontNormal
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                Button {
                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus
                                    implicitHeight: 36
                                    leftPadding: 16
                                    rightPadding: 16
                                    background: Rectangle {
                                        color: Theme.primary()
                                        radius: 6
                                    }
                                    contentItem: Text {
                                        text: qsTr("Add item")
                                        color: "white"
                                        font.bold: true
                                        font.pixelSize: Theme.fontNormal
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: {
                                        const name = newItemName.text.trim()
                                        if (name.length === 0 || MenuService.currentCategoryId === -1)
                                            return
                                        if (newItemPrice.text.trim().length === 0)
                                            return

                                        MenuService.addMenuItem(
                                                    name,
                                                    MenuService.currentCategoryId,
                                                    root.parsePrice(newItemPrice.text),
                                                    newItemAvailable.checked,
                                                    newItemTaxable.checked,
                                                    newItemPortion.text.trim())

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

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: Theme.border
            }

            // Item detail and modifiers
            Rectangle {
                Layout.preferredWidth: 360
                Layout.fillHeight: true
                color: Theme.background

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    visible: root.currentItemId !== -1

                    Text {
                        text: qsTr("Item details")
                        font.bold: true
                        font.pixelSize: Theme.fontNormal
                        color: Theme.text
                    }

                    TextField {
                        id: editName
                        placeholderText: qsTr("Item name")
                        Layout.fillWidth: true
                        implicitHeight: 38
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        leftPadding: 10
                        rightPadding: 10
                        placeholderTextColor: Theme.secondaryText
                        background: Rectangle {
                            color: Theme.surface
                            radius: 6
                            border.color: Theme.border
                        }
                    }

                    RowLayout {
                        spacing: 8

                        TextField {
                            id: editPrice
                            placeholderText: qsTr("Price")
                            Layout.fillWidth: true
                            implicitHeight: 38
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                            leftPadding: 10
                            rightPadding: 10
                            placeholderTextColor: Theme.secondaryText
                            background: Rectangle {
                                color: Theme.surface
                                radius: 6
                                border.color: Theme.border
                            }
                        }

                        TextField {
                            id: editPortion
                            placeholderText: qsTr("Portion")
                            Layout.fillWidth: true
                            implicitHeight: 38
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                            leftPadding: 10
                            rightPadding: 10
                            placeholderTextColor: Theme.secondaryText
                            background: Rectangle {
                                color: Theme.surface
                                radius: 6
                                border.color: Theme.border
                            }
                        }
                    }

                    RowLayout {
                        CheckBox {
                            id: editAvailable
                            contentItem: Text {
                                text: qsTr("Available")
                                color: Theme.text
                                leftPadding: 24
                                font.pixelSize: Theme.fontNormal
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        CheckBox {
                            id: editTaxable
                            contentItem: Text {
                                text: qsTr("Taxable")
                                color: Theme.text
                                leftPadding: 24
                                font.pixelSize: Theme.fontNormal
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    RowLayout {
                        spacing: 8

                        Button {
                            Layout.fillWidth: true
                            implicitHeight: 38
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            background: Rectangle {
                                color: Theme.primary()
                                radius: 6
                            }
                            contentItem: Text {
                                text: qsTr("Save")
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontNormal
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                const name = editName.text.trim()
                                if (name.length === 0)
                                    return
                                const ok = MenuService.editMenuItem(
                                             root.currentItemId,
                                             name,
                                             MenuService.currentCategoryId,
                                             root.parsePrice(editPrice.text),
                                             editAvailable.checked,
                                             editTaxable.checked,
                                             editPortion.text.trim())
                                if (ok)
                                    root.currentItemName = name
                            }
                        }

                        Button {
                            implicitHeight: 38
                            leftPadding: 14
                            rightPadding: 14
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            background: Rectangle {
                                color: "#c62828"
                                radius: 6
                            }
                            contentItem: Text {
                                text: qsTr("Delete")
                                color: "white"
                                font.pixelSize: Theme.fontNormal
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                confirmationDialog.title = qsTr("Delete Item")
                                confirmationDialog.message = qsTr('Are you sure you want to delete "%1"?').arg(root.currentItemName)
                                confirmationDialog.confirmCallback = function (confirmed) {
                                    if (confirmed) {
                                        MenuService.removeMenuItem(root.currentItemId)
                                        root.clearItemSelection()
                                    }
                                }
                                confirmationDialog.open()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.border
                        Layout.topMargin: 4
                    }

                    RowLayout {
                        Text {
                            text: qsTr("Stock use")
                            font.pixelSize: Theme.fontNormal
                            color: Theme.text
                            Layout.fillWidth: true
                        }

                        Button {
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            flat: true
                            contentItem: Text {
                                text: qsTr("Edit")
                                color: Theme.primary()
                                font.pixelSize: Theme.fontNormal
                                font.bold: true
                                font.underline: true
                            }
                            background: null
                            onClicked: {
                                root.stockUseItemId = root.currentItemId
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.border
                        Layout.topMargin: 4
                    }

                    RowLayout {
                        Text {
                            text: qsTr("Modifiers")
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                            color: Theme.text
                            Layout.fillWidth: true
                        }

                        Button {
                            text: qsTr("Manage")
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 6
                            bottomPadding: 6
                            background: Rectangle {
                                color: Theme.surface
                                radius: 6
                                border.color: Theme.border
                            }
                            contentItem: Text {
                                text: parent.text
                                color: Theme.text
                                font.pixelSize: Theme.fontSmall
                                horizontalAlignment: Text.AlignHCenter
                            }
                            onClicked: modifierLibrary.open()
                        }
                    }

                    ListView {
                        id: attachedGroupList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: ModifiersService.menuModifierModel

                        delegate: Rectangle {
                            id: attachedGroup

                            required property int id
                            required property string name
                            required property string selectionType
                            required property int minSelect
                            required property var maxSelect
                            required property bool isRequired
                            required property var modifiers

                            width: attachedGroupList.width
                            implicitHeight: attachedCol.implicitHeight + 16
                            radius: 8
                            color: Theme.surface
                            border.color: Theme.border
                            border.width: 1

                            ColumnLayout {
                                id: attachedCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 10
                                spacing: 4

                                RowLayout {
                                    Text {
                                        text: name
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        font.bold: true
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                    }
                                    
                                    Button {
                                        hoverEnabled: false
                                        focusPolicy: Qt.NoFocus
                                        leftPadding: 8
                                        rightPadding: 8
                                        topPadding: 4
                                        bottomPadding: 4
                                        background: Rectangle {
                                            color: Theme.background
                                            radius: 4
                                            border.color: Theme.border
                                        }
                                        contentItem: Text {
                                            text: qsTr("Remove")
                                            color: Theme.secondaryText
                                            font.pixelSize: Theme.fontSmall
                                        }
                                        onClicked: {
                                            modifierConfirmationDialog.open()
                                            confirmationDialog.groupId = attachedGroup.id
                                            confirmationDialog.open()
                                        }
                                    }
                                }

                                Text {
                                    text: {
                                        const maxLabel = (maxSelect === undefined || maxSelect === null || maxSelect === "")
                                                       ? qsTr("any")
                                                       : String(maxSelect)
                                        const req = isRequired ? qsTr("Required") : qsTr("Optional")
                                        return req + " · " + selectionType + qsTr(" · min ") + minSelect + qsTr(" · max ") + maxLabel
                                    }
                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontSmall
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Repeater {
                                    model: modifiers
                                    Text {
                                        required property var modelData
                                        text: {
                                            const label = modelData.name || ""
                                            const extra = modelData.isDefault ? qsTr(" (default)") : ""
                                            return "• " + label + extra + "  " + root.formatDelta(modelData.priceDelta)
                                        }
                                        color: Theme.text
                                        font.pixelSize: Theme.fontSmall
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        visible: attachedGroupList.count === 0
                        text: qsTr("No modifier groups on this item.")
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontSmall
                    }

                    ComboBox {
                        id: attachBox
                        Layout.fillWidth: true
                        implicitHeight: 40
                        textRole: "name"
                        valueRole: "id"
                        model: ModifiersService.modifierModel
                        displayText: qsTr("Attach a group")
                        font.pixelSize: Theme.fontNormal
                        onActivated: function (index) {
                            const groupId = valueAt(index)
                            if (!groupId || root.currentItemId === -1)
                                return
                            ModifiersService.attachGroupToMenu(root.currentItemId, groupId)
                            if (ModifiersService.reloadForMenu)
                                ModifiersService.reloadForMenu(root.currentItemId)
                            currentIndex = -1
                        }
                    }
                }

                Column {
                    visible: root.currentItemId === -1
                    anchors.centerIn: parent
                    width: parent.width - 40
                    spacing: 8

                    Text {
                        width: parent.width
                        text: qsTr("Select an item")
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        width: parent.width
                        text: qsTr("Edit details and attach modifier groups here.")
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontNormal
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    Dialog {
        id: modifierLibrary
        title: qsTr("Modifier groups")
        modal: true
        anchors.centerIn: Overlay.overlay
        width: Math.min(760, root.width - 24)
        height: Math.min(620, root.height - 24)
        standardButtons: Dialog.Close
        font.pixelSize: Theme.fontNormal

        background: Rectangle {
            color: Theme.background
            radius: 12
            border.color: Theme.border
        }

        onOpened: {
            if (ModifiersService.reload)
                ModifiersService.reload()
            else if (ModifiersService.modifierModel)
                ModifiersService.modifierModel.loadGroups()
        }

        contentItem: ColumnLayout {
            spacing: 12

            ListView {
                id: libraryList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 10
                model: ModifiersService.modifierModel

                delegate: Rectangle {
                    id: groupCard

                    required property int id
                    required property string name
                    required property string selectionType
                    required property int minSelect
                    required property var maxSelect
                    required property bool isRequired
                    required property var modifiers

                    width: libraryList.width
                    implicitHeight: groupBody.implicitHeight + 20
                    radius: 10
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1

                    ColumnLayout {
                        id: groupBody
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 8

                        RowLayout {
                            Text {
                                text: name
                                color: Theme.text
                                font.bold: true
                                font.pixelSize: Theme.fontNormal
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                text: isRequired ? qsTr("Required") : qsTr("Optional")
                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontSmall
                            }
                        }

                        Text {
                            text: {
                                const maxLabel = (maxSelect === undefined || maxSelect === null || maxSelect === "")
                                               ? qsTr("any")
                                               : String(maxSelect)
                                return selectionType + qsTr(" · min ") + minSelect + qsTr(" · max ") + maxLabel
                            }
                            color: Theme.secondaryText
                            font.pixelSize: Theme.fontSmall
                        }

                        Repeater {
                            model: modifiers

                            RowLayout {
                                required property var modelData
                                spacing: 8
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    text: (modelData.name || "")
                                          + (modelData.isDefault ? qsTr(" · default") : "")
                                          + (modelData.isAvailable === false ? qsTr(" · hidden") : "")
                                          + "  " + root.formatDelta(modelData.priceDelta)
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                    wrapMode: Text.WordWrap
                                }

                                Button {
                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus
                                    leftPadding: 8
                                    rightPadding: 8
                                    topPadding: 4
                                    bottomPadding: 4
                                    background: Rectangle {
                                        color: Theme.background
                                        radius: 4
                                        border.color: Theme.border
                                    }
                                    contentItem: Text {
                                        text: qsTr("Delete")
                                        color: Theme.secondaryText
                                        font.pixelSize: Theme.fontSmall
                                    }
                                    onClicked: {
                                        confirmationDialog.title = qsTr("Delete option")
                                        confirmationDialog.message = qsTr('Delete "%1"?').arg(modelData.name)
                                        confirmationDialog.confirmCallback = function (confirmed) {
                                            if (confirmed) {
                                                ModifiersService.deleteModifier(modelData.id)
                                                if (ModifiersService.reload)
                                                    ModifiersService.reload()
                                            }
                                        }
                                        confirmationDialog.open()
                                    }
                                }
                            }
                        }

                        RowLayout {
                            spacing: 6

                            TextField {
                                id: optionName
                                placeholderText: qsTr("Option name")
                                Layout.fillWidth: true
                                implicitHeight: 34
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                                leftPadding: 8
                                placeholderTextColor: Theme.secondaryText
                                background: Rectangle {
                                    color: Theme.background
                                    radius: 6
                                    border.color: Theme.border
                                }
                            }

                            TextField {
                                id: optionDelta
                                placeholderText: qsTr("+Price")
                                Layout.preferredWidth: 80
                                implicitHeight: 34
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                                leftPadding: 8
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                placeholderTextColor: Theme.secondaryText
                                background: Rectangle {
                                    color: Theme.background
                                    radius: 6
                                    border.color: Theme.border
                                }
                            }

                            CheckBox {
                                id: optionDefault
                                contentItem: Text {
                                    text: qsTr("Default")
                                    color: Theme.text
                                    leftPadding: 22
                                    font.pixelSize: Theme.fontSmall
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Button {
                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus
                                implicitHeight: 34
                                leftPadding: 10
                                rightPadding: 10
                                background: Rectangle {
                                    color: Theme.primary()
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: qsTr("Add")
                                    color: "white"
                                    font.pixelSize: Theme.fontSmall
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    const label = optionName.text.trim()
                                    if (label.length === 0)
                                        return
                                    ModifiersService.createModifier(
                                                groupCard.id,
                                                label,
                                                root.parseDelta(optionDelta.text),
                                                optionDefault.checked,
                                                true)
                                    optionName.text = ""
                                    optionDelta.text = ""
                                    optionDefault.checked = false
                                    if (ModifiersService.reload)
                                        ModifiersService.reload()
                                }
                            }
                        }

                        Button {
                            Layout.alignment: Qt.AlignRight
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 6
                            bottomPadding: 6
                            background: Rectangle {
                                color: "#c62828"
                                radius: 6
                            }
                            contentItem: Text {
                                text: qsTr("Delete group")
                                color: "white"
                                font.pixelSize: Theme.fontSmall
                            }
                            onClicked: {
                                confirmationDialog.title = qsTr("Delete group")
                                confirmationDialog.message = qsTr('Delete "%1" and its options?').arg(name)
                                confirmationDialog.confirmCallback = function (confirmed) {
                                    if (confirmed) {
                                        ModifiersService.deleteGroup(groupCard.id)
                                        if (ModifiersService.reload)
                                            ModifiersService.reload()
                                        if (root.currentItemId !== -1 && ModifiersService.reloadForMenu)
                                            ModifiersService.reloadForMenu(root.currentItemId)
                                    }
                                }
                                confirmationDialog.open()
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: newGroupCol.implicitHeight + 16
                radius: 10
                color: Theme.surface
                border.color: Theme.border
                border.width: 1

                ColumnLayout {
                    id: newGroupCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 8
                    spacing: 8

                    Text {
                        text: qsTr("New group")
                        color: Theme.text
                        font.bold: true
                        font.pixelSize: Theme.fontNormal
                    }

                    TextField {
                        id: groupName
                        placeholderText: qsTr("Group name, e.g. Size")
                        Layout.fillWidth: true
                        implicitHeight: 36
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        leftPadding: 10
                        placeholderTextColor: Theme.secondaryText
                        background: Rectangle {
                            color: Theme.background
                            radius: 6
                            border.color: Theme.border
                        }
                    }

                    RowLayout {
                        spacing: 8

                        ComboBox {
                            id: groupType
                            Layout.preferredWidth: 140
                            model: ["single", "multiple"]
                            font.pixelSize: Theme.fontNormal
                        }

                        TextField {
                            id: groupMin
                            text: "0"
                            placeholderText: qsTr("Min")
                            Layout.preferredWidth: 70
                            implicitHeight: 36
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                            leftPadding: 8
                            inputMethodHints: Qt.ImhDigitsOnly
                            background: Rectangle {
                                color: Theme.background
                                radius: 6
                                border.color: Theme.border
                            }
                        }

                        TextField {
                            id: groupMax
                            placeholderText: qsTr("Max")
                            Layout.preferredWidth: 70
                            implicitHeight: 36
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                            leftPadding: 8
                            inputMethodHints: Qt.ImhDigitsOnly
                            background: Rectangle {
                                color: Theme.background
                                radius: 6
                                border.color: Theme.border
                            }
                        }

                        CheckBox {
                            id: groupRequired
                            contentItem: Text {
                                text: qsTr("Required")
                                color: Theme.text
                                leftPadding: 24
                                font.pixelSize: Theme.fontNormal
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        implicitHeight: 38
                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus
                        background: Rectangle {
                            color: Theme.primary()
                            radius: 6
                        }
                        contentItem: Text {
                            text: qsTr("Create group")
                            color: "white"
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            const name = groupName.text.trim()
                            if (name.length === 0)
                                return
                            const minVal = parseInt(groupMin.text)
                            const maxText = groupMax.text.trim()
                            const maxVal = maxText.length ? parseInt(maxText) : null
                            const created = ModifiersService.createGroup(
                                              name,
                                              groupType.currentText,
                                              isNaN(minVal) ? 0 : minVal,
                                              maxVal,
                                              groupRequired.checked)
                            if (created !== undefined && created !== false && created !== -1) {
                                groupName.text = ""
                                groupMin.text = "0"
                                groupMax.text = ""
                                groupRequired.checked = false
                                groupType.currentIndex = 0
                                if (ModifiersService.reload)
                                    ModifiersService.reload()
                            }
                        }
                    }
                }
            }
        }
    }
}
