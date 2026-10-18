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
        { key: "g", label: qsTr("Gram"), category: "weight" },
        { key: "kg", label: qsTr("Kilogram"), category: "weight" },
        { key: "oz", label: qsTr("Ounce"), category: "weight" },
        { key: "lb", label: qsTr("Pound"), category: "weight" },
        { key: "ml", label: qsTr("Milliliter"), category: "volume" },
        { key: "L", label: qsTr("Liter"), category: "volume" },
        { key: "fl_oz", label: qsTr("Fluid ounce"), category: "volume" },
        { key: "gal", label: qsTr("Gallon"), category: "volume" },
        { key: "qt", label: qsTr("Quart"), category: "volume" },
        { key: "pt", label: qsTr("Pint"), category: "volume" },
        { key: "cup", label: qsTr("Cup"), category: "volume" },
        { key: "unit", label: qsTr("Unit"), category: "count" },
        { key: "dozen", label: qsTr("Dozen"), category: "count" },
        { key: "pack", label: qsTr("Pack"), category: "count" },
        { key: "box", label: qsTr("Box"), category: "count" },
        { key: "bag", label: qsTr("Bag"), category: "count" },
        { key: "bottle", label: qsTr("Bottle"), category: "count" },
        { key: "can", label: qsTr("Can"), category: "count" },
        { key: "carton", label: qsTr("Carton"), category: "count" },
        { key: "case", label: qsTr("Case"), category: "count" }
    ]
    readonly property var effectCatalog: [
        { key: "add", label: qsTr("Use extra") },
        { key: "remove", label: qsTr("Leave out") },
        { key: "replace", label: qsTr("Replace") }
    ]

    property string fulfillmentMode: "none"
    property bool fulfillmentDirty: false
    property string linePickerQuery: ""
    property bool creatingLineStock: false
    property string statusMessage: ""
    property int ruleTargetModifierId: -1
    property string ruleEffect: "add"
    property int replaceFromId: -1
    property int rulesRevision: 0
    property int nextRuleKey: 1
    property var modifierTemplates: null
    property int templateRevision: 0

    ListModel { id: stockModel }
    ListModel { id: recipeStockModel }
    ListModel { id: recipeLines }
    ListModel { id: modifierRules }

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

    function unitCategory(key) {
        for (var i = 0; i < unitCatalog.length; ++i) {
            if (unitCatalog[i].key === key)
                return unitCatalog[i].category
        }
        return "count"
    }

    function unitsForCategory(category) {
        var out = []
        for (var i = 0; i < unitCatalog.length; ++i) {
            if (unitCatalog[i].category === category)
                out.push(unitCatalog[i])
        }
        return out
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
        return !row || row.modifierId === undefined || row.modifierId === null || row.modifierId === "" || Number(row.modifierId) <= 0
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

    function modifierComponents(rows) {
        var out = []
        if (!rows)
            return out
        for (var i = 0; i < rows.length; ++i) {
            if (!isDefaultComponent(rows[i]))
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

    function ruleLabel(row) {
        if (!row)
            return ""
        if (row.effect === "replace") {
            return qsTr("Replace %1 %2 %3 with %4 %5 %6")
                    .arg(formatQty(row.qty))
                    .arg(catalogLabel(unitCatalog, row.unit))
                    .arg(row.name || "")
                    .arg(formatQty(row.replacementQty))
                    .arg(catalogLabel(unitCatalog, row.replacementUnit))
                    .arg(row.replacementName || "")
        }
        const verb = row.effect === "remove" ? qsTr("Leave out") : qsTr("Use extra")
        return verb + " " + formatQty(row.qty) + " " + catalogLabel(unitCatalog, row.unit) + " · " + (row.name || "")
    }

    function appendModifierRuleRow(rule, replacement) {
        const meta = modifierMeta(rule.modifierId)
        modifierRules.append({
            ruleKey: nextRuleKey++,
            componentId: rule.id || -1,
            modifierId: Number(rule.modifierId),
            modifierName: meta.name,
            groupName: meta.groupName,
            inventoryItemId: rule.inventoryItemId,
            name: rule.inventoryItemName || stockName(rule.inventoryItemId),
            type: rule.type || stockType(rule.inventoryItemId),
            qty: Number(rule.quantity) || 0,
            unit: rule.unit || stockUnit(rule.inventoryItemId),
            effect: replacement ? "replace" : (rule.effect || "add"),
            replacementInventoryItemId: replacement ? replacement.inventoryItemId : -1,
            replacementName: replacement ? (replacement.inventoryItemName || stockName(replacement.inventoryItemId)) : "",
            replacementQty: replacement ? (Number(replacement.quantity) || 0) : 0,
            replacementUnit: replacement ? (replacement.unit || stockUnit(replacement.inventoryItemId)) : ""
        })
    }

    function baseQty(inventoryItemId) {
        var total = 0
        for (var i = 0; i < recipeLines.count; ++i) {
            if (recipeLines.get(i).inventoryItemId === inventoryItemId)
                total += Number(recipeLines.get(i).qty) || 0
        }
        return total
    }

    function inferMode(rows) {
        const defaults = defaultComponents(rows)
        const conditional = modifierComponents(rows)
        if (defaults.length === 0 && conditional.length === 0)
            return "none"
        return "recipe"
    }

    function loadComponents(id) {
        if (!InventoryService || typeof InventoryService.getRecipeComponents !== "function" || id < 0)
            return []
        return InventoryService.getRecipeComponents(menuOwnerType, id) || []
    }

    function reloadModifiers() {
        if (menuItemId < 0 || typeof ModifiersService === "undefined")
            return
        if (ModifiersService.reloadForMenu)
            ModifiersService.reloadForMenu(menuItemId)
        else if (ModifiersService.menuModifierModel && ModifiersService.menuModifierModel.loadGroupsForMenu)
            ModifiersService.menuModifierModel.loadGroupsForMenu(menuItemId)
    }

    function modifierMeta(modifierId) {
        const model = (typeof ModifiersService !== "undefined") ? ModifiersService.menuModifierModel : null
        if (!model)
            return { name: qsTr("Option"), groupName: "" }
        const nameRole = Qt.UserRole + 2
        const modifiersRole = Qt.UserRole + 8
        for (var g = 0; g < model.rowCount(); ++g) {
            const groupIndex = model.index(g, 0)
            const groupName = model.data(groupIndex, nameRole) || ""
            const options = model.data(groupIndex, modifiersRole) || []
            for (var m = 0; m < options.length; ++m) {
                if (Number(options[m].id) === Number(modifierId))
                    return { name: options[m].name || qsTr("Option"), groupName: groupName }
            }
        }
        return { name: qsTr("Option"), groupName: "" }
    }

    function reloadStock() {
        stockModel.clear()
        recipeStockModel.clear()
        if (!InventoryService || typeof InventoryService.getItems !== "function")
            return
        const items = InventoryService.getItems()
        for (var i = 0; i < items.length; ++i) {
            const it = items[i]
            if (it.deletedAt)
                continue
            stockModel.append(it)
            if (it.type === "ingredient" || it.type === "prep" || it.type === "packaging" || it.type === "finishedProduct")
                recipeStockModel.append(it)
        }
    }

    function loadFulfillment() {
        recipeLines.clear()
        modifierRules.clear()
        nextRuleKey = 1
        creatingLineStock = false
        linePickerQuery = ""
        ruleTargetModifierId = -1
        ruleEffect = "add"
        replaceFromId = -1
        statusMessage = ""
        modifierTemplates = null
        if (lineSearchField)
            lineSearchField.text = ""
        if (newLineQty)
            newLineQty.text = "1"

        const rows = loadComponents(menuItemId)
        fulfillmentMode = inferMode(rows)
        const defaults = defaultComponents(rows)

        if (fulfillmentMode === "recipe") {
            for (var i = 0; i < defaults.length; ++i) {
                const line = defaults[i]
                recipeLines.append({
                    componentId: line.id || -1,
                    inventoryItemId: line.inventoryItemId,
                    name: line.inventoryItemName || stockName(line.inventoryItemId),
                    type: line.type || stockType(line.inventoryItemId),
                    qty: Number(line.quantity) || 0,
                    unit: line.unit || stockUnit(line.inventoryItemId)
                })
            }
            const conditional = modifierComponents(rows)
            for (var j = 0; j < conditional.length; ++j) {
                const rule = conditional[j]
                const next = j + 1 < conditional.length ? conditional[j + 1] : null
                if ((rule.effect || "") === "replace"
                        && next
                        && (next.effect || "") === "replace"
                        && Number(next.modifierId) === Number(rule.modifierId)) {
                    appendModifierRuleRow(rule, next)
                    j++
                    continue
                }
                appendModifierRuleRow(rule, null)
            }
        }
        rulesRevision++
        fulfillmentDirty = false
    }

    function setMode(mode) {
        if (fulfillmentMode === mode)
            return
        fulfillmentMode = mode
        fulfillmentDirty = true
        statusMessage = ""
        if (mode !== "recipe") {
            creatingLineStock = false
            ruleTargetModifierId = -1
        }
    }

    function setRuleTarget(modifierId) {
        ruleTargetModifierId = modifierId
        replaceFromId = -1
        if (modifierId === -1) {
            ruleEffect = "add"
            modifierTemplates = null
            return
        }
        if (ruleEffect !== "add" && ruleEffect !== "remove" && ruleEffect !== "replace")
            ruleEffect = "add"

        // load templates only when targeting a modifier that has no rules yet
        if (rulesForModifier(modifierId).length === 0)
            loadModifierTemplates(modifierId)
        else
            modifierTemplates = null
    }

    function loadModifierTemplates(modifierId) {
        modifierTemplates = null
        if (!InventoryService || typeof InventoryService.getModifierRecipeTemplates !== "function" || modifierId <= 0)
            return
        const result = InventoryService.getModifierRecipeTemplates(modifierId)
        if (!result || !result.default)
            return
        modifierTemplates = result
        templateRevision++
        // auto apply default if present
        applyTemplate(result.default)
    }

    function applyTemplate(template) {
        if (!template || !template.components || ruleTargetModifierId <= 0)
            return
        // remove any existing rules for this modifier first
        for (var i = modifierRules.count - 1; i >= 0; --i) {
            if (Number(modifierRules.get(i).modifierId) === Number(ruleTargetModifierId))
                modifierRules.remove(i)
        }
        const components = template.components
        for (var j = 0; j < components.length; ++j) {
            const rule = components[j]
            // force the rule onto the currently targeted modifier
            const adjusted = Object.assign({}, rule)
            adjusted.modifierId = ruleTargetModifierId
            const nextRaw = j + 1 < components.length ? components[j + 1] : null
            const next = nextRaw ? Object.assign({}, nextRaw) : null
            if (next)
                next.modifierId = ruleTargetModifierId
            if ((adjusted.effect || "") === "replace"
                    && next
                    && (next.effect || "") === "replace") {
                appendModifierRuleRow(adjusted, next)
                j++
                continue
            }
            appendModifierRuleRow(adjusted, null)
        }
        fulfillmentDirty = true
        rulesRevision++
        statusMessage = template.ownerName
                         ? qsTr("Using rules from %1").arg(template.ownerName)
                         : qsTr("Using existing rules")
    }

    function templateLabel(template) {
        if (!template)
            return ""
        return template.ownerName || qsTr("Template from item %1").arg(template.ownerId || "")
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

    function addModifierRule(inventoryItemId) {
        if (ruleTargetModifierId <= 0 || !inventoryItemId || inventoryItemId === -1)
            return
        const typed = Number(newLineQty ? newLineQty.text : 1)
        const addQty = (!isNaN(typed) && typed > 0) ? typed : 1
        if (ruleEffect === "replace") {
            if (replaceFromId <= 0) {
                if (baseQty(inventoryItemId) <= 0) {
                    statusMessage = qsTr("Pick a base recipe line to replace.")
                    return
                }
                replaceFromId = inventoryItemId
                statusMessage = qsTr("Pick the stock item to use instead.")
                rulesRevision++
                return
            }
            if (Number(inventoryItemId) === Number(replaceFromId)) {
                statusMessage = qsTr("Pick a different item to use instead.")
                return
            }
            const from = stockById(replaceFromId)
            const to = stockById(inventoryItemId)
            if (!from || !to)
                return
            const fromQty = Math.min(addQty, baseQty(replaceFromId))
            const meta = modifierMeta(ruleTargetModifierId)
            modifierRules.append({
                ruleKey: nextRuleKey++,
                componentId: -1,
                modifierId: ruleTargetModifierId,
                modifierName: meta.name,
                groupName: meta.groupName,
                inventoryItemId: from.id,
                name: from.name,
                type: from.type,
                qty: fromQty,
                unit: from.baseUnit,
                effect: "replace",
                replacementInventoryItemId: to.id,
                replacementName: to.name,
                replacementQty: addQty,
                replacementUnit: to.baseUnit
            })
            replaceFromId = -1
            fulfillmentDirty = true
            rulesRevision++
            statusMessage = ""
            if (newLineQty)
                newLineQty.text = "1"
            return
        }
        if (ruleEffect === "remove" && baseQty(inventoryItemId) <= 0) {
            statusMessage = qsTr("Leave out only applies to a base recipe line.")
            return
        }
        for (var i = 0; i < modifierRules.count; ++i) {
            const existing = modifierRules.get(i)
            if (existing.modifierId === ruleTargetModifierId
                    && existing.inventoryItemId === inventoryItemId
                    && existing.effect === ruleEffect) {
                modifierRules.setProperty(i, "qty", (Number(existing.qty) || 0) + addQty)
                fulfillmentDirty = true
                rulesRevision++
                return
            }
        }
        const it = stockById(inventoryItemId)
        if (!it)
            return
        const meta = modifierMeta(ruleTargetModifierId)
        modifierRules.append({
            ruleKey: nextRuleKey++,
            componentId: -1,
            modifierId: ruleTargetModifierId,
            modifierName: meta.name,
            groupName: meta.groupName,
            inventoryItemId: it.id,
            name: it.name,
            type: it.type,
            qty: addQty,
            unit: it.baseUnit,
            effect: ruleEffect,
            replacementInventoryItemId: -1,
            replacementName: "",
            replacementQty: 0,
            replacementUnit: ""
        })
        fulfillmentDirty = true
        rulesRevision++
        statusMessage = ""
        if (newLineQty)
            newLineQty.text = "1"
    }

    function addFromPicker(inventoryItemId) {
        if (ruleTargetModifierId <= 0)
            addRecipeLine(inventoryItemId)
        else
            addModifierRule(inventoryItemId)
    }

    function removeRecipeLine(index) {
        if (index < 0 || index >= recipeLines.count)
            return
        recipeLines.remove(index)
        fulfillmentDirty = true
    }

    function removeModifierRule(ruleKey) {
        for (var i = 0; i < modifierRules.count; ++i) {
            if (modifierRules.get(i).ruleKey === ruleKey) {
                modifierRules.remove(i)
                fulfillmentDirty = true
                rulesRevision++
                return
            }
        }
    }

    function updateModifierRuleProperty(ruleKey, property, value) {
        for (var i = 0; i < modifierRules.count; ++i) {
            if (modifierRules.get(i).ruleKey === ruleKey) {
                modifierRules.setProperty(i, property, value)
                fulfillmentDirty = true
                rulesRevision++
                return
            }
        }
    }

    function rulesForModifier(modifierId) {
        rulesRevision
        var out = []
        for (var i = 0; i < modifierRules.count; ++i) {
            const row = modifierRules.get(i)
            if (Number(row.modifierId) === Number(modifierId))
                out.push(row)
        }
        return out
    }

    function matchesLinePicker(item) {
        if (ruleTargetModifierId > 0 && ruleEffect === "remove" && baseQty(item.id) <= 0)
            return false
        if (ruleTargetModifierId > 0 && ruleEffect === "replace" && replaceFromId <= 0 && baseQty(item.id) <= 0)
            return false
        if (ruleTargetModifierId > 0 && ruleEffect === "replace" && replaceFromId > 0 && Number(item.id) === Number(replaceFromId))
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
                unit: lines[j].unit,
                effect: "add",
                sortOrder: j
            })
            if (newId === -1 || newId === undefined || newId === false)
                return false
        }
        return true
    }

    function replaceModifierComponents(lines) {
        const existing = modifierComponents(loadComponents(menuItemId))
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
                unit: lines[j].unit,
                modifierId: lines[j].modifierId,
                effect: lines[j].effect,
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
        var rules = []
        if (fulfillmentMode === "recipe") {
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
                lines.push({
                    inventoryItemId: line.inventoryItemId,
                    quantity: qty,
                    unit: line.unit
                })
            }
            for (var r = 0; r < modifierRules.count; ++r) {
                const rule = modifierRules.get(r)
                const qty = Number(rule.qty)
                if (isNaN(qty) || qty <= 0) {
                    statusMessage = qsTr("Every modifier rule needs a quantity.")
                    return false
                }
                if (rule.effect === "remove" && qty > baseQty(rule.inventoryItemId)) {
                    statusMessage = qsTr("Leave out cannot exceed the base quantity.")
                    return false
                }
                if (rule.effect === "replace") {
                    const replacementQty = Number(rule.replacementQty)
                    if (!rule.replacementInventoryItemId || rule.replacementInventoryItemId === -1 || isNaN(replacementQty) || replacementQty <= 0) {
                        statusMessage = qsTr("Replace needs the item to use instead.")
                        return false
                    }
                    if (qty > baseQty(rule.inventoryItemId)) {
                        statusMessage = qsTr("Replace cannot leave out more than the base quantity.")
                        return false
                    }
                    rules.push({
                        inventoryItemId: rule.inventoryItemId,
                        quantity: qty,
                        unit: rule.unit,
                        modifierId: rule.modifierId,
                        effect: "replace"
                    })
                    rules.push({
                        inventoryItemId: rule.replacementInventoryItemId,
                        quantity: replacementQty,
                        unit: rule.replacementUnit,
                        modifierId: rule.modifierId,
                        effect: "replace"
                    })
                    continue
                }
                rules.push({
                    inventoryItemId: rule.inventoryItemId,
                    quantity: qty,
                    unit: rule.unit,
                    modifierId: rule.modifierId,
                    effect: rule.effect || "add"
                })
            }
        }

        if (!replaceDefaultComponents(lines)) {
            statusMessage = qsTr("Could not save stock use.")
            return false
        }
        if (!replaceModifierComponents(rules)) {
            statusMessage = qsTr("Could not save modifier stock rules.")
            return false
        }

        fulfillmentDirty = false
        statusMessage = qsTr("Saved")
        reloadStock()
        loadFulfillment()
        root.saved()
        return true
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
        addFromPicker(newId)
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
        reloadModifiers()
        loadFulfillment()
    }

    onMenuItemIdChanged: hydrate()
    Component.onCompleted: hydrate()

    Connections {
        target: (typeof ModifiersService !== "undefined") ? ModifiersService : null
        function onMenuGroupsChanged(menuId) {
            if (menuId === root.menuItemId)
                root.rulesRevision++
        }
    }

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

        RowLayout {
            visible: fulfillmentMode === "recipe"
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.background

                Flickable {
                    id: recipeFlick
                    anchors.fill: parent
                    anchors.margins: 16
                    contentWidth: width
                    contentHeight: recipeCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: recipeCol
                        width: recipeFlick.width
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

                        Repeater {
                            model: recipeLines

                            delegate: Rectangle {
                                required property int index
                                required property int inventoryItemId
                                required property string name
                                required property string type
                                required property var qty
                                required property string unit

                                Layout.fillWidth: true
                                implicitHeight: 58
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

                                    ComboBox {
                                        Layout.preferredWidth: 110
                                        implicitHeight: 34
                                        model: unitsForCategory(unitCategory(stockUnit(inventoryItemId)))
                                        textRole: "label"
                                        currentIndex: {
                                            const units = unitsForCategory(unitCategory(stockUnit(inventoryItemId)))
                                            for (var i = 0; i < units.length; ++i) {
                                                if (units[i].key === unit)
                                                    return i
                                            }
                                            return 0
                                        }
                                        onActivated: function(index) {
                                            const units = unitsForCategory(unitCategory(stockUnit(inventoryItemId)))
                                            recipeLines.setProperty(index, "unit", units[index].key)
                                            fulfillmentDirty = true
                                        }
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

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            height: 1
                            color: Theme.border
                        }

                        Text {
                            text: qsTr("Modifiers")
                            font.bold: true
                            color: Theme.text
                            font.pixelSize: Theme.fontMedium
                        }

                        Repeater {
                            model: (typeof ModifiersService !== "undefined") ? ModifiersService.menuModifierModel : null

                            delegate: ColumnLayout {
                                id: groupBlock
                                required property int id
                                required property string name
                                required property var modifiers
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: name
                                    color: Theme.secondaryText
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                }

                                Repeater {
                                    model: modifiers

                                    delegate: Rectangle {
                                        id: optionCard
                                        required property var modelData
                                        Layout.fillWidth: true
                                        implicitHeight: optionCol.implicitHeight + 16
                                        radius: 8
                                        color: Theme.surface
                                        border.width: 1
                                        border.color: ruleTargetModifierId === Number(modelData.id) ? Theme.primary() : Theme.border

                                        ColumnLayout {
                                            id: optionCol
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            anchors.margins: 8
                                            spacing: 6

                                            RowLayout {
                                                Layout.fillWidth: true
                                                Text {
                                                    text: modelData.name || ""
                                                    color: Theme.text
                                                    font.bold: true
                                                    font.pixelSize: Theme.fontNormal
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            Repeater {
                                                model: rulesForModifier(modelData.id)

                                                delegate: RowLayout {
                                                    required property var modelData
                                                    Layout.fillWidth: true
                                                    spacing: 6

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: ruleLabel(modelData)
                                                        color: Theme.text
                                                        font.pixelSize: Theme.fontNormal
                                                        elide: Text.ElideRight
                                                    }

                                                    TextField {
                                                        text: modelData.qty !== undefined ? String(modelData.qty) : ""
                                                        Layout.preferredWidth: 56
                                                        horizontalAlignment: TextInput.AlignHCenter
                                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                                        onEditingFinished: {
                                                            const qty = parseFloat(text)
                                                            if (isNaN(qty) || qty < 0)
                                                                return
                                                            updateModifierRuleProperty(modelData.ruleKey, "qty", qty)
                                                        }
                                                    }

                                                    ComboBox {
                                                        Layout.preferredWidth: 110
                                                        implicitHeight: 34
                                                        model: unitsForCategory(unitCategory(stockUnit(modelData.inventoryItemId)))
                                                        textRole: "label"
                                                        currentIndex: {
                                                            const units = unitsForCategory(unitCategory(stockUnit(modelData.inventoryItemId)))
                                                            for (var i = 0; i < units.length; ++i) {
                                                                if (units[i].key === modelData.unit)
                                                                    return i
                                                            }
                                                            return 0
                                                        }
                                                        onActivated: function(index) {
                                                            const units = unitsForCategory(unitCategory(stockUnit(modelData.inventoryItemId)))
                                                            if (index >= 0 && index < units.length)
                                                                updateModifierRuleProperty(modelData.ruleKey, "unit", units[index].key)
                                                        }
                                                    }

                                                    Button {
                                                        hoverEnabled: false
                                                        focusPolicy: Qt.NoFocus
                                                        leftPadding: 8
                                                        rightPadding: 8
                                                        topPadding: 2
                                                        bottomPadding: 2
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
                                                        onClicked: removeModifierRule(modelData.ruleKey)
                                                    }
                                                }
                                            }

                                            Button {
                                                hoverEnabled: false
                                                focusPolicy: Qt.NoFocus
                                                visible: ruleTargetModifierId !== Number(optionCard.modelData.id)
                                                leftPadding: 8
                                                rightPadding: 8
                                                topPadding: 4
                                                bottomPadding: 4
                                                background: Rectangle {
                                                    color: ruleTargetModifierId === Number(optionCard.modelData.id) ? Theme.primary() : Theme.background
                                                    radius: 4
                                                    border.color: Theme.border
                                                    border.width: ruleTargetModifierId === Number(optionCard.modelData.id) ? 0 : 1
                                                }
                                                contentItem: Text {
                                                    text: qsTr("Add stock rule")
                                                    color: ruleTargetModifierId === Number(optionCard.modelData.id) ? "white" : Theme.text
                                                    font.pixelSize: Theme.fontSmall
                                                }
                                                onClicked: setRuleTarget(Number(optionCard.modelData.id))
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            visible: typeof ModifiersService === "undefined"
                                     || !ModifiersService.menuModifierModel
                                     || ModifiersService.menuModifierModel.rowCount() === 0
                            text: qsTr("No modifier groups attached to this item.")
                            color: Theme.secondaryText
                            font.pixelSize: Theme.fontNormal
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
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
                        text: ruleTargetModifierId <= 0
                              ? qsTr("Add to recipe")
                              : qsTr("Add to %1").arg(modifierMeta(ruleTargetModifierId).name)
                        font.bold: true
                        color: Theme.text
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        visible: ruleTargetModifierId > 0
                        spacing: 6

                        Repeater {
                            model: effectCatalog
                            delegate: Rectangle {
                                required property var modelData
                                implicitHeight: 28
                                implicitWidth: effectLabel.implicitWidth + 16
                                radius: 6
                                color: ruleEffect === modelData.key ? Theme.primary() : Theme.surface
                                border.width: ruleEffect === modelData.key ? 0 : 1
                                border.color: Theme.border

                                Text {
                                    id: effectLabel
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: ruleEffect === modelData.key ? "white" : Theme.text
                                    font.pixelSize: Theme.fontSmall
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        ruleEffect = modelData.key
                                        replaceFromId = -1
                                        statusMessage = ""
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: qsTr("Base")
                            color: Theme.primary()
                            font.pixelSize: Theme.fontSmall
                            MouseArea {
                                anchors.fill: parent
                                onClicked: setRuleTarget(-1)
                            }
                        }
                    }

                    // template switcher (shown when templates exist for the targeted modifier)
                    RowLayout {
                        visible: ruleTargetModifierId > 0 && modifierTemplates && (modifierTemplates.default || (modifierTemplates.others && modifierTemplates.others.length > 0))
                        spacing: 6
                        Layout.fillWidth: true

                        Text {
                            text: qsTr("Template:")
                            color: Theme.secondaryText
                            font.pixelSize: Theme.fontSmall
                        }

                        ComboBox {
                            id: templateCombo
                            Layout.fillWidth: true
                            implicitHeight: 28
                            textRole: "label"
                            model: {
                                templateRevision
                                var items = []
                                if (modifierTemplates && modifierTemplates.default)
                                    items.push({ label: templateLabel(modifierTemplates.default), template: modifierTemplates.default })
                                if (modifierTemplates && modifierTemplates.others) {
                                    for (var i = 0; i < modifierTemplates.others.length; ++i)
                                        items.push({ label: templateLabel(modifierTemplates.others[i]), template: modifierTemplates.others[i] })
                                }
                                return items
                            }
                            onActivated: function(index) {
                                if (index >= 0 && index < model.length)
                                    applyTemplate(model[index].template)
                            }
                        }
                    }

                    Text {
                        visible: ruleTargetModifierId > 0 && ruleEffect === "replace"
                        text: replaceFromId <= 0
                              ? qsTr("Pick the base item to replace.")
                              : qsTr("Replacing %1. Pick the item to use instead.").arg(stockName(replaceFromId))
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontSmall
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
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

                            visible: matchesLinePicker({ id: id, name: name, type: type })
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
                                onClicked: addFromPicker(id)
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
