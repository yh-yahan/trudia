import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0
import "../../components"

Item {
    id: root

    property int menuItemId: -1
    property string menuItemName: ""
    property double menuItemPrice: 0
    property string menuItemPortion: ""
    property bool menuItemAvailable: true
    property string menuOwnerType: "menu_item"

    signal closed()
    signal saved()

    readonly property var typeCatalog: [
        { key: "ingredient", label: qsTr("Ingredient") },
        { key: "finishedProduct", label: qsTr("Packaged product") },
        { key: "packaging", label: qsTr("Packaging") },
        { key: "prep", label: qsTr("Prep") }
    ]
    readonly property var unitCatalog: [
        { key: "g", label: qsTr("Gram") }, { key: "kg", label: qsTr("Kilogram") },
        { key: "oz", label: qsTr("Ounce") }, { key: "lb", label: qsTr("Pound") },
        { key: "ml", label: qsTr("Milliliter") }, { key: "L", label: qsTr("Liter") },
        { key: "fl_oz", label: qsTr("Fluid ounce") }, { key: "gal", label: qsTr("Gallon") },
        { key: "qt", label: qsTr("Quart") }, { key: "pt", label: qsTr("Pint") },
        { key: "cup", label: qsTr("Cup") }, { key: "unit", label: qsTr("Unit") },
        { key: "dozen", label: qsTr("Dozen") }, { key: "pack", label: qsTr("Pack") },
        { key: "box", label: qsTr("Box") }, { key: "bag", label: qsTr("Bag") },
        { key: "bottle", label: qsTr("Bottle") }, { key: "can", label: qsTr("Can") },
        { key: "carton", label: qsTr("Carton") }, { key: "case", label: qsTr("Case") }
    ]

    property string fulfillmentMode: "none"
    property int linkedStockId: -1
    property double packagedQty: 1
    property bool fulfillmentDirty: false
    property string linePickerQuery: ""
    property bool creatingLineStock: false
    property string statusMessage: ""

    ListModel { id: stockModel }
    ListModel { id: packagedStockModel }
    ListModel { id: recipeStockModel }
    ListModel { id: recipeLines }

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

    function formatMoney(value) {
        const symbol = (typeof SettingService !== "undefined" && SettingService.currencySymbol)
                     ? SettingService.currencySymbol() : ""
        const number = Number(value)
        return symbol + (isNaN(number) ? "0.00" : number.toFixed(2))
    }

    function formatQty(value) {
        const number = Number(value)
        if (isNaN(number))
            return "0"
        if (Math.abs(number - Math.round(number)) < 0.0005)
            return String(Math.round(number))
        return Number(number.toFixed(3)).toString()
    }

    function isDefaultComponent(row) {
        return !row || row.modifierId === undefined || row.modifierId === null || row.modifierId === ""
    }

    function defaultComponents(rows) {
        var out = []
        if (!rows)
            return out
        for (var i = 0; i < rows.length; ++i) {
            if (isDefaultComponent(rows[i]))
                out.push(rows[i])
        }
        return out
    }

    function stockById(id) {
        for (var i = 0; i < stockModel.count; ++i) {
            if (stockModel.get(i).id === id)
                return stockModel.get(i)
        }
        return null
    }

    function stockName(id) {
        const it = stockById(id)
        return it ? it.name : qsTr("Unknown item")
    }

    function stockType(id) {
        const it = stockById(id)
        return it ? it.type : ""
    }

    function stockUnit(id) {
        const it = stockById(id)
        return it ? it.baseUnit : "unit"
    }

    function stockQuantity(id) {
        const it = stockById(id)
        return it ? Number(it.quantity) : 0
    }

    function stockLow(id) {
        const it = stockById(id)
        return it ? Number(it.lowQuantity) : 0
    }

    function inferMode(rows) {
        const defaults = defaultComponents(rows)
        if (defaults.length === 0)
            return "none"
        if (defaults.length === 1) {
            const type = defaults[0].type || stockType(defaults[0].inventoryItemId)
            if (type === "finishedProduct")
                return "stock"
        }
        return "recipe"
    }

    function loadComponents(id) {
        if (!InventoryService || typeof InventoryService.getRecipeComponents !== "function" || id < 0)
            return []
        return InventoryService.getRecipeComponents(menuOwnerType, id) || []
    }

    function reloadStock() {
        stockModel.clear()
        packagedStockModel.clear()
        recipeStockModel.clear()
        if (!InventoryService || typeof InventoryService.getItems !== "function")
            return
        const items = InventoryService.getItems()
        for (var i = 0; i < items.length; ++i) {
            const it = items[i]
            if (it.deletedAt)
                continue
            stockModel.append(it)
            if (it.type === "finishedProduct")
                packagedStockModel.append(it)
            if (it.type === "ingredient" || it.type === "prep" || it.type === "packaging")
                recipeStockModel.append(it)
        }
        syncPackagedCombo()
    }

    function syncPackagedCombo() {
        var idx = -1
        for (var i = 0; i < packagedStockModel.count; ++i) {
            if (packagedStockModel.get(i).id === linkedStockId) {
                idx = i
                break
            }
        }
        if (packagedBox)
            packagedBox.currentIndex = idx
    }

    function loadFulfillment() {
        recipeLines.clear()
        linkedStockId = -1
        packagedQty = 1
        creatingLineStock = false
        linePickerQuery = ""
        statusMessage = ""
        if (lineSearchField)
            lineSearchField.text = ""
        if (newLineQty)
            newLineQty.text = "1"

        const rows = loadComponents(menuItemId)
        fulfillmentMode = inferMode(rows)
        const defaults = defaultComponents(rows)

        if (fulfillmentMode === "stock" && defaults.length === 1) {
            linkedStockId = Number(defaults[0].inventoryItemId)
            packagedQty = Number(defaults[0].quantity) || 1
        } else if (fulfillmentMode === "recipe") {
            for (var i = 0; i < defaults.length; ++i) {
                const line = defaults[i]
                recipeLines.append({
                    componentId: line.id || -1,
                    inventoryItemId: line.inventoryItemId,
                    name: line.inventoryItemName || stockName(line.inventoryItemId),
                    type: line.type || stockType(line.inventoryItemId),
                    qty: Number(line.quantity) || 0,
                    unit: line.baseUnit || stockUnit(line.inventoryItemId)
                })
            }
        }
        syncPackagedCombo()
        fulfillmentDirty = false
    }

    function setMode(mode) {
        if (fulfillmentMode === mode)
            return
        fulfillmentMode = mode
        fulfillmentDirty = true
        statusMessage = ""
        if (mode !== "recipe")
            creatingLineStock = false
    }

    function addRecipeLine(inventoryItemId) {
        if (!inventoryItemId || inventoryItemId === -1)
            return
        const typed = Number(newLineQty ? newLineQty.text : 1)
        const addQty = (!isNaN(typed) && typed > 0) ? typed : 1
        for (var i = 0; i < recipeLines.count; ++i) {
            if (recipeLines.get(i).inventoryItemId === inventoryItemId) {
                recipeLines.setProperty(i, "qty", (Number(recipeLines.get(i).qty) || 0) + addQty)
                fulfillmentDirty = true
                return
            }
        }
        const it = stockById(inventoryItemId)
        if (!it)
            return
        recipeLines.append({
            componentId: -1,
            inventoryItemId: it.id,
            name: it.name,
            type: it.type,
            qty: addQty,
            unit: it.baseUnit
        })
        fulfillmentDirty = true
        if (newLineQty)
            newLineQty.text = "1"
        linePickerQuery = ""
        if (lineSearchField)
            lineSearchField.text = ""
    }

    function removeRecipeLine(index) {
        if (index < 0 || index >= recipeLines.count)
            return
        recipeLines.remove(index)
        fulfillmentDirty = true
    }

    function matchesLinePicker(item) {
        if (!item || item.type === "finishedProduct")
            return false
        if (!linePickerQuery.length)
            return true
        return String(item.name).toLowerCase().indexOf(linePickerQuery.toLowerCase()) !== -1
    }

    function replaceDefaultComponents(lines) {
        const existing = defaultComponents(loadComponents(menuItemId))
        for (var i = 0; i < existing.length; ++i) {
            if (!InventoryService.removeRecipeComponent(existing[i].id))
                return false
        }
        for (var j = 0; j < lines.length; ++j) {
            const newId = InventoryService.createRecipeComponent({
                ownerType: menuOwnerType,
                ownerId: menuItemId,
                inventoryItemId: lines[j].inventoryItemId,
                quantity: lines[j].quantity,
                effect: "add",
                sortOrder: j
            })
            if (newId === -1 || newId === undefined || newId === false)
                return false
        }
        return true
    }

    function saveFulfillment() {
        if (menuItemId === -1 || !InventoryService || typeof InventoryService.createRecipeComponent !== "function")
            return false

        var lines = []
        if (fulfillmentMode === "stock") {
            if (linkedStockId === -1 || linkedStockId === undefined) {
                statusMessage = qsTr("Choose a packaged product.")
                if (packagedBox)
                    packagedBox.forceActiveFocus()
                return false
            }
            const qty = Number(packagedQty)
            lines.push({
                inventoryItemId: linkedStockId,
                quantity: (!isNaN(qty) && qty > 0) ? qty : 1
            })
        } else if (fulfillmentMode === "recipe") {
            if (recipeLines.count === 0) {
                statusMessage = qsTr("Add at least one recipe line.")
                return false
            }
            for (var i = 0; i < recipeLines.count; ++i) {
                const line = recipeLines.get(i)
                const qty = Number(line.qty)
                if (isNaN(qty) || qty <= 0) {
                    statusMessage = qsTr("Every recipe line needs a quantity.")
                    return false
                }
                lines.push({ inventoryItemId: line.inventoryItemId, quantity: qty })
            }
        }

        if (!replaceDefaultComponents(lines)) {
            statusMessage = qsTr("Could not save stock use.")
            return false
        }

        fulfillmentDirty = false
        statusMessage = qsTr("Saved")
        reloadStock()
        loadFulfillment()
        root.saved()
        return true
    }

    function clearFulfillment() {
        fulfillmentMode = "none"
        linkedStockId = -1
        packagedQty = 1
        recipeLines.clear()
        fulfillmentDirty = true
        saveFulfillment()
    }

    function createPackagedFromMenu() {
        if (!menuItemName.length)
            return
        const newId = InventoryService.createItem({
            name: menuItemName,
            type: "finishedProduct",
            baseUnit: "unit",
            quantity: 0,
            lowQuantity: 0,
            deletedAt: null,
            salePausedAt: null
        })
        if (newId === -1 || newId === undefined || newId === false)
            return
        reloadStock()
        linkedStockId = newId
        fulfillmentMode = "stock"
        packagedQty = 1
        fulfillmentDirty = true
        syncPackagedCombo()
    }

    function createStockAndAddToRecipe() {
        const name = inlineStockName.text.trim()
        if (!name.length) {
            inlineStockName.forceActiveFocus()
            return
        }
        const newId = InventoryService.createItem({
            name: name,
            type: catalogKey(typeCatalog, inlineStockType.currentIndex),
            baseUnit: catalogKey(unitCatalog, inlineStockUnit.currentIndex),
            quantity: 0,
            lowQuantity: 0,
            deletedAt: null,
            salePausedAt: null
        })
        if (newId === -1 || newId === undefined || newId === false)
            return
        reloadStock()
        addRecipeLine(newId)
        inlineStockName.text = ""
        creatingLineStock = false
    }

    function requestClose() {
        if (!fulfillmentDirty) {
            root.closed()
            return
        }
        confirmationDialog.title = qsTr("Unsaved changes")
        confirmationDialog.message = qsTr("Save stock use for “%1” before leaving?").arg(menuItemName)
        confirmationDialog.type = "saveBeforeLeave"
        confirmationDialog.confirmCallback = function (confirmed) {
            if (confirmed)
                saveFulfillment()
            fulfillmentDirty = false
            root.closed()
        }
        confirmationDialog.open()
    }

    function hydrate() {
        reloadStock()
        loadFulfillment()
    }

    onMenuItemIdChanged: hydrate()
    Component.onCompleted: hydrate()

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

                Button {
                    text: qsTr("Back")
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
                    onClicked: root.requestClose()
                }

                ColumnLayout {
                    spacing: 1
                    Layout.fillWidth: true

                    Text {
                        text: menuItemName.length ? menuItemName : qsTr("Stock use")
                        color: Theme.text
                        font.bold: true
                        font.pixelSize: Theme.fontNormal + 2
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: {
                            var bits = [root.formatMoney(menuItemPrice)]
                            if (menuItemPortion.length)
                                bits.push(menuItemPortion)
                            if (!menuItemAvailable)
                                bits.push(qsTr("Hidden on menu"))
                            return bits.join(" · ")
                        }
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontNormal
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Text {
                    text: fulfillmentDirty ? qsTr("Unsaved") : (statusMessage.length ? statusMessage : qsTr("Saved"))
                    color: fulfillmentDirty ? "#c45c5c" : Theme.secondaryText
                    font.pixelSize: Theme.fontNormal
                }

                Button {
                    visible: fulfillmentMode !== "none"
                    text: qsTr("Don't track")
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8
                    background: Rectangle {
                        color: Theme.surface
                        radius: 6
                        border.color: Theme.border
                    }
                    contentItem: Text {
                        text: parent.text
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: clearFulfillment()
                }

                Button {
                    text: fulfillmentDirty ? qsTr("Save") : qsTr("Saved")
                    enabled: fulfillmentDirty
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    leftPadding: 16
                    rightPadding: 16
                    topPadding: 8
                    bottomPadding: 8
                    background: Rectangle {
                        color: fulfillmentDirty ? Theme.primary() : Theme.surface
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: fulfillmentDirty ? "white" : Theme.secondaryText
                        font.bold: true
                        font.pixelSize: Theme.fontNormal
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: saveFulfillment()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            color: Theme.background

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 8

                Repeater {
                    model: [
                        { key: "none", label: qsTr("Don't track") },
                        { key: "stock", label: qsTr("Packaged") },
                        { key: "recipe", label: qsTr("Recipe") }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        implicitHeight: 32
                        implicitWidth: modeLabel.implicitWidth + 20
                        radius: 6
                        color: fulfillmentMode === modelData.key ? Theme.primary() : Theme.surface
                        border.width: fulfillmentMode === modelData.key ? 0 : 1
                        border.color: Theme.border

                        Text {
                            id: modeLabel
                            anchors.centerIn: parent
                            text: modelData.label
                            color: fulfillmentMode === modelData.key ? "white" : Theme.text
                            font.pixelSize: Theme.fontNormal
                            font.bold: fulfillmentMode === modelData.key
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: setMode(modelData.key)
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    visible: statusMessage.length && fulfillmentDirty
                    text: statusMessage
                    color: "#c45c5c"
                    font.pixelSize: Theme.fontNormal
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        Item {
            visible: fulfillmentMode === "none"
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.centerIn: parent
                width: Math.min(420, parent.width - 48)
                spacing: 8

                Text {
                    width: parent.width
                    text: qsTr("A sale of this item will not change stock")
                    color: Theme.text
                    font.bold: true
                    font.pixelSize: Theme.fontNormal
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            visible: fulfillmentMode === "stock"
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                width: 420
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Theme.background

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    spacing: 10

                    Text {
                        text: qsTr("Packaged product")
                        font.bold: true
                        color: Theme.text
                        font.pixelSize: Theme.fontMedium
                    }
                    Text {
                        text: qsTr("One counted item is deducted per sale.")
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontNormal
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    ComboBox {
                        id: packagedBox
                        Layout.fillWidth: true
                        implicitHeight: 40
                        model: packagedStockModel
                        textRole: "name"
                        valueRole: "id"
                        displayText: currentIndex >= 0 ? currentText : qsTr("Choose a packaged product")
                        onActivated: function (index) {
                            linkedStockId = packagedStockModel.get(index).id
                            fulfillmentDirty = true
                        }
                    }

                    RowLayout {
                        Text {
                            text: qsTr("Qty per sale")
                            color: Theme.secondaryText
                            font.pixelSize: Theme.fontNormal
                        }
                        TextField {
                            Layout.preferredWidth: 90
                            implicitHeight: 38
                            text: String(packagedQty)
                            color: Theme.text
                            leftPadding: 8
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            background: Rectangle {
                                color: Theme.surface
                                radius: 6
                                border.color: Theme.border
                            }
                            onEditingFinished: {
                                const value = Number(text)
                                if (!isNaN(value) && value > 0) {
                                    packagedQty = value
                                    fulfillmentDirty = true
                                }
                            }
                        }
                    }

                    Text {
                        visible: packagedStockModel.count === 0
                        text: qsTr("No packaged products in inventory yet.")
                        color: Theme.secondaryText
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Button {
                        Layout.fillWidth: true
                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        topPadding: 5
                        bottomPadding: 5

                        background: Rectangle {
                            color: Theme.surface
                            radius: 4
                            border.color: Theme.border
                        }
                        contentItem: Text {
                            text: qsTr("Create packaged item “%1”").arg(menuItemName)
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                        onClicked: createPackagedFromMenu()
                    }

                    Text {
                        visible: linkedStockId !== -1
                        text: {
                            const it = stockById(linkedStockId)
                            if (!it)
                                return ""
                            const low = Number(it.quantity) <= Number(it.lowQuantity)
                            return qsTr("On hand %1 %2").arg(formatQty(it.quantity)).arg(catalogLabel(unitCatalog, it.baseUnit))
                                   + (low ? qsTr(" · Low") : "")
                        }
                        color: {
                            const it = stockById(linkedStockId)
                            return (it && Number(it.quantity) <= Number(it.lowQuantity)) ? "#c45c5c" : Theme.secondaryText
                        }
                        font.pixelSize: Theme.fontNormal
                    }
                }
            }
        }

        RowLayout {
            visible: fulfillmentMode === "recipe"
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.background

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Text {
                            text: qsTr("Recipe")
                            font.bold: true
                            color: Theme.text
                            Layout.fillWidth: true
                            font.pixelSize: Theme.fontMedium
                        }
                        Text {
                            text: qsTr("%1 lines").arg(recipeLines.count)
                            color: Theme.secondaryText
                            font.pixelSize: Theme.fontNormal
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 6
                        model: recipeLines

                        delegate: Rectangle {
                            required property int index
                            required property int inventoryItemId
                            required property string name
                            required property string type
                            required property var qty
                            required property string unit

                            width: ListView.view.width
                            height: 58
                            radius: 8
                            color: Theme.surface
                            border.width: 1
                            border.color: Theme.border

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 10
                                spacing: 8

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: name
                                        color: Theme.text
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        font.pixelSize: Theme.fontMedium
                                    }
                                    Text {
                                        text: catalogLabel(typeCatalog, type)
                                              + qsTr(" · on hand %1").arg(formatQty(stockQuantity(inventoryItemId)))
                                              + (stockQuantity(inventoryItemId) <= stockLow(inventoryItemId) ? qsTr(" · Low") : "")
                                        color: stockQuantity(inventoryItemId) <= stockLow(inventoryItemId) ? "#c45c5c" : Theme.secondaryText
                                        font.pixelSize: Theme.fontNormal
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                TextField {
                                    Layout.preferredWidth: 80
                                    implicitHeight: 34
                                    text: String(qty)
                                    color: Theme.text
                                    leftPadding: 8
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    background: Rectangle {
                                        color: Theme.background
                                        radius: 6
                                        border.color: Theme.border
                                    }
                                    onEditingFinished: {
                                        const value = Number(text)
                                        if (!isNaN(value) && value >= 0) {
                                            recipeLines.setProperty(index, "qty", value)
                                            fulfillmentDirty = true
                                        }
                                    }
                                }

                                Text {
                                    Layout.preferredWidth: 72
                                    text: catalogLabel(unitCatalog, unit)
                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontNormal
                                    elide: Text.ElideRight
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
                                        font.pixelSize: Theme.fontNormal
                                    }
                                    onClicked: removeRecipeLine(index)
                                }
                            }
                        }
                    }

                    Text {
                        visible: recipeLines.count === 0
                        text: qsTr("No lines yet. Pick stock on the right.")
                        color: Theme.secondaryText
                    }
                }
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: Theme.border
            }

            Rectangle {
                Layout.preferredWidth: 360
                Layout.fillHeight: true
                color: Theme.background

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Text {
                        text: qsTr("Add to recipe")
                        font.bold: true
                        color: Theme.text
                    }

                    RowLayout {
                        TextField {
                            id: lineSearchField
                            Layout.fillWidth: true
                            implicitHeight: 36
                            placeholderText: qsTr("Search stock")
                            color: Theme.text
                            leftPadding: 10
                            placeholderTextColor: Theme.secondaryText
                            background: Rectangle {
                                color: Theme.surface
                                radius: 6
                                border.color: Theme.border
                            }
                            onTextChanged: linePickerQuery = text.trim()
                        }
                        TextField {
                            id: newLineQty
                            Layout.preferredWidth: 56
                            implicitHeight: 36
                            text: "1"
                            color: Theme.text
                            leftPadding: 8
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            background: Rectangle {
                                color: Theme.surface
                                radius: 6
                                border.color: Theme.border
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 6
                        model: recipeStockModel

                        delegate: Rectangle {
                            required property int id
                            required property string name
                            required property string type
                            required property string baseUnit

                            visible: matchesLinePicker({ name: name, type: type })
                            width: ListView.view.width
                            height: visible ? 44 : 0
                            radius: 8
                            color: Theme.surface
                            border.width: 1
                            border.color: Theme.border

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text {
                                        text: name
                                        color: Theme.text
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        font.pixelSize: Theme.fontNormal
                                    }
                                    Text {
                                        text: catalogLabel(typeCatalog, type) + " · " + catalogLabel(unitCatalog, baseUnit)
                                        color: Theme.secondaryText
                                        font.pixelSize: Theme.fontNormal
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: addRecipeLine(id)
                            }
                        }
                    }

                    Text {
                        visible: !creatingLineStock
                        text: qsTr("+ New stock item")
                        color: Theme.primary()
                        font.pixelSize: Theme.fontNormal
                        MouseArea {
                            anchors.fill: parent
                            onClicked: creatingLineStock = true
                        }
                    }

                    Rectangle {
                        visible: creatingLineStock
                        Layout.fillWidth: true
                        implicitHeight: inlineCol.implicitHeight + 16
                        radius: 8
                        color: Theme.surface
                        border.color: Theme.border

                        ColumnLayout {
                            id: inlineCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 8
                            spacing: 8

                            Text {
                                text: qsTr("New stock item")
                                font.bold: true
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }
                            TextField {
                                id: inlineStockName
                                Layout.fillWidth: true
                                implicitHeight: 34
                                placeholderText: qsTr("Name")
                                color: Theme.text
                                leftPadding: 8
                                background: Rectangle {
                                    color: Theme.background
                                    radius: 6
                                    border.color: Theme.border
                                }
                            }
                            RowLayout {
                                ComboBox {
                                    id: inlineStockType
                                    Layout.fillWidth: true
                                    implicitHeight: 34
                                    model: typeCatalog
                                    textRole: "label"
                                }
                                ComboBox {
                                    id: inlineStockUnit
                                    Layout.fillWidth: true
                                    implicitHeight: 34
                                    model: unitCatalog
                                    textRole: "label"
                                }
                            }
                            RowLayout {
                                Button {
                                    text: qsTr("Cancel")
                                    implicitHeight: 32
                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus
                                    onClicked: creatingLineStock = false
                                }
                                Button {
                                    Layout.fillWidth: true
                                    text: qsTr("Add to recipe")
                                    implicitHeight: 32
                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus
                                    onClicked: createStockAndAddToRecipe()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
