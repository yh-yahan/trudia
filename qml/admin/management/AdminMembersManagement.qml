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
                            : Theme.error

                        font.pixelSize: Theme.fontNormal
                        Layout.preferredWidth: 120
                    }
                }
            }
        }
    }
}
