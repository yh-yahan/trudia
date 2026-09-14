import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Dialog {
    id: root

    property int menuItemId: -1
    property string itemName: ""
    property real basePrice: 0
    property string portion: ""
    property string currencySymbol: SettingService.currencySymbol()

    signal confirmed(var payload)

    modal: true
    title: itemName
    anchors.centerIn: Overlay.overlay
    width: Math.min(520, parent ? parent.width - 24 : 520)
    height: Math.min(640, parent ? parent.height - 24 : 640)
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: Theme.background
        radius: 12
        border.color: Theme.border
    }

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
        return (number > 0 ? "+" : "-") + currencySymbol + Math.abs(number).toFixed(2)
    }

    function openFor(id, name, price, itemPortion) {
        menuItemId = id
        itemName = name
        basePrice = Number(price) || 0
        portion = itemPortion || ""
        selectionModel.clear()
        groupMetaModel.clear()
        errorLabel.text = ""

        ModifiersService.currentMenuId = id
        if (ModifiersService.reloadForMenu)
            ModifiersService.reloadForMenu(id)
        else if (ModifiersService.menuModifierModel)
            ModifiersService.menuModifierModel.loadGroupsForMenu(id)

        if (!ModifiersService.menuModifierModel
                || ModifiersService.menuModifierModel.rowCount() === 0) {
            confirmed(buildPayload())
            return
        }

        open()
    }

    function selectedModifiers() {
        const result = []
        for (let i = 0; i < selectionModel.count; ++i) {
            const raw = String(selectionModel.get(i).payload || "")
            if (!raw.length)
                continue
            const parts = raw.split("||")
            for (let j = 0; j < parts.length; ++j) {
                if (!parts[j].length)
                    continue
                const fields = parts[j].split("::")
                result.push({
                                "id": Number(fields[0]),
                                "groupId": Number(fields[1]),
                                "name": fields[2],
                                "priceDelta": Number(fields[3])
                            })
            }
        }
        return result
    }

    function extraPrice() {
        let extra = 0
        const mods = selectedModifiers()
        for (let i = 0; i < mods.length; ++i)
            extra += Number(mods[i].priceDelta) || 0
        return extra
    }

    function modifiersForGroup(groupId) {
        return selectedModifiers().filter(function (m) { return m.groupId === groupId })
    }

    function setGroupSelection(groupId, modifiers) {
        const ids = []
        const payload = []
        for (let i = 0; i < modifiers.length; ++i) {
            ids.push(String(modifiers[i].id))
            payload.push(modifiers[i].id + "::" + groupId + "::"
                         + modifiers[i].name + "::" + modifiers[i].priceDelta)
        }

        for (let i = 0; i < selectionModel.count; ++i) {
            if (selectionModel.get(i).groupId === groupId) {
                selectionModel.set(i, {
                                       "groupId": groupId,
                                       "ids": ids.join(","),
                                       "payload": payload.join("||")
                                   })
                return
            }
        }

        selectionModel.append({
                                  "groupId": groupId,
                                  "ids": ids.join(","),
                                  "payload": payload.join("||")
                              })
    }

    function findGroupMeta(groupId) {
        for (let i = 0; i < groupMetaModel.count; ++i) {
            if (groupMetaModel.get(i).groupId === groupId)
                return groupMetaModel.get(i)
        }
        return null
    }

    function toggleModifier(groupId, modifier, forceOn) {
        const current = modifiersForGroup(groupId)
        const exists = current.some(function (m) { return m.id === modifier.id })
        let next = current.slice()
        const meta = findGroupMeta(groupId)
        const isSingle = meta && meta.selectionType === "single"

        if (isSingle) {
            next = (exists && !forceOn) ? [] : [modifier]
        } else if (exists && !forceOn) {
            next = current.filter(function (m) { return m.id !== modifier.id })
        } else if (!exists) {
            if (meta && meta.maxSelect >= 0 && current.length >= meta.maxSelect)
                return
            next.push(modifier)
        }

        setGroupSelection(groupId, next)
    }

    function isSelected(groupId, modifierId) {
        return modifiersForGroup(groupId).some(function (m) { return m.id === modifierId })
    }

    function validationError() {
        for (let i = 0; i < groupMetaModel.count; ++i) {
            const group = groupMetaModel.get(i)
            const count = modifiersForGroup(group.groupId).length
            if (group.isRequired && count < Math.max(group.minSelect, 1))
                return qsTr('Choose an option for "%1".').arg(group.name)
            if (count < group.minSelect)
                return qsTr('"%1" needs at least %2 selected.').arg(group.name).arg(group.minSelect)
            if (group.maxSelect >= 0 && count > group.maxSelect)
                return qsTr('"%1" allows at most %2 selected.').arg(group.name).arg(group.maxSelect)
        }
        return ""
    }

    function modifierKey() {
        const ids = selectedModifiers().map(function (m) { return m.id })
        ids.sort(function (a, b) { return a - b })
        return ids.join(",")
    }

    function buildPayload() {
        const mods = selectedModifiers()
        return {
            "menuItemId": menuItemId,
            "name": itemName,
            "portion": portion,
            "basePrice": basePrice,
            "price": basePrice + extraPrice(),
            "modifiers": mods,
            "modifierKey": modifierKey(),
            "modifierLabel": mods.map(function (m) { return m.name }).join(", ")
        }
    }

    ListModel { id: selectionModel }
    ListModel { id: groupMetaModel }

    contentItem: ColumnLayout {
        spacing: 10

        Text {
            text: portion.length ? portion + " · " + root.formatMoney(root.basePrice)
                                 : root.formatMoney(root.basePrice)
            color: Theme.secondaryText
            font.pixelSize: Theme.fontNormal
        }

        ListView {
            id: groupList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10
            model: ModifiersService.menuModifierModel

            delegate: Rectangle {
                id: groupCard

                required property int id
                required property string name
                required property string selectionType
                required property int minSelect
                required property var maxSelect
                required property bool isRequired
                required property var modifiers

                width: groupList.width
                implicitHeight: groupCol.implicitHeight + 20
                radius: 10
                color: Theme.surface
                border.color: Theme.border
                border.width: 1

                Component.onCompleted: {
                    groupMetaModel.append({
                                             "groupId": id,
                                             "name": name,
                                             "selectionType": selectionType,
                                             "minSelect": minSelect,
                                             "maxSelect": (maxSelect === undefined || maxSelect === null || maxSelect === "")
                                                          ? -1 : Number(maxSelect),
                                             "isRequired": isRequired
                                         })

                    for (let i = 0; i < modifiers.length; ++i) {
                        if (modifiers[i].isDefault)
                            root.toggleModifier(id, modifiers[i], true)
                    }
                }

                ColumnLayout {
                    id: groupCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
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

                        Button {
                            required property var modelData
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus
                            Layout.fillWidth: true
                            implicitHeight: 40

                            property bool chosen: {
                                selectionModel.count
                                return root.isSelected(groupCard.id, modelData.id)
                            }

                            background: Rectangle {
                                radius: 8
                                color: parent.chosen ? Theme.primary() : Theme.background
                                border.color: parent.chosen ? Theme.primary() : Theme.border
                            }

                            contentItem: RowLayout {
                                Text {
                                    text: modelData.name + (modelData.isDefault ? qsTr(" (default)") : "")
                                    color: parent.parent.chosen ? "white" : Theme.text
                                    font.pixelSize: Theme.fontNormal
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: root.formatDelta(modelData.priceDelta)
                                    color: parent.parent.chosen ? "white" : Theme.secondaryText
                                    font.pixelSize: Theme.fontNormal
                                }
                            }

                            onClicked: root.toggleModifier(groupCard.id, modelData, false)
                        }
                    }
                }
            }
        }

        Text {
            id: errorLabel
            visible: text.length > 0
            color: "#c62828"
            font.pixelSize: Theme.fontSmall
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            text: qsTr("Line total: %1").arg(root.formatMoney(root.basePrice + root.extraPrice()))
            color: Theme.text
            font.bold: true
            font.pixelSize: Theme.fontNormal
        }

        RowLayout {
            spacing: 8
            Layout.fillWidth: true

            Button {
                Layout.fillWidth: true
                implicitHeight: 42
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                background: Rectangle {
                    color: Theme.surface
                    radius: 8
                    border.color: Theme.border
                }
                contentItem: Text {
                    text: qsTr("Cancel")
                    color: Theme.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontNormal
                }
                onClicked: root.reject()
            }

            Button {
                Layout.fillWidth: true
                implicitHeight: 42
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                background: Rectangle {
                    color: Theme.primary()
                    radius: 8
                }
                contentItem: Text {
                    text: qsTr("Add to order")
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontNormal
                }
                onClicked: {
                    const error = root.validationError()
                    errorLabel.text = error
                    if (error.length)
                        return
                    root.confirmed(root.buildPayload())
                    root.accept()
                }
            }
        }
    }
}
