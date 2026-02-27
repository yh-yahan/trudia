import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Xeno.Services 1.0

ScrollView {
    property var membershipData: ({})

    Component.onCompleted: {
        membershipData = SettingService.getMembershipSettings()

        if (!membershipData || Object.keys(membershipData).length === 0)
            return

        enableLoyaltySwitch.checked = membershipData.enabled

        earnRateField.text = membershipData.earn_rate || ""

        minSpendField.text = membershipData.min_spend ? (membershipData.min_spend / 100).toFixed(
                                                            2) : ""

        earnBaseCombo.currentIndex = membershipData.earn_on === "total" ? 1 : 0

        conversionRateField.text = membershipData.conversion || ""
        minRedeemField.text = membershipData.redeem_min_point || ""
        partialRedeemSwitch.checked = membershipData.partial_redemption
    }

    anchors.fill: parent
    contentWidth: parent.width
    clip: true

    ColumnLayout {
        width: parent.width
        spacing: 30

        Label {
            text: "Membership Settings"
            font.pixelSize: 26
            font.bold: true
            color: "white"
        }

        ColumnLayout {
            spacing: 15

            Text {
                text: "General"
                font.bold: true
                color: "#c9c9c9"
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
                        text: "Enable Points Loyalty"
                        color: "white"
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: enableLoyaltySwitch
                        checked: false
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 15
            visible: enableLoyaltySwitch.checked

            Text {
                text: "Earning Rules"
                font.bold: true
                color: "#c9c9c9"
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
                        text: "Earn Rate (points per RM1)"
                        color: "white"
                        Layout.preferredWidth: 230
                    }

                    TextField {
                        id: earnRateField
                        Layout.preferredWidth: 150
                        inputMethodHints: Qt.ImhDigitsOnly
                        placeholderText: "1"
                        color: "white"
                        placeholderTextColor: "#AAAAAA"

                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Minimum Spend (RM)"
                        color: "white"
                        Layout.preferredWidth: 230
                    }

                    TextField {
                        id: minSpendField
                        Layout.preferredWidth: 150
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        placeholderText: "0.00"
                        color: "white"
                        placeholderTextColor: "#AAAAAA"

                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Earn Based On"
                        color: "white"
                        Layout.preferredWidth: 230
                    }

                    ComboBox {
                        id: earnBaseCombo
                        Layout.preferredWidth: 220
                        model: ["Subtotal (Before Tax)", "Total (After Tax)"]
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 15
            visible: enableLoyaltySwitch.checked

            Text {
                text: "Redemption Rules"
                font.bold: true
                color: "#c9c9c9"
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
                        text: "Conversion (points = RM1)"
                        color: "white"
                        Layout.preferredWidth: 230
                    }

                    TextField {
                        id: conversionRateField
                        Layout.preferredWidth: 150
                        inputMethodHints: Qt.ImhDigitsOnly
                        placeholderText: "100"
                        color: "white"
                        placeholderTextColor: "#AAAAAA"

                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Minimum Points to Redeem"
                        color: "white"
                        Layout.preferredWidth: 230
                    }

                    TextField {
                        id: minRedeemField
                        Layout.preferredWidth: 150
                        inputMethodHints: Qt.ImhDigitsOnly
                        placeholderText: "100"
                        color: "white"
                        placeholderTextColor: "#AAAAAA"

                        background: Rectangle {
                            color: "#3A3A3A"
                            radius: 6
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Allow Partial Redemption"
                        color: "white"
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: partialRedeemSwitch
                        checked: false
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
            width: 80
            leftPadding: 20
            rightPadding: 20
            topPadding: 10
            bottomPadding: 10

            background: Rectangle {
                color: "#9a7bff"
                radius: 4
            }

            contentItem: Text {
                text: qsTr("Save")
                font.bold: true
                anchors.centerIn: parent
                color: "white"
            }

            hoverEnabled: false
            focusPolicy: Qt.NoFocus

            onClicked: {
                var payload = {}

                payload.id = membershipData.id || 1
                payload.enabled = enableLoyaltySwitch.checked

                payload.earn_rate = parseInt(earnRateField.text || 0)

                // convert RM → cents
                var minSpend = parseFloat(minSpendField.text || 0)
                payload.min_spend = Math.round(minSpend * 100)

                payload.earn_on = earnBaseCombo.currentIndex === 1 ? "total" : "subtotal"

                payload.conversion = parseInt(conversionRateField.text || 0)
                payload.redeem_min_point = parseInt(minRedeemField.text || 0)

                payload.partial_redemption = partialRedeemSwitch.checked ? 1 : 0

                SettingService.saveMembershipSettings(payload)
            }
        }
    }
}
