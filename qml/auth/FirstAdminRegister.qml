import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Xeno.Services 1.0

Item {
    property bool running: false

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
                            errorMessage.text = qsTr("Please fill in all fields");
                            return;
                        }
                        if (pw !== pw2) {
                            errorMessage.text = qsTr("Passwords do not match");
                            return;
                        }

                        running = true;
                        errorMessage.text = "";

                        var future = UserService.createUser(username, pw, pw2, "admin");
                        var watcher = Qt.createQmlObject('import QtQuick 2.0; QFutureWatcher {}', parent);

                        watcher.future = future;
                        watcher.finished.connect(function () {
                            var success = watcher.result;
                            if (!success) {
                                errorMessage.text = qsTr("Could not create account");
                                running = false;
                                return;
                            }

                            AuthService.login(username, pw).then(function (loginOk) {
                                running = false;
                                if (loginOk) {
                                    stackView.push("../admin/AdminHome.qml");
                                    Window.window.showMaximized();
                                } else {
                                    errorMessage.text = qsTr("Login failed after registration");
                                }
                            }).catch(function (err) {
                                running = false;
                                errorMessage.text = qsTr("Error: ") + (err || "Unknown error");
                                console.error("Login failed:", err);
                            });
                        });
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
