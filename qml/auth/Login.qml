import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    visible: true

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: Theme.background

            Column {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "Trudia"
                    font.bold: true
                    font.pixelSize: Theme.fontXL
                    color: Theme.text
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "v0.3.0"
                    font.pixelSize: Theme.fontSmall
                    color: Theme.secondaryText
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.background

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12
                width: 300

                Label {
                    text: qsTr("Username")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                }

                TextField {
                    id: usernameField
                    placeholderText: qsTr("Enter username")
                    font.pixelSize: Theme.fontNormal
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Password")
                    font.pixelSize: Theme.fontNormal
                    color: Theme.text
                }

                TextField {
                    id: passwordField
                    placeholderText: qsTr("Enter password")
                    font.pixelSize: Theme.fontNormal
                    echoMode: TextInput.Password
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    Layout.fillWidth: true
                }

                Button {
                    id: button
                    text: qsTr("Login")
                    Layout.fillWidth: true
                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 15
                    bottomPadding: 15
                    Layout.topMargin: 15
                    background: Rectangle {
                        color: Theme.primary()
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("Login")
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
                        var username = usernameField.text
                        var password = passwordField.text
                        if (AuthService.login(username, password)) {
                            var userRole = AuthService.currentUserRole
                            if (userRole === "admin") {
                                stackView.push("../admin/AdminHome.qml")
                            } else if (userRole === "service_staff") {
                                stackView.push(
                                            "../serviceStaff/ServiceStaffHome.qml")
                            } else if (userRole === "kitchen_staff") {
                                stackView.push(
                                            "../kitchenStaff/KitchenStaffHome.qml")
                            }

                            Window.window.showMaximized()
                        } else {
                            errorMessage.text = qsTr(
                                        "Invalid username or password.")
                        }
                    }
                }

                Text {
                    id: errorMessage
                    text: ""
                    color: Theme.error()
                    font.pixelSize: Theme.fontNormal
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
