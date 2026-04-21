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
        timezoneCombo.currentIndex = timezoneCombo.find(regionalData.timezone || "America/New_York");

        dateFormatCombo.currentValue = regionalData.date_format || "yyyy-MM-dd";
        timeFormatCombo.currentValue = regionalData.time_format || "HH:mm";
    }

    ColumnLayout {
        width: parent.width
        spacing: 30

        Label {
            text: qsTr("Region & Format Settings")
            font.pixelSize: 26
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
                        text: qsTr("Locale")
                        color: Theme.text
                        Layout.preferredWidth: 230
                    }

                    ComboBox {
                        id: localeCombo
                        Layout.preferredWidth: 220

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
                        text: qsTr("Default Currency")
                        color: Theme.text
                        Layout.preferredWidth: 230
                    }

                    ComboBox {
                        id: currencyCombo
                        Layout.preferredWidth: 220

                        model: [
                            { value: "USD", label: "$ (USD)" },
                            { value: "MYR", label: "RM (MYR)" },
                            { value: "EUR", label: "€ (EUR)" },
                            { value: "JPY", label: "¥ (JPY)" },
                            { value: "CNY", label: "¥ (CNY)" }
                        ]

                        textRole: "label"
                        valueRole: "value"
                    }
                }
            }
        }

        // time & region
        ColumnLayout {
            spacing: 15

            Text {
                text: qsTr("Time & Region")
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
                        text: qsTr("Timezone")
                        color: Theme.text
                        Layout.preferredWidth: 230
                    }

                    ComboBox {
                        id: timezoneCombo
                        Layout.preferredWidth: 220

                        model: [
                            "America/New_York",
                            "Europe/London",
                            "Asia/Kuala_Lumpur",
                            "Asia/Singapore",
                            "Asia/Jakarta",
                        ]
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Date Format")
                        color: Theme.text
                        Layout.preferredWidth: 230
                    }

                    ComboBox {
                        id: dateFormatCombo
                        Layout.preferredWidth: 220

                        model: [
                            { value: "MM/dd/yyyy", label: "MM/DD/YYYY" },
                            { value: "dd/MM/yyyy", label: "DD/MM/YYYY" },
                            { value: "yyyy-MM-dd", label: "YYYY-MM-DD" }
                        ]

                        textRole: "label"
                        valueRole: "value"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Time Format")
                        color: Theme.text
                        Layout.preferredWidth: 230
                    }

                    ComboBox {
                        id: timeFormatCombo
                        Layout.preferredWidth: 220

                        model: [
                            { value: "hh:mm AP", label: "12-hour" },
                            { value: "HH:mm", label: "24-hour" }
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
            }

            hoverEnabled: false
            focusPolicy: Qt.NoFocus

            onClicked: {
                var payload = {};

                payload.id = regionalData.id || 1;

                payload.locale = localeCombo.currentValue;

                payload.currency_code = currencyCombo.currentValue;
                payload.timezone = timezoneCombo.currentText;

                payload.date_format = dateFormatCombo.currentValue;
                payload.time_format = timeFormatCombo.currentValue;

                SettingService.saveRegionalSettings(payload);
            }
        }
    }
}
