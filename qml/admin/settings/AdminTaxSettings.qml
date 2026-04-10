import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

ScrollView {
    anchors.fill: parent
    contentWidth: parent.width
    clip: true

    function loadTaxSettings() {
        let data = SettingService.getTaxSettings()
        if (!data || Object.keys(data).length === 0)
            return

        enableTaxSwitch.checked = data.enabled
        taxNameField.text = data.name
        taxRateField.text = (data.rate / 1000000).toFixed(2)
        registrationField.text = data.registration_number
    }

    Component.onCompleted: loadTaxSettings()

    ColumnLayout {
        width: parent.width
        spacing: 30

        Label {
            text: qsTr("Tax Settings")
            font.pixelSize: 26
            font.bold: true
            color: Theme.text
        }

        ColumnLayout {
            spacing: 15

            Text {
                text: qsTr("General")
                font.bold: true
                color: Theme.secondaryText
                font.pointSize: 16
            }

            ColumnLayout {
                spacing: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Enable Tax")
                        color: Theme.text
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
                        text: qsTr("Tax Name")
                        color: Theme.text
                        Layout.preferredWidth: 200
                    }

                    TextField {
                        id: taxNameField
                        Layout.fillWidth: true
                        placeholderText: qsTr("e.g. Sales Tax")
                        color: Theme.text
                        placeholderTextColor: Theme.secondaryText

                        background: Rectangle {
                            color: Theme.surface
                            radius: 6
                        }
                    }
                }

                RowLayout {
                    visible: enableTaxSwitch.checked
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Tax Rate (%)")
                        color: Theme.text
                        Layout.preferredWidth: 200
                    }

                    TextField {
                        id: taxRateField
                        Layout.preferredWidth: 150
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        color: Theme.text

                        background: Rectangle {
                            color: Theme.surface
                            radius: 6
                        }
                    }
                }

                RowLayout {
                    visible: enableTaxSwitch.checked
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Registration Number")
                        color: Theme.text
                        Layout.preferredWidth: 200
                    }

                    TextField {
                        id: registrationField
                        Layout.fillWidth: true
                        placeholderText: qsTr("Optional")
                        color: Theme.text
                        placeholderTextColor: Theme.secondaryText

                        background: Rectangle {
                            color: Theme.surface
                            radius: 6
                        }
                    }
                }
            }
        }
    }

    background: Rectangle {
        color: Theme.background
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 20

        Button {
            text: qsTr("Save")
            width: 60
            leftPadding: 20
            rightPadding: 20
            topPadding: 10
            bottomPadding: 10
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            Layout.leftMargin: 20
            background: Rectangle {
                color: Theme.primary()
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
                if (enableTaxSwitch.checked && taxRateField.text.trim(
                            ) === "") {
                    console.log("Tax rate required")
                    return
                }

                let scaledRate = 0

                if (enableTaxSwitch.checked) {
                    scaledRate = Math.round(parseFloat(
                                                taxRateField.text) * 1000000)
                }

                let taxSettings = {
                    "enabled": enableTaxSwitch.checked,
                    "name": taxNameField.text,
                    "rate": scaledRate,
                    "registration_number": registrationField.text
                }

                if (SettingService.saveTaxSettings(taxSettings)) {
                    console.log("Tax settings saved")
                } else {
                    console.error("Failed to save tax settings")
                }
            }
        }
    }
}
