import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0

ScrollView {
    property var membershipData: ({})

    Component.onCompleted: {
        membershipData = SettingService.getMembershipSettings();

        if (!membershipData || Object.keys(membershipData).length === 0)
            return;

        enableLoyaltySwitch.checked = membershipData.enabled;

        earnPointsField.text = membershipData.earn_points || "";
        earnSpendField.text = membershipData.earn_spend;

        redeemPointsField.text = membershipData.redeem_points || "";
        redeemValueField.text = membershipData.redeem_value;

        earnBaseCombo.currentValue = membershipData.earn_on || "subtotal";
    }

    anchors.fill: parent
    contentWidth: parent.width
    clip: true

    ColumnLayout {
        width: parent.width
        spacing: 30

        Label {
            text: qsTr("Membership Settings")
            font.pixelSize: 26
            font.bold: true
            color: "white"
        }

        ColumnLayout {
            spacing: 15

            Text {
                text: qsTr("General")
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
                        text: qsTr("Enable Points Loyalty")
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
                text: qsTr("Earning Rules")
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
                    spacing: 10

                    Label {
                        text: qsTr("Earn")
                        color: "white"
                        Layout.preferredWidth: 230
                    }

                    RowLayout {
                        spacing: 6

                        TextField {
                            id: earnPointsField
                            width: 60
                            inputMethodHints: Qt.ImhDigitsOnly
                            placeholderText: "1"
                            placeholderTextColor: "#AAAAAA"
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter

                            background: Rectangle {
                                color: "#3A3A3A"
                                radius: 6
                            }
                        }

                        Label {
                            text: qsTr("point(s) for every RM")
                            color: "white"
                        }

                        TextField {
                            id: earnSpendField
                            width: 80
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            placeholderText: "1.00"
                            placeholderTextColor: "#AAAAAA"
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter

                            background: Rectangle {
                                color: "#3A3A3A"
                                radius: 6
                            }
                        }

                        Label {
                            text: qsTr("spent")
                            color: "white"
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Earn Based On")
                        color: "white"
                        Layout.preferredWidth: 230
                    }

                    ComboBox {
                        id: earnBaseCombo
                        Layout.preferredWidth: 220
                        model: [
                            {
                                value: "subtotal",
                                label: qsTr("Subtotal (Before Tax)")
                            },
                            {
                                value: "total",
                                label: qsTr("Total (After Tax)")
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
                    spacing: 10

                    Label {
                        text: qsTr("Redemption")
                        color: "white"
                        Layout.preferredWidth: 230
                    }

                    RowLayout {
                        spacing: 6

                        TextField {
                            id: redeemPointsField
                            width: 80
                            inputMethodHints: Qt.ImhDigitsOnly
                            placeholderText: "100"
                            placeholderTextColor: "#AAAAAA"
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter

                            background: Rectangle {
                                color: "#3A3A3A"
                                radius: 6
                            }
                        }

                        Label {
                            text: qsTr("points = RM")
                            color: "white"
                        }

                        TextField {
                            id: redeemValueField
                            width: 80
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            placeholderText: "1.00"
                            placeholderTextColor: "#AAAAAA"
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter

                            background: Rectangle {
                                color: "#3A3A3A"
                                radius: 6
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
    }
}
