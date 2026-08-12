import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0
import "../../components"

Item {
    width: 900
    height: 600

    Connections {
        target: UserService

        function onCreateUserFinished(success) {

            if (!createDialog.visible)
                return

            if (success) {
                createDialog.close()
            }
        }
    }

    ConfirmationDialog {
        id: confirmationDialog
        anchors.centerIn: parent
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
                text: qsTr("User Management")
                font.pixelSize: Theme.fontLarge
                font.bold: true
                color: Theme.text
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Create User")
                hoverEnabled: false
                focusPolicy: Qt.NoFocus

                background: Rectangle {
                    color: Theme.primary()
                    radius: 4
                }

                contentItem: Text {
                    text: qsTr("Create User")
                    color: "white"
                    anchors.centerIn: parent
                    font.bold: true
                    font.pixelSize: Theme.fontNormal
                }

                onClicked: createDialog.open()
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
                spacing: 12

                Text {
                    text: qsTr("Username")
                    color: Theme.secondaryText
                    font.bold: true
                    Layout.fillWidth: true
                    font.pixelSize: Theme.fontSmall
                }

                Text {
                    text: qsTr("Role")
                    color: Theme.secondaryText
                    font.bold: true
                    Layout.preferredWidth: 140
                    font.pixelSize: Theme.fontSmall
                }

                Text {
                    text: qsTr("Active")
                    color: Theme.secondaryText
                    font.bold: true
                    Layout.preferredWidth: 100
                    font.pixelSize: Theme.fontSmall
                }

                Item {
                    Layout.preferredWidth: 260
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: UserService.userModel
            clip: true
            spacing: 4

            delegate: Rectangle {
                height: 44
                width: ListView.view.width
                radius: 4
                color: Theme.background

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    Text {
                        text: username
                        color: Theme.text
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        font.pixelSize: Theme.fontNormal
                    }

                    Text {
                        text: role
                        color: Theme.secondaryText
                        Layout.preferredWidth: 140
                        font.pixelSize: Theme.fontNormal
                    }

                    Text {
                        text: active ? qsTr("Yes") : qsTr("No")
                        color: active ? Theme.green : Theme.error()
                        Layout.preferredWidth: 100
                        font.pixelSize: Theme.fontNormal
                    }

                    Button {
                        text: qsTr("Edit")
                        visible: active

                        background: Rectangle {
                            color: Theme.primary()
                            radius: 4
                        }

                        contentItem: Text {
                            text: qsTr("Edit")
                            color: "white"
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontNormal
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            editDialog.userId = id
                            editDialog.username = username
                            editDialog.role = role
                            editDialog.open()
                        }
                    }

                    Button {
                        text: qsTr("Password")
                        visible: active

                        background: Rectangle {
                            color: Theme.surface
                            radius: 4
                        }

                        contentItem: Text {
                            text: qsTr("Password")
                            color: Theme.text
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontNormal
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            passwordDialog.userId = id
                            passwordDialog.open()
                        }
                    }

                    Button {
                        text: qsTr("Deactivate")
                        visible: active

                        background: Rectangle {
                            color: "red"
                            radius: 4
                        }

                        contentItem: Text {
                            text: qsTr("Deactivate")
                            color: "white"
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontNormal
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            confirmationDialog.title = qsTr("Deactivate User")
                            confirmationDialog.message = qsTr(
                                        'Deactivate "%1"?').arg(username)

                            confirmationDialog.confirmCallback = function (confirmed) {
                                if (confirmed) {
                                    UserService.deactivateUser(id)
                                }
                            }

                            confirmationDialog.open()
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
        height: 450
        padding: 0

        background: Rectangle {
            color: Theme.background
            radius: 8
            border.color: Theme.border
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 6

            Text {
                text: qsTr("Create User")
                font.pixelSize: Theme.fontLarge
                font.bold: true
                color: Theme.text
            }

            Label {
                text: qsTr("Username")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            TextField {
                id: newUsername
                placeholderText: qsTr("Username")
                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                }
                color: Theme.text
                font.pixelSize: Theme.fontNormal
                placeholderTextColor: Theme.secondaryText
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Password")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            TextField {
                id: newPassword
                placeholderText: qsTr("Password")
                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                }
                color: Theme.text
                font.pixelSize: Theme.fontNormal
                placeholderTextColor: Theme.secondaryText
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                echoMode: TextInput.Password
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Confirm Password")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            TextField {
                id: newPasswordConfirm
                placeholderText: qsTr("Confirm Password")
                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                }
                color: Theme.text
                font.pixelSize: Theme.fontNormal
                placeholderTextColor: Theme.secondaryText
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                echoMode: TextInput.Password
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Role")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            ComboBox {
                id: newRole

                model: [
                    { value: "admin", text: qsTr("Admin") },
                    { value: "service_staff", text: qsTr("Service Staff") },
                    { value: "kitchen_staff", text: qsTr("Kitchen Staff") }
                ]

                textRole: "text"
                valueRole: "value"
                implicitHeight: 42
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                Layout.fillWidth: true
                font.pixelSize: Theme.fontNormal
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                Button {
                    text: qsTr("Create")

                    background: Rectangle {
                        color: Theme.primary()
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
                        font.pixelSize: Theme.fontNormal
                    }

                    onClicked: {
                        UserService.createUser(newUsername.text,
                                               newPassword.text,
                                               newPasswordConfirm.text,
                                               newRole.currentText)

                        newUsername.text = "";
                        newPassword.text = "";
                        newPasswordConfirm.text = "";
                        newRole.currentText = "";
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
                        font.pixelSize: Theme.fontNormal
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: {
                        createDialog.close()

                        newUsername.text = "";
                        newPassword.text = "";
                        newPasswordConfirm.text = "";
                        newRole.currentText = "";
                    }
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
                font.pixelSize: Theme.fontLarge
                color: Theme.text
            }

            Label {
                text: qsTr("Username")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            TextField {
                id: editUsername
                placeholderText: qsTr("Username")
                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                }
                color: Theme.text
                font.pixelSize: Theme.fontNormal
                placeholderTextColor: Theme.secondaryText
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                Layout.fillWidth: true
                text: editDialog.username
            }

            Label {
                text: qsTr("Role")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            ComboBox {
                id: editRole
                model: ["admin", "service_staff", "kitchen_staff"]
                Component.onCompleted: {
                    if (editDialog.role === "admin")
                        currentIndex = 0
                    else if (editDialog.role === "service_staff")
                        currentIndex = 1
                    else if (editDialog.role === "kitchen_staff")
                        currentIndex = 2
                }
                font.pixelSize: Theme.fontNormal
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
                        color: Theme.primary()
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
                        font.pixelSize: Theme.fontNormal
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: {
                        var ok = UserService.updateUser(editDialog.userId,
                                                        editUsername.text,
                                                        editRole.currentText)

                        if (ok) {
                            editDialog.close()
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
                        font.pixelSize: Theme.fontNormal
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: editDialog.close()
                }
            }
        }

        background: Rectangle {
            color: Theme.background
            radius: 6
        }
    }

    Dialog {
        id: passwordDialog
        anchors.centerIn: Overlay.overlay
        modal: true
        width: 360
        height: 380

        property int userId: -1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 6

            Text {
                text: qsTr("Change Password")
                font.bold: true
                font.pixelSize: Theme.fontLarge
                color: Theme.text
            }

            Label {
                text: qsTr("Old Password")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            TextField {
                id: oldPass
                placeholderText: qsTr("Old Password")
                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                }
                color: Theme.text
                font.pixelSize: Theme.fontNormal
                placeholderTextColor: Theme.secondaryText
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                echoMode: TextInput.Password
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("New Password")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            TextField {
                id: newPass
                placeholderText: qsTr("New Password")
                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                }
                color: Theme.text
                font.pixelSize: Theme.fontNormal
                placeholderTextColor: Theme.secondaryText
                echoMode: TextInput.Password
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Confirm New Password")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            TextField {
                id: newPassConfirm
                placeholderText: qsTr("Confirm New Password")
                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                }
                color: Theme.text
                font.pixelSize: Theme.fontNormal
                placeholderTextColor: Theme.secondaryText
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
                        color: Theme.primary()
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
                        font.pixelSize: Theme.fontNormal
                    }
                    onClicked: {
                        var ok = UserService.changePassword(
                                    passwordDialog.userId, oldPass.text,
                                    newPass.text, newPassConfirm.text)

                        if (ok) {
                            passwordDialog.close()
                            oldPass.text = ""
                            newPass.text = ""
                            newPassConfirm.text = ""
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
                        font.pixelSize: Theme.fontNormal
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus
                    onClicked: passwordDialog.close()
                }
            }
        }

        background: Rectangle {
            color: Theme.background
            radius: 6
        }
    }
}
