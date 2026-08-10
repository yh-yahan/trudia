import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    width: 900
    height: 600

    Component.onCompleted: {
        MemberService.loadMembers()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: qsTr("Member Management")
                font.pixelSize: Theme.fontLarge
                font.bold: true
                color: Theme.text
                Layout.fillWidth: true
            }
        }

        TextField {
            id: searchField

            Layout.fillWidth: true

            placeholderText: qsTr("Search phone number")
            color: Theme.text
            placeholderTextColor: Theme.secondaryText

            background: Rectangle {
                color: Theme.surface
                radius: 4
            }

            leftPadding: 10
            rightPadding: 10

            onTextChanged: {
                MemberService.searchMembers(text)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: Theme.background
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12

                Text {
                    text: qsTr("Phone Number")
                    color: Theme.secondaryText
                    font.bold: true
                    font.pixelSize: Theme.fontSmall
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr("Points")
                    color: Theme.secondaryText
                    font.bold: true
                    font.pixelSize: Theme.fontSmall
                    Layout.preferredWidth: 120
                }

                Text {
                    text: qsTr("Status")
                    color: Theme.secondaryText
                    font.bold: true
                    font.pixelSize: Theme.fontSmall
                    Layout.preferredWidth: 120
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: MemberService.membersModel

            clip: true
            spacing: 4

            delegate: Rectangle {
                width: ListView.view.width
                height: 44
                radius: 4
                color: Theme.background

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        memberDialog.memberId = id
                        memberDialog.open()
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8

                    Text {
                        text: phoneNumber
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        Layout.fillWidth: true
                    }

                    Text {
                        text: totalPoints
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        Layout.preferredWidth: 120
                    }

                    Text {
                        text: status
                        color: status === "active"
                            ? Theme.green
                            : Theme.error()

                        font.pixelSize: Theme.fontNormal
                        Layout.preferredWidth: 120
                    }
                }
            }
        }
    }

    Dialog {
        id: memberDialog

        property int memberId: 0
        property var member

        anchors.centerIn: Overlay.overlay

        width: 700
        height: 500
        modal: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16

            Label {
                text: qsTr("Member Phone: %1").arg(memberDialog.member.phoneNumber)
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            Label {
                text: qsTr("Points: %1").arg(memberDialog.member.totalPoints)
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            Label {
                text: qsTr("Status: %1").arg(memberDialog.member.status)
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            Label {
                text: qsTr("Transactions")
                font.bold: true
                font.pixelSize: Theme.fontLarge
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                border.width: 1
                border.color: Theme.border
                radius: 4
                color: Theme.surface

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        color: Theme.surfaceVariant

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            Label {
                                Layout.preferredWidth: 120
                                text: qsTr("Type")
                                font.bold: true
                            }

                            Label {
                                Layout.preferredWidth: 80
                                text: qsTr("Points")
                                font.bold: true
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }

                            Label {
                                Layout.preferredWidth: 120
                                text: qsTr("Source")
                                font.bold: true
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }

                            Label {
                                Layout.fillWidth: true
                                text: qsTr("Date")
                                font.bold: true
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        clip: true
                        model: MemberService.transactionModel

                        ScrollBar.vertical: ScrollBar {}

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 40

                            color: index % 2 === 0
                                ? Theme.background
                                : Theme.surface

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8

                                Label {
                                    Layout.preferredWidth: 120
                                    text: type === "earn"
                                        ? qsTr("Earn")
                                        : qsTr("Redeem")
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }

                                Label {
                                    Layout.preferredWidth: 80
                                    text: (type === "redeem" ? "-" : "+") + points
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }

                                Label {
                                    Layout.preferredWidth: 120
                                    text: orderDisplayNumber > 0
                                        ? "#" + orderDisplayNumber
                                        : qsTr("Manual")
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }

                                Label {
                                    Layout.fillWidth: true
                                    text: Qt.formatDateTime(
                                        createdAt,
                                        "dd/MM/yyyy hh:mm"
                                    )
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }
                            }
                        }
                    }
                }
            }
        }

        onOpened: {
            member = MemberService.getMemberDetails(memberId)
            MemberService.loadTransactions(memberId)
        }

        background: Rectangle {
            color: Theme.background
            radius: 6
        }
    }
}
