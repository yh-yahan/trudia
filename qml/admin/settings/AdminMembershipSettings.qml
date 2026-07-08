import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

ScrollView {
    property var membershipData: ({})

    property string currencySymbol: SettingService.currencySymbol()

    Component.onCompleted: {
        membershipData = SettingService.getMembershipSettings();

        if (!membershipData || Object.keys(membershipData).length === 0)
            return;

        enableLoyaltySwitch.checked = membershipData.enabled;

        earnPointsField.text = membershipData.earn_points || "";
        earnSpendField.text = membershipData.earn_spend;

        redeemPointsField.text = membershipData.redeem_points || "";
        redeemValueField.text = membershipData.redeem_value;

        earnBaseCombo.currentValue = membershipData.earn_on || "total";
    }

    anchors.fill: parent
    contentWidth: parent.width
    clip: true

    ColumnLayout {
        width: parent.width
        spacing: 30

        Label {
            text: qsTr("Membership Settings")
            font.pixelSize: Theme.fontLarge
            font.bold: true
            color: Theme.text
        }

        ColumnLayout {
            spacing: 15

            Text {
                text: qsTr("General")
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
                        text: qsTr("Enable Points Loyalty")
                        color: Theme.text
                        Layout.fillWidth: true
                        font.pixelSize: Theme.fontNormal
                    }

                    Switch {
                        id: enableLoyaltySwitch
                        checked: false
                        font.pixelSize: Theme.fontNormal
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 15
            visible: enableLoyaltySwitch.checked

            Text {
                text: qsTr("Earning Rules")
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
                    spacing: 10

                    Label {
                        text: qsTr("Earn")
                        color: Theme.text
                        Layout.preferredWidth: 230
                        font.pixelSize: Theme.fontNormal
                    }

                    RowLayout {
                        spacing: 6

                        TextField {
                            id: earnPointsField
                            width: 60
                            inputMethodHints: Qt.ImhDigitsOnly
                            placeholderText: "1"
                            placeholderTextColor: Theme.secondaryText
                            color: Theme.text
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: Theme.fontNormal

                            background: Rectangle {
                                color: Theme.background
                                radius: 6
                            }
                        }

                        Label {
                            text: qsTr("point(s) for every %1").arg(currencySymbol)
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        TextField {
                            id: earnSpendField
                            width: 80
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            placeholderText: "1.00"
                            placeholderTextColor: Theme.secondaryText
                            color: Theme.text
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: Theme.fontNormal

                            background: Rectangle {
                                color: Theme.surface
                                radius: 6
                            }
                        }

                        Label {
                            text: qsTr("spent")
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Earn Based On")
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        Layout.preferredWidth: 230
                    }

                    ComboBox {
                        id: earnBaseCombo
                        Layout.preferredWidth: 220
                        font.pixelSize: Theme.fontNormal
                        model: [
                            {
                                value: "total",
                                label: qsTr("Total")
                            },
                            {
                                value: "subtotal",
                                label: qsTr("Subtotal")
                            }
                        ]
                        textRole: "label"
                        valueRole: "value"
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 15
            visible: enableLoyaltySwitch.checked

            Text {
                text: qsTr("Redemption Rules")
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
                    spacing: 10

                    Label {
                        text: qsTr("Redemption")
                        color: Theme.text
                        Layout.preferredWidth: 230
                        font.pixelSize: Theme.fontNormal
                    }

                    RowLayout {
                        spacing: 6

                        TextField {
                            id: redeemPointsField
                            width: 80
                            inputMethodHints: Qt.ImhDigitsOnly
                            placeholderText: "100"
                            placeholderTextColor: Theme.secondaryText
                            color: Theme.text
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: Theme.fontNormal

                            background: Rectangle {
                                color: Theme.surface
                                radius: 6
                            }
                        }

                        Label {
                            text: qsTr("points = %1").arg(currencySymbol)
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        TextField {
                            id: redeemValueField
                            width: 80
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            placeholderText: "1.00"
                            placeholderTextColor: Theme.secondaryText
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignHCenter

                            background: Rectangle {
                                color: Theme.background
                                radius: 6
                            }
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
            text: "Save"
            width: 80
            leftPadding: 20
            rightPadding: 20
            topPadding: 10
            bottomPadding: 10

            background: Rectangle {
                color: Theme.primary()
                radius: 4
            }

            contentItem: Text {
                text: qsTr("Save")
                font.bold: true
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: Theme.fontNormal
            }

            hoverEnabled: false
            focusPolicy: Qt.NoFocus

            onClicked: {
                var payload = {};

                payload.id = membershipData.id || 1;
                payload.enabled = enableLoyaltySwitch.checked;

                payload.earn_points = parseInt(earnPointsField.text || 0);
                payload.earn_spend = parseFloat(earnSpendField.text || 0);

                payload.redeem_points = parseInt(redeemPointsField.text || 0);
                payload.redeem_value = parseFloat(redeemValueField.text || 0);

                payload.earn_on = earnBaseCombo.currentValue;

                SettingService.saveMembershipSettings(payload);
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
