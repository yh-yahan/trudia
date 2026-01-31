import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Xeno.Services 1.0

Item {
    visible: true

    Rectangle {
        anchors.fill: parent
        color: "#181818"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: "#181818"

            Text {
                anchors.centerIn: parent
                text: "Xeno"
                font.bold: true
                font.pixelSize: 32
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#181818"

            ColumnLayout {
                anchors.centerIn: parent
                width: 300
                spacing: 12

                Text {
                    text: qsTr("Create your admin account")
                    font.bold: true
                    font.pixelSize: 28
                    color: "white"
                    wrapMode: Text.WordWrap
                }

                Label {
                    text: qsTr("Username")
                    color: "white"
                }

                TextField {
                    id: usernameField
                    placeholderText: "Enter username"
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Password")
                    color: "white"
                }

                TextField {
                    id: passwordField
                    placeholderText: "Enter password"
                    echoMode: TextInput.Password
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Confirm password")
                    color: "white"
                }

                TextField {
                    id: passwordConfirmField
                    placeholderText: "Confirm password"
                    echoMode: TextInput.Password
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    Layout.fillWidth: true
                }

                Button {
                    text: "Register"
                    Layout.fillWidth: true
                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 15
                    bottomPadding: 15
                    Layout.topMargin: 15
                    background: Rectangle {
                        color: "#9a7bff"
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("Register")
                        font.bold: true
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: {
                        var username = usernameField.text
                        var password = passwordField.text
                        var passwordConfirm = passwordConfirmField.text

                        if (AuthService.registerUser(username, password,
                                                     passwordConfirm)) {
                            stackView.push("../admin/AdminHome.qml")
                        } else {
                            errorMessage.text = qsTr("An error occurred.")
                        }
                    }
                }

                Text {
                    id: errorMessage
                    text: ""
                    color: "red"
                    font.pixelSize: 14
                    anchors.top: button.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
