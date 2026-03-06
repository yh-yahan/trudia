import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Xeno.Services 1.0
import "../../components"

Item {
    width: 900
    height: 600

    property var users: []

    function loadUsers() {
        users = UserService.getAllUsers();
    }

    Component.onCompleted: loadUsers()

    ConfirmationDialog {
        id: confirmationDialog
        anchors.centerIn: parent
    }

    Rectangle {
        anchors.fill: parent
        color: "#121212"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: qsTr("User Management")
                font.pixelSize: 20
                font.bold: true
                color: "white"
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Create User")
                hoverEnabled: false
                focusPolicy: Qt.NoFocus

                background: Rectangle {
                    color: "#9a7bff"
                    radius: 4
                }

                contentItem: Text {
                    text: qsTr("Create User")
                    color: "white"
                    anchors.centerIn: parent
                    font.bold: true
                }

                onClicked: createDialog.open()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#1f1f1f"
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Text {
                    text: qsTr("Username")
                    color: "#b0b0b0"
                    font.bold: true
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr("Role")
                    color: "#b0b0b0"
                    font.bold: true
                    Layout.preferredWidth: 140
                }

                Text {
                    text: qsTr("Active")
                    color: "#b0b0b0"
                    font.bold: true
                    Layout.preferredWidth: 100
                }

                Item {
                    Layout.preferredWidth: 260
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: users
            clip: true
            spacing: 4

            delegate: Rectangle {
                height: 44
                width: ListView.view.width
                radius: 4
                color: "#1f1f1f"
                border.color: "#2a2a2a"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    Text {
                        text: modelData.username
                        color: "white"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: modelData.role
                        color: "#d0d0d0"
                        Layout.preferredWidth: 140
                    }

                    Text {
                        text: modelData.active ? qsTr("Yes") : qsTr("No")
                        color: modelData.active ? "#7ed957" : "#ff6b6b"
                        Layout.preferredWidth: 100
                    }

                    Button {
                        text: qsTr("Edit")
                        visible: modelData.active

                        background: Rectangle {
                            color: "#9a7bff"
                            radius: 4
                        }

                        contentItem: Text {
                            text: qsTr("Edit")
                            color: "white"
                            anchors.centerIn: parent
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            editDialog.userId = modelData.id;
                            editDialog.username = modelData.username;
                            editDialog.role = modelData.role;
                            editDialog.open();
                        }
                    }

                    Button {
                        text: qsTr("Password")
                        visible: modelData.active

                        background: Rectangle {
                            color: "#444"
                            radius: 4
                        }

                        contentItem: Text {
                            text: qsTr("Password")
                            color: "white"
                            anchors.centerIn: parent
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            passwordDialog.userId = modelData.id;
                            passwordDialog.open();
                        }
                    }

                    Button {
                        text: qsTr("Deactivate")
                        visible: modelData.active

                        background: Rectangle {
                            color: "red"
                            radius: 4
                        }

                        contentItem: Text {
                            text: qsTr("Deactivate")
                            color: "white"
                            anchors.centerIn: parent
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            confirmationDialog.title = qsTr("Deactivate User");
                            confirmationDialog.contentItem.children[0].text = qsTr("Deactivate \"%1\"?").arg(modelData.username);

                            confirmationDialog.confirmCallback = function (confirmed) {
                                if (confirmed) {
                                    UserService.deactivateUser(modelData.id);
                                    loadUsers();
                                }
                            };

                            confirmationDialog.open();
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: createDialog
        modal: true
        focus: true

        anchors.centerIn: Overlay.overlay

        width: 460
        height: 400
        padding: 0

        background: Rectangle {
            color: "#1f1f1f"
            radius: 8
            border.color: "#2a2a2a"
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 6

            Text {
                text: qsTr("Create User")
                font.pixelSize: 18
                font.bold: true
                color: "white"
            }

            Label {
                text: qsTr("Username")
                color: "white"
            }

            TextField {
                id: newUsername
                placeholderText: qsTr("Username")
                background: Rectangle {
                    color: "#292929"
                    radius: 4
                }
                color: "white"
                placeholderTextColor: "#b5b5b5"
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
                id: newPassword
                placeholderText: qsTr("Password")
                background: Rectangle {
                    color: "#292929"
                    radius: 4
                }
                color: "white"
                placeholderTextColor: "#b5b5b5"
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                echoMode: TextInput.Password
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Confirm Password")
                color: "white"
            }

            TextField {
                id: newPasswordConfirm
                placeholderText: qsTr("Confirm Password")
                background: Rectangle {
                    color: "#292929"
                    radius: 4
                }
                color: "white"
                placeholderTextColor: "#b5b5b5"
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                echoMode: TextInput.Password
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Role")
                color: "white"
            }

            ComboBox {
                id: newRole
                model: ["admin", "service_staff", "kitchen_staff"]
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                Button {
                    text: qsTr("Create")

                    background: Rectangle {
                        color: "#9a7bff"
                        radius: 4
                    }

                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15

                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus

                    contentItem: Text {
                        text: qsTr("Create")
                        color: "white"
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        var ok = UserService.createUser(newUsername.text, newPassword.text, newPasswordConfirm.text, newRole.currentText);

                        if (ok) {
                            createDialog.close();
                            loadUsers();
                        }
                    }
                }

                Button {
                    text: qsTr("Cancel")
                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    background: Rectangle {
                        color: '#6b6b6b'
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("Cancel")
                        color: "white"
                        anchors.centerIn: parent
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: createDialog.close()
                }
            }
        }
    }

    Dialog {
        id: editDialog
        modal: true

        anchors.centerIn: Overlay.overlay

        width: 320
        height: 300

        property int userId: -1
        property string username: ""
        property string role: ""

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 6

            Text {
                text: qsTr("Edit User")
                font.bold: true
                font.pixelSize: 16
                color: "white"
            }

            Label {
                text: qsTr("Username")
                color: "white"
            }

            TextField {
                id: editUsername
                placeholderText: qsTr("Username")
                background: Rectangle {
                    color: "#292929"
                    radius: 4
                }
                color: "white"
                placeholderTextColor: "#b5b5b5"
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                Layout.fillWidth: true
                text: editDialog.username
            }

            Label {
                text: qsTr("Role")
                color: "white"
            }

            ComboBox {
                id: editRole
                model: ["admin", "service_staff", "kitchen_staff"]
                Component.onCompleted: currentIndex = role === "admin" ? 0 : 1
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8
                Button {
                    text: qsTr("Save")
                    background: Rectangle {
                        color: "#9a7bff"
                        radius: 4
                    }
                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    contentItem: Text {
                        text: qsTr("Save")
                        color: "white"
                        anchors.centerIn: parent
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: {
                        var ok = UserService.updateUser(editDialog.userId, editUsername.text, editRole.currentText);

                        if (ok) {
                            editDialog.close();
                            loadUsers();
                        }
                    }
                }

                Button {
                    text: qsTr("Cancel")
                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    background: Rectangle {
                        color: '#6b6b6b'
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("Cancel")
                        color: "white"
                        anchors.centerIn: parent
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: editDialog.close()
                }
            }
        }

        background: Rectangle {
            color: "#1f1f1f"
            radius: 6
        }
    }

    Dialog {
        id: passwordDialog
        anchors.centerIn: Overlay.overlay
        modal: true
        width: 360
        height: 340

        property int userId: -1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 6

            Text {
                text: qsTr("Change Password")
                font.bold: true
                font.pixelSize: 16
                color: "white"
            }

            Label {
                text: qsTr("Old Password")
                color: "white"
            }

            TextField {
                id: oldPass
                placeholderText: qsTr("Old Password")
                background: Rectangle {
                    color: "#292929"
                    radius: 4
                }
                color: "white"
                placeholderTextColor: "#b5b5b5"
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                echoMode: TextInput.Password
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("New Password")
                color: "white"
            }

            TextField {
                id: newPass
                placeholderText: qsTr("New Password")
                background: Rectangle {
                    color: "#292929"
                    radius: 4
                }
                color: "white"
                placeholderTextColor: "#b5b5b5"
                echoMode: TextInput.Password
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Confirm New Password")
                color: "white"
            }

            TextField {
                id: newPassConfirm
                placeholderText: qsTr("Confirm New Password")
                background: Rectangle {
                    color: "#292929"
                    radius: 4
                }
                color: "white"
                placeholderTextColor: "#b5b5b5"
                echoMode: TextInput.Password
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                Button {
                    text: qsTr("Change Password")
                    background: Rectangle {
                        color: "#9a7bff"
                        radius: 4
                    }

                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    contentItem: Text {
                        text: qsTr("Change Password")
                        color: "white"
                        anchors.centerIn: parent
                    }
                    onClicked: {
                        var ok = UserService.changePassword(passwordDialog.userId, oldPass.text, newPass.text, newPassConfirm.text);

                        if (ok) {
                            passwordDialog.close();
                            oldPass.text = "";
                            newPass.text = "";
                            newPassConfirm.text = "";
                        }
                    }
                }
                Button {
                    text: qsTr("Cancel")
                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    background: Rectangle {
                        color: '#6b6b6b'
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("Cancel")
                        color: "white"
                        anchors.centerIn: parent
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: passwordDialog.close()
                }
            }
        }

        background: Rectangle {
            color: "#1f1f1f"
            radius: 6
        }
    }
}
