import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

ScrollView {
    id: root
    anchors.fill: parent
    contentWidth: parent.width
    clip: true

    property var regionalData: ({})
    
    Component.onCompleted: {
        regionalData = SettingService.getRegionalSettings();

        if (!regionalData || Object.keys(regionalData).length === 0)
            return;

        localeCombo.currentValue = regionalData.locale || "en_US";
        currencyCombo.currentValue = regionalData.currency_code || "USD";
    }

    ColumnLayout {
        width: parent.width
        spacing: 30

        Label {
            text: qsTr("Region & Format Settings")
            font.pixelSize: Theme.fontLarge
            font.bold: true
            color: Theme.text
        }

        // locale
        ColumnLayout {
            spacing: 15

            Text {
                text: qsTr("Region & Language")
                font.bold: true
                color: Theme.secondaryText
                font.pixelSize: Theme.fontNormal
            }

            ColumnLayout {
                spacing: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Locale")
                        color: Theme.text
                        Layout.preferredWidth: 230
                        font.pixelSize: Theme.fontNormal
                    }

                    ComboBox {
                        id: localeCombo
                        Layout.preferredWidth: 220
                        font.pixelSize: Theme.fontNormal

                        model: [
                            { value: "en_US", label: "English (United States)" },
                            { value: "zh_CN", label: "中文 (简体)" }
                        ]

                        textRole: "label"
                        valueRole: "value"
                    }
                }
            }
        }

        // currency
        ColumnLayout {
            spacing: 15

            Text {
                text: qsTr("Currency")
                font.bold: true
                color: Theme.secondaryText
                font.pixelSize: Theme.fontNormal
            }

            ColumnLayout {
                spacing: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Default Currency")
                        color: Theme.text
                        Layout.preferredWidth: 230
                        font.pixelSize: Theme.fontNormal
                    }

                    ComboBox {
                        id: currencyCombo
                        Layout.preferredWidth: 220
                        font.pixelSize: Theme.fontNormal

                        model: [
                            { value: "USD", label: "$ (USD)" },
                            { value: "MYR", label: "RM (MYR)" },
                            { value: "EUR", label: "€ (EUR)" },
                            { value: "CNY", label: "¥ (CNY)" }
                        ]

                        textRole: "label"
                        valueRole: "value"
                    }
                }
            }
        }
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
                font.pixelSize: Theme.fontNormal
            }

            hoverEnabled: false
            focusPolicy: Qt.NoFocus

            onClicked: {
                var payload = {};

                payload.id = regionalData.id || 1;

                payload.locale = localeCombo.currentValue;

                payload.currency_code = currencyCombo.currentValue;

                SettingService.saveRegionalSettings(payload);
            }
        }

        Text {
            text: root.errorMessage
            color: "red"
            font.bold: true
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            font.pixelSize: Theme.fontNormal
        }
    }
}
