import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Trudia.Services 1.0
import trudia.Theme 1.0

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

            // stackView.push("../admin/AdminHome.qml");
            stackView.push("SetupBetaWelcome.qml");
        }
    }

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
                    text: "v0.2.1"
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
                width: 300
                spacing: 12

                Text {
                    text: qsTr("Create your admin account")
                    font.bold: true
                    font.pixelSize: Theme.fontXL
                    color: Theme.text
                    wrapMode: Text.WordWrap
                }

                Label {
                    text: qsTr("Username")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                }

                TextField {
                    id: usernameField
                    placeholderText: qsTr("Enter username")
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    Layout.fillWidth: true
                    font.pixelSize: Theme.fontNormal
                }

                Label {
                    text: qsTr("Password")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
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
                    font.pixelSize: Theme.fontNormal
                }

                Label {
                    text: qsTr("Confirm password")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
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
                    font.pixelSize: Theme.fontNormal
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
                        color: Theme.primary()
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("Register")
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
                    font.pixelSize: Theme.fontNormal
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
