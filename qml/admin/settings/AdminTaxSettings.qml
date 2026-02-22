import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Xeno.Services 1.0

ScrollView {
    ListModel {
        id: taxRuleModel
    }

    function findIndexByValue(model, value) {
        for (var i = 0; i < model.length; i++) {
            if (model[i].value === value)
                return i
        }
        return 0
    }

    function loadTaxSettings() {
        let data = SettingService.getTaxSettings()

        if (!data || Object.keys(data).length === 0)
            return

        enableTaxSwitch.checked = data.enabled
        registrationField.text = data.registration_number

        priceModeCombo.currentIndex = findIndexByValue(priceModeCombo.model,
                                                       data.price_mode)
        roundingCombo.currentIndex = findIndexByValue(roundingCombo.model,
                                                      data.rounding_strategy)
    }

    function loadTaxRules() {
        taxRuleModel.clear()

        let rules = SettingService.getAllTaxRule()

        for (var i = 0; i < rules.length; i++) {
            taxRuleModel.append(rules[i])
        }
    }

    Component.onCompleted: {
        loadTaxSettings()
        loadTaxRules()
    }

    anchors.fill: parent
    contentWidth: parent.width
    clip: true

    ColumnLayout {
        width: parent.width
        spacing: 30

        Label {
            text: "Tax Settings"
            font.pixelSize: 26
            font.bold: true
            color: "white"
        }

        // =========================
        ColumnLayout {
            spacing: 15

            Text {
                text: "General"
                font.bold: true
                color: "#c9c9c9"
                font.pointSize: 16
            }

            ColumnLayout {
                spacing: 10
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Enable Tax"
                        color: "white"
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: enableTaxSwitch
                        checked: true
                    }
                }

                RowLayout {
                    visible: enableTaxSwitch.checked
                    Layout.fillWidth: true

                    Label {
                        text: "Tax Registration Number"
                        color: "white"
                        Layout.preferredWidth: 220
                    }

                    TextField {
                        id: registrationField
                        Layout.fillWidth: true
                        placeholderText: "Enter registration number"
                        color: "white"
                        placeholderTextColor: "#AAAAAA"

                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10

                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }
                    }
                }
            }
        }

        // =========================
        ColumnLayout {
            spacing: 15

            Text {
                text: "Calculation Settings"
                font.bold: true
                color: "#c9c9c9"
                font.pointSize: 16
            }

            ColumnLayout {
                spacing: 10
                anchors.fill: parent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.topMargin: 30

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Price Mode"
                        color: "white"
                        Layout.preferredWidth: 220
                    }

                    ComboBox {
                        id: priceModeCombo
                        Layout.fillWidth: true
                        model: [{
                                "text": "Tax Exclusive",
                                "value": "exclusive"
                            }, {
                                "text": "Tax Inclusive",
                                "value": "inclusive"
                            }]

                        textRole: "text"
                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.displayText
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Rounding Strategy"
                        color: "white"
                        Layout.preferredWidth: 220
                    }

                    ComboBox {
                        id: roundingCombo
                        Layout.fillWidth: true
                        model: [{
                                "text": "Round Per Line",
                                "value": "per_line"
                            }, {
                                "text": "Round At Order Total",
                                "value": "per_order"
                            }]

                        textRole: "text"
                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.displayText
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }
                    }
                }
            }
        }

        // =========================
        ColumnLayout {
            spacing: 15

            Text {
                text: "Tax Configuration"
                font.bold: true
                color: "#c9c9c9"
                font.pointSize: 16
                anchors.topMargin: 30
            }

            ColumnLayout {
                spacing: 10
                anchors.fill: parent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.topMargin: 30

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: "#1f1f1f"
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8

                        Text {
                            text: "Name"
                            color: "#b0b0b0"
                            font.bold: true
                        }
                        Text {
                            text: "Rate"
                            width: 70
                            color: "#b0b0b0"
                            font.bold: true
                        }
                        Text {
                            text: "Applied To"
                            width: 100
                            color: "#b0b0b0"
                            font.bold: true
                        }
                        Text {
                            text: "Active"
                            width: 70
                            color: "#b0b0b0"
                            font.bold: true
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    height: 250
                    model: taxRuleModel
                    clip: true

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 36
                        color: index % 2 === 0 ? "#262626" : "#2e2e2e"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 20

                            Text {
                                text: name
                                color: "white"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: (rate * 100).toFixed(2) + "%"
                                width: 70
                                color: "white"
                            }

                            Text {
                                text: apply_to
                                width: 100
                                color: "white"
                            }

                            Switch {
                                width: 70
                                checked: active

                                onToggled: {
                                    SettingService.setTaxRuleActiveStatus({
                                                                              "id": id
                                                                          },
                                                                          checked)
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    Label {
                        text: "Tax Name"
                        color: "white"
                    }

                    TextField {
                        id: taxNameField
                        Layout.preferredWidth: 200
                        placeholderText: "e.g. Service Tax"
                        color: "white"
                        placeholderTextColor: "#AAAAAA"

                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }
                    }

                    Label {
                        text: "Tax Rate (%)"
                        color: "white"
                    }

                    TextField {
                        id: taxRateField
                        Layout.preferredWidth: 100
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        color: "white"

                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }
                    }

                    Label {
                        text: "Scope"
                        color: "white"
                    }

                    ComboBox {
                        id: scopeCombo
                        Layout.preferredWidth: 150

                        model: [{
                                "text": "Item-Level",
                                "value": "item"
                            }, {
                                "text": "Order-Level",
                                "value": "order"
                            }]

                        textRole: "text"

                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }

                        contentItem: Text {
                            text: parent.displayText
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }
                    }

                    Label {
                        text: "Apply To"
                        color: "white"
                    }

                    ComboBox {
                        id: applyToCombo
                        Layout.preferredWidth: 180

                        model: [{
                                "text": "All Items",
                                "value": "all"
                            }, {
                                "text": "Only Taxable Items",
                                "value": "taxable_only"
                            }]

                        textRole: "text"

                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }

                        contentItem: Text {
                            text: parent.displayText
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }
                    }

                    Label {
                        text: "Priority"
                        color: "white"
                    }

                    TextField {
                        id: priorityField
                        Layout.preferredWidth: 60
                        text: "1"
                        inputMethodHints: Qt.ImhDigitsOnly
                        color: "white"

                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }
                    }

                    CheckBox {
                        id: activeCheck
                        checked: true

                        contentItem: Text {
                            text: "Active"
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 6
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    spacing: 10

                    Button {
                        text: "Add Tax Rule"
                        width: 120
                        height: 36
                        background: Rectangle {
                            color: "#9a7bff"
                            radius: 4
                        }
                        contentItem: Text {
                            text: qsTr("Add Tax Rule")
                            font.bold: true
                            anchors.centerIn: parent
                            color: "white"
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            if (taxNameField.text.trim() === ""
                                    || taxRateField.text.trim() === "") {
                                console.log("Tax Name and Rate are required")
                                return
                            }

                            let newRule = {
                                "name": taxNameField.text,
                                "rate": parseFloat(taxRateField.text) / 100,
                                "scope"// convert % → fraction
                                : scopeCombo.model[scopeCombo.currentIndex].value,
                                "apply_to": applyToCombo.model[applyToCombo.currentIndex].value,
                                "priority": parseInt(priorityField.text),
                                "active": activeCheck.checked
                            }

                            let ok = SettingService.addTaxRule(newRule)

                            if (ok) {
                                // Refresh list
                                loadTaxRules()

                                // Clear input fields
                                taxNameField.text = ""
                                taxRateField.text = ""
                                scopeCombo.currentIndex = 0
                                applyToCombo.currentIndex = 0
                                priorityField.text = "1"
                                activeCheck.checked = true
                            } else {
                                console.log("Failed to add tax rule")
                            }
                        }
                    }
                }
            }
        }
    }

    background: Rectangle {
        color: "#1E1E1E"
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 20

        Button {
            text: "Save"
            width: 60
            leftPadding: 20
            rightPadding: 20
            topPadding: 10
            bottomPadding: 10
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            Layout.leftMargin: 20
            background: Rectangle {
                color: "#9a7bff"
                radius: 4
            }
            contentItem: Text {
                text: qsTr("Save")
                font.bold: true
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white"
            }
            hoverEnabled: false
            focusPolicy: Qt.NoFocus
            onClicked: {
                let taxSettings = {
                    "enabled": enableTaxSwitch.checked,
                    "registration_number": registrationField.text,
                    "price_mode": priceModeCombo.model[priceModeCombo.currentIndex].value,
                    "rounding_strategy": roundingCombo.model[roundingCombo.currentIndex].value
                }

                if (SettingService.saveTaxSettings(taxSettings)) {
                    console.log("General tax settings saved successfully")
                } else {
                    console.error("Failed to save general tax settings")
                }
            }
        }

        // Text {
        //     text: root.errorMessage
        //     color: "red"
        //     font.bold: true
        //     wrapMode: Text.WordWrap
        //     Layout.fillWidth: true
        // }
    }
}
