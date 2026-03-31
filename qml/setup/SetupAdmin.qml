import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Xeno.Services 1.0

Item {
    visible: true

    property bool running: false

    Connections {
        target: UserService

        function onCreateUserFinished(success) {
            running = false;

            if (!success) {
                errorMessage.text = "Could not create account";
                return;
            }

            if (!AuthService.login(usernameField.text, passwordField.text)) {
                errorMessage.text = "Login failed after registration";
                return;
            }

            stackView.push("../admin/AdminHome.qml");
            Window.window.showMaximized();
        }
    }

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

            Column {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "Xeno"
                    font.bold: true
                    font.pixelSize: 32
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "v0.1.0-beta"
                    font.pixelSize: 12
                    color: "#aaaaaa"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
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
                    placeholderText: qsTr("Enter username")
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
                    placeholderText: qsTr("Enter password")
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
                    placeholderText: qsTr("Confirm password")
                    echoMode: TextInput.Password
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    Layout.fillWidth: true
                }

                Button {
                    id: registerButton
                    text: qsTr("Register")
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
                        let username = usernameField.text.trim();
                        let pw = passwordField.text;
                        let pw2 = passwordConfirmField.text;

                        if (username === "" || pw === "") {
                            errorMessage.text = "Please fill in all fields";
                            return;
                        }

                        if (pw !== pw2) {
                            errorMessage.text = "Passwords do not match";
                            return;
                        }

                        errorMessage.text = "";
                        running = true;

                        UserService.createUser(username, pw, pw2, "admin");
                    }
                }

                Text {
                    id: errorMessage
                    text: ""
                    color: "red"
                    font.pixelSize: 14
                    anchors.top: registerButton.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
