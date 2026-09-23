import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0
import "../../components"

Item {
    id: root
    width: 800
    height: 600

    readonly property var typeCatalog: [
        { key: "ingredient", label: qsTr("Ingredient") },
        { key: "sellable", label: qsTr("Product/Sellable") },
        { key: "packaging", label: qsTr("Packaging") },
        { key: "prep", label: qsTr("Prep") }
    ]

    readonly property var unitCatalog: [
        { key: "g", label: qsTr("Gram") },
        { key: "kg", label: qsTr("Kilogram") },
        { key: "oz", label: qsTr("Ounce") },
        { key: "lb", label: qsTr("Pound") },
        { key: "ml", label: qsTr("Milliliter") },
        { key: "L", label: qsTr("Liter") },
        { key: "fl_oz", label: qsTr("Fluid ounce") },
        { key: "gal", label: qsTr("Gallon") },
        { key: "qt", label: qsTr("Quart") },
        { key: "pt", label: qsTr("Pint") },
        { key: "cup", label: qsTr("Cup") },
        { key: "unit", label: qsTr("Unit") },
        { key: "dozen", label: qsTr("Dozen") },
        { key: "pack", label: qsTr("Pack") },
        { key: "box", label: qsTr("Box") },
        { key: "bag", label: qsTr("Bag") },
        { key: "bottle", label: qsTr("Bottle") },
        { key: "can", label: qsTr("Can") },
        { key: "carton", label: qsTr("Carton") },
        { key: "case", label: qsTr("Case") }
    ]

    readonly property var typeFilterChips: [
        { key: "All", label: qsTr("All") }
    ].concat(typeCatalog)

        property int selectedId: -1
    property bool creating: false
    property bool formOpen: creating || selectedId !== -1
    property string searchText: ""
    property string typeFilter: "All"

    readonly property int filteredCount: {
        var n = 0
        for (var i = 0; i < itemModel.count; ++i) {
            if (matchesFilters(itemModel.get(i)))
                ++n
        }
        return n
    }

    readonly property int lowStockCount: {
        var n = 0
        for (var i = 0; i < itemModel.count; ++i) {
            var it = itemModel.get(i)
            if (it.isActive && it.quantity <= it.lowQuantity)
                ++n
        }
        return n
    }

    function catalogIndex(catalog, key) {
        for (var i = 0; i < catalog.length; ++i) {
            if (catalog[i].key === key)
                return i
        }
        return 0
    }

    function catalogKey(catalog, index) {
        if (index >= 0 && index < catalog.length)
            return catalog[index].key
        return catalog.length ? catalog[0].key : ""
    }

    function catalogLabel(catalog, key) {
        for (var i = 0; i < catalog.length; ++i) {
            if (catalog[i].key === key)
                return catalog[i].label
        }
        return key || ""
    }

    function matchesFilters(item) {
        if (!item)
            return false
        if (typeFilter !== "All" && item.type !== typeFilter)
            return false
        if (searchText.length > 0
                && item.name.toLowerCase().indexOf(searchText.toLowerCase()) === -1)
            return false
        return true
    }

    function reloadItems() {
        const keepId = selectedId
        itemModel.clear()
        const items = InventoryService.getItems()
        for (var i = 0; i < items.length; ++i)
            itemModel.append(items[i])

        if (creating)
            return

        if (keepId !== -1) {
            const fresh = InventoryService.getItem(keepId)
            if (fresh && fresh.id !== undefined) {
                selectedId = keepId
                applyItemToForm(fresh)
                return
            }
        }

        selectedId = -1
        resetFormDefaults()
    }

    function applyItemToForm(item) {
        formName.text = item.name || ""
        formType.currentIndex = catalogIndex(typeCatalog, item.type)
        formUnit.currentIndex = catalogIndex(unitCatalog, item.baseUnit)
        formQuantity.value = item.quantity || 0
        formLowQuantity.value = item.lowQuantity || 0
        formIsActive.checked = item.isActive !== false
        formIsSellable.checked = !!item.isSellable
    }

    function resetFormDefaults() {
        formName.text = ""
        formType.currentIndex = 0
        formUnit.currentIndex = 0
        formQuantity.value = 0
        formLowQuantity.value = 0
        formIsActive.checked = true
        formIsSellable.checked = false
    }

    function formPayload() {
        return {
            "name": formName.text.trim(),
            "type": catalogKey(typeCatalog, formType.currentIndex),
            "baseUnit": catalogKey(unitCatalog, formUnit.currentIndex),
            "quantity": Number(formQuantity.text),
            "lowQuantity": Number(formLowQuantity.text),
            "isActive": formIsActive.checked,
            "isSellable": formIsSellable.checked
        }
    }

    function startCreate() {
        selectedId = -1
        creating = true
        resetFormDefaults()
        formName.forceActiveFocus()
    }

    function selectItem(itemId) {
        const item = InventoryService.getItem(itemId)
        if (!item || item.id === undefined)
            return
        creating = false
        selectedId = itemId
        applyItemToForm(item)
    }

    function cancelForm() {
        creating = false
        selectedId = -1
        resetFormDefaults()
    }

    function saveForm() {
        if (formName.text.trim().length === 0) {
            formName.forceActiveFocus()
            return
        }

        if (creating) {
            const newId = InventoryService.createItem(formPayload())
            if (newId === -1)  return
            creating = false
            selectedId = newId
            reloadItems()
        } else if (selectedId !== -1) {
            if (!InventoryService.updateItem(selectedId, formPayload())) return
            reloadItems()
        }
    }

    function confirmDelete(itemId, itemName) {
        confirmationDialog.title = qsTr("Delete item")
        confirmationDialog.message = qsTr('Delete "%1"? This cannot be undone.').arg(itemName)
        confirmationDialog.confirmCallback = function (confirmed) {
            if (!confirmed)
                return
            if (InventoryService.removeItem(itemId)) {
                if (selectedId === itemId)
                    cancelForm()
                reloadItems()
            }
        }
        confirmationDialog.open()
    }

    Component.onCompleted: reloadItems()

    ConfirmationDialog {
        id: confirmationDialog
        anchors.centerIn: parent
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true

                Text {
                    text: qsTr("Inventory")
                    font.bold: true
                    font.pixelSize: Theme.fontLarge
                    color: Theme.text
                }

                Text {
                    text: {
                        var parts = [ qsTr("%1 items").arg(itemModel.count) ]
                        if (lowStockCount > 0)
                            parts.push(qsTr("%1 low stock").arg(lowStockCount))
                        return parts.join("  ·  ")
                    }
                    color: lowStockCount > 0 ? "#c45c5c" : Theme.secondaryText
                    font.pixelSize: Theme.fontNormal
                }
            }

            TextField {
                id: searchField
                Layout.preferredWidth: 220
                height: 36
                placeholderText: qsTr("Search items")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
                placeholderTextColor: Theme.secondaryText
                leftPadding: 12
                rightPadding: 12
                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                    border.width: 1
                    border.color: searchField.activeFocus ? Theme.primary() : Theme.border
                }
                onTextChanged: root.searchText = text.trim()
            }

            Button {
                text: qsTr("New item")
                leftPadding: 16
                rightPadding: 16
                topPadding: 8
                bottomPadding: 8
                background: Rectangle {
                    color: Theme.primary()
                    radius: 4
                }
                contentItem: Text {
                    text: qsTr("New item")
                    color: "white"
                    font.bold: true
                    font.pixelSize: Theme.fontNormal
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                onClicked: startCreate()
            }
        }

        Row {
            spacing: 6
            Repeater {
                model: typeFilterChips
                delegate: Rectangle {
                    id: chip
                    required property var modelData
                    height: 28
                    width: chipLabel.implicitWidth + 20
                    radius: 8
                    color: root.typeFilter === modelData.key ? Theme.primary() : Theme.surface
                    border.width: root.typeFilter === modelData.key ? 0 : 1
                    border.color: Theme.border

                    Text {
                        id: chipLabel
                        anchors.centerIn: parent
                        text: modelData.label
                        color: root.typeFilter === modelData.key ? "white" : Theme.text
                        font.pixelSize: Theme.fontNormal
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.typeFilter = chip.modelData.key
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: formOpen ? 320 : -1
                Layout.fillWidth: !formOpen
                Layout.fillHeight: true
                color: Theme.surface
                radius: 12

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Text {
                        visible: filteredCount !== itemModel.count
                        text: qsTr("%1 shown").arg(filteredCount)
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontNormal
                        leftPadding: 8
                    }

                    ListView {
                        id: inventoryList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 6
                        model: itemModel

                        delegate: Item {
                            id: rowWrap
                            width: ListView.view.width
                            height: matchesFilters(model) ? 72 : 0
                            visible: height > 0

                            readonly property bool isLow: quantity <= lowQuantity
                            readonly property bool isSelected: !creating && selectedId === id

                            Rectangle {
                                anchors.fill: parent
                                visible: rowWrap.visible
                                radius: 10
                                color: isSelected ? Theme.background : "transparent"
                                border.width: isSelected ? 1 : 0
                                border.color: Theme.primary()

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Rectangle {
                                        width: 8
                                        height: 40
                                        radius: 4
                                        color: !isActive ? Theme.border
                                                         : (isLow ? "#c45c5c" : Theme.primary())
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: name
                                            color: Theme.text
                                            font.pixelSize: Theme.fontNormal
                                            font.bold: true
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                            opacity: isActive ? 1 : 0.55
                                        }

                                        Text {
                                            text: catalogLabel(typeCatalog, type)
                                                  + "  ·  " + catalogLabel(unitCatalog, baseUnit)
                                            color: Theme.secondaryText
                                            font.pixelSize: Theme.fontNormal
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 2

                                        Text {
                                            text: quantity
                                            color: isLow ? "#c45c5c" : Theme.text
                                            font.pixelSize: Theme.fontNormal
                                            font.bold: true
                                            horizontalAlignment: Text.AlignRight
                                            Layout.alignment: Qt.AlignRight
                                        }

                                        Text {
                                            text: isLow ? qsTr("Low") : qsTr("In stock")
                                            color: isLow ? "#c45c5c" : Theme.secondaryText
                                            font.pixelSize: Theme.fontNormal
                                            horizontalAlignment: Text.AlignRight
                                            Layout.alignment: Qt.AlignRight
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: selectItem(id)
                                }
                            }
                        }
                    }

                    Item {
                        visible: itemModel.count === 0 || filteredCount === 0
                        Layout.fillWidth: true
                        Layout.fillHeight: itemModel.count === 0
                        implicitHeight: itemModel.count === 0 ? 0 : 48

                        Text {
                            anchors.centerIn: parent
                            text: itemModel.count === 0
                                  ? qsTr("No items yet")
                                  : qsTr("No matches")
                            color: Theme.secondaryText
                            font.pixelSize: Theme.fontNormal
                        }
                    }
                }
            }

            Rectangle {
                visible: formOpen
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.surface
                radius: 12

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            Text {
                                text: creating ? qsTr("New item") : qsTr("Edit item")
                                font.bold: true
                                font.pixelSize: Theme.fontLarge
                                color: Theme.text
                            }
                        }

                        Button {
                            visible: !creating && selectedId !== -1
                            text: qsTr("Delete")
                            leftPadding: 14
                            rightPadding: 14
                            topPadding: 6
                            bottomPadding: 6
                            background: Rectangle {
                                color: "#c45c5c"
                                radius: 4
                            }
                            contentItem: Text {
                                text: qsTr("Delete")
                                color: "white"
                                font.pixelSize: Theme.fontNormal
                                horizontalAlignment: Text.AlignHCenter
                            }
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            onClicked: confirmDelete(selectedId, formName.text)
                        }
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: formGrid.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id: formGrid
                            width: parent.width
                            spacing: 12

                            Text {
                                text: qsTr("Name")
                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontNormal
                            }

                            TextField {
                                id: formName
                                Layout.fillWidth: true
                                height: 40
                                placeholderText: qsTr("e.g. Espresso beans")
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                                placeholderTextColor: Theme.secondaryText
                                leftPadding: 12
                                rightPadding: 12
                                background: Rectangle {
                                    color: Theme.background
                                    radius: 4
                                    border.width: 1
                                    border.color: formName.activeFocus ? Theme.primary() : Theme.border
                                }
                                Keys.onReturnPressed: saveForm()
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: qsTr("Type")
                                        color: Theme.secondaryText
                                        font.pixelSize: Theme.fontNormal
                                    }

                                    ComboBox {
                                        id: formType
                                        Layout.fillWidth: true
                                        implicitHeight: 40
                                        model: typeCatalog
                                        textRole: "label"
                                        valueRole: "key"
                                        font.pixelSize: Theme.fontNormal
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: qsTr("Base unit")
                                        color: Theme.secondaryText
                                        font.pixelSize: Theme.fontNormal
                                    }

                                    ComboBox {
                                        id: formUnit
                                        Layout.fillWidth: true
                                        implicitHeight: 40
                                        model: unitCatalog
                                        textRole: "label"
                                        valueRole: "key"
                                        font.pixelSize: Theme.fontNormal
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: qsTr("Quantity")
                                        color: Theme.secondaryText
                                        font.pixelSize: Theme.fontNormal
                                    }

                                    TextField {
                                        id: formQuantity
                                        Layout.fillWidth: true
                                        implicitHeight: 40

                                        text: "0"
                                        placeholderText: "0"
                                        font.pixelSize: Theme.fontNormal

                                        validator: DoubleValidator {
                                            bottom: 0
                                            top: 999999
                                            decimals: 3
                                            notation: DoubleValidator.StandardNotation
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: qsTr("Low-stock alert")
                                        color: Theme.secondaryText
                                        font.pixelSize: Theme.fontNormal
                                    }

                                    TextField {
                                        id: formLowQuantity
                                        Layout.fillWidth: true
                                        implicitHeight: 40

                                        text: "0"
                                        placeholderText: "0"
                                        font.pixelSize: Theme.fontNormal

                                        validator: DoubleValidator {
                                            bottom: 0
                                            top: 999999
                                            decimals: 3
                                            notation: DoubleValidator.StandardNotation
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 1
                                color: Theme.border
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 16

                                CheckBox {
                                    id: formIsActive
                                    checked: true
                                    text: qsTr("Active")
                                    contentItem: Text {
                                        text: qsTr("Active")
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        leftPadding: formIsActive.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                CheckBox {
                                    id: formIsSellable
                                    checked: false
                                    text: qsTr("Sellable")
                                    contentItem: Text {
                                        text: qsTr("Sellable")
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        leftPadding: formIsSellable.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            Text {
                                visible: formQuantity.value <= formLowQuantity.value
                                text: qsTr("This item will show as low stock.")
                                color: "#c45c5c"
                                font.pixelSize: Theme.fontNormal
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Button {
                            text: qsTr("Cancel")
                            Layout.fillWidth: true
                            leftPadding: 16
                            rightPadding: 16
                            topPadding: 12
                            bottomPadding: 12
                            background: Rectangle {
                                color: Theme.background
                                radius: 4
                                border.width: 1
                                border.color: Theme.border
                            }
                            contentItem: Text {
                                text: qsTr("Cancel")
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                                horizontalAlignment: Text.AlignHCenter
                            }
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            onClicked: cancelForm()
                        }

                        Button {
                            text: creating ? qsTr("Create item") : qsTr("Save changes")
                            Layout.fillWidth: true
                            leftPadding: 16
                            rightPadding: 16
                            topPadding: 12
                            bottomPadding: 12
                            background: Rectangle {
                                color: Theme.primary()
                                radius: 4
                            }
                            contentItem: Text {
                                text: creating ? qsTr("Create item") : qsTr("Save changes")
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontNormal
                                horizontalAlignment: Text.AlignHCenter
                            }
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            onClicked: saveForm()
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: itemModel
    }
}
