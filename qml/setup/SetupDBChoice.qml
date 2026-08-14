import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    id: root

    property string mode: "none" // none/exists/missing/unusable
    property string currentPath: ""

    property bool databaseExists: mode === "exists"
    property bool databaseMissing: mode === "missing"
    property bool databaseUnusable: mode === "unusable"
    property bool hasDatabaseProblem: databaseMissing || databaseUnusable

    Component.onCompleted: {
        if (databaseMissing || databaseUnusable) {
            root.currentPath = AppService.databasePath();
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: 450
        spacing: 16

        Text {
            text: {
                if (root.databaseExists)
                    return qsTr("Database Already Exists")
                if (root.databaseMissing)
                    return qsTr("Database Not Found")
                if (root.databaseUnusable)
                    return qsTr("Database Cannot Be Opened or Is Not a Valid Trudia Database")
                return qsTr("Set up Trudia")
            }
            font.pixelSize: Theme.fontLarge
            font.bold: true
            color: Theme.text
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            text: {
                if (root.databaseExists) {
                    return qsTr(
                        "A Trudia database already exists at this location."
                    )
                }

                if (root.databaseMissing) {
                    return qsTr(
                        "Trudia couldn't find the database at the "
                        + "location saved on this computer."
                    )
                }

                if (root.databaseUnusable) {
                    return qsTr(
                        "A database was found at the location saved on this computer, but Trudia could not use it."
                    )
                }

                return qsTr(
                    "Choose how you would like to set up your database."
                )
            }
            color: Theme.secondaryText
            font.pixelSize: Theme.fontNormal
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            visible: root.databaseExists
                    || root.databaseMissing
                    || root.databaseUnusable
            text: root.currentPath
            color: Theme.secondaryText
            font.pixelSize: Theme.fontSmall
            wrapMode: Text.Wrap
            elide: Text.ElideMiddle
            Layout.fillWidth: true
        }

        Item {
            Layout.preferredHeight: 8
        }

        // normal setup
        Button {
            visible: root.mode === "none" || root.mode === "unusable"

            Layout.fillWidth: true
            Layout.preferredHeight: 90

            background: Rectangle {
                color: parent.down
                       ? Theme.primary()
                       : Theme.surface
                radius: 6
                border.color: Theme.primary()
                border.width: 1
            }

            contentItem: ColumnLayout {
                spacing: 4

                Text {
                    text: qsTr("Create New Database")
                    color: parent.parent.down
                           ? "white"
                           : Theme.text
                    font.pixelSize: Theme.fontNormal
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr(
                        "Start with a new, empty database."
                    )

                    color: parent.parent.down
                           ? "white"
                           : Theme.secondaryText
                    font.pixelSize: Theme.fontSmall
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            onClicked: stackView.push("./SetupDBCreation.qml")
        }

        Button {
            visible: root.mode === "none"
                || root.databaseMissing

            Layout.fillWidth: true
            Layout.preferredHeight: 90

            background: Rectangle {
                color: parent.down
                       ? Theme.primary()
                       : Theme.surface
                radius: 6
                border.color: Theme.primary()
                border.width: 1
            }

            contentItem: ColumnLayout {
                spacing: 4

                Text {
                    text: qsTr("Open Existing Database")
                    color: parent.parent.down
                           ? "white"
                           : Theme.text
                    font.pixelSize: Theme.fontNormal
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr(
                        "Use a Trudia database that already exists."
                    )

                    color: parent.parent.down
                           ? "white"
                           : Theme.secondaryText
                    font.pixelSize: Theme.fontSmall
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            onClicked: stackView.push("./SetupDBOpen.qml")
        }

        // missing database
        
        // open another (existing) db button is reusing the button from normal setup

        Button {
            visible: root.databaseMissing
            Layout.fillWidth: true
            Layout.preferredHeight: 90

            background: Rectangle {
                color: parent.down
                    ? Theme.primary()
                    : Theme.surface
                radius: 6
                border.color: Theme.primary()
                border.width: 1
            }

            contentItem: ColumnLayout {
                spacing: 4

                Text {
                    text: qsTr("Create New Database Here")
                    color: parent.parent.down
                        ? "white"
                        : Theme.text
                    font.pixelSize: Theme.fontNormal
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr(
                        "Create a new database at the saved location."
                    )
                    color: parent.parent.down
                        ? "white"
                        : Theme.secondaryText
                    font.pixelSize: Theme.fontSmall
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            onClicked: {
                let SetupResult = SetupService.initializeApp(currentPath);

                switch (SetupResult) {
                case SetupService.Success:
                    Qt.callLater(function () {
                        SetupService.restartApp();
                    });
                    break;
                case SetupService.DatabaseExists:
                    stackView.push("./SetupDBChoice.qml", {
                        "mode": "exists",
                        "currentPath": currentPath
                    })
                    break;
                case SetupService.InvalidPath:
                    errorText = qsTr("Invalid path");
                    break;
                case SetupService.InitializationFailed:
                    errorText = qsTr("Setup failed. Please try again.");
                    break;
                }
            }
        }

        // unusable database

        // create database button is from normal setup
        
        Button {
            visible: root.databaseUnusable
            Layout.fillWidth: true
            Layout.preferredHeight: 90

            background: Rectangle {
                color: parent.down
                    ? Theme.primary()
                    : Theme.surface
                radius: 6
                border.color: Theme.primary()
                border.width: 1
            }

            contentItem: ColumnLayout {
                spacing: 4

                Text {
                    text: qsTr("Choose Another Database")
                    color: parent.parent.down
                        ? "white"
                        : Theme.text
                    font.pixelSize: Theme.fontNormal
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr(
                        "Open a different Trudia database."
                    )
                    color: parent.parent.down
                        ? "white"
                        : Theme.secondaryText
                    font.pixelSize: Theme.fontSmall
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            onClicked: {
                stackView.push("./SetupDBOpen.qml")
            }
        }

        // replace db button is reusing the button from existing database setup

        // existing database
        Button {
            visible: root.databaseExists

            Layout.fillWidth: true
            Layout.preferredHeight: 90

            background: Rectangle {
                color: parent.down
                       ? Theme.primary()
                       : Theme.surface
                radius: 6
                border.color: Theme.primary()
                border.width: 1
            }

            contentItem: ColumnLayout {
                spacing: 4

                Text {
                    text: qsTr("Use Existing Database")
                    color: parent.parent.down
                           ? "white"
                           : Theme.text
                    font.pixelSize: Theme.fontNormal
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr("Open the database already at this location.")

                    color: parent.parent.down
                           ? "white"
                           : Theme.secondaryText
                    font.pixelSize: Theme.fontSmall
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            onClicked: {
                DatabaseService.openDatabase(root.currentPath)

                Qt.callLater(function () {
                    SetupService.restartApp()
                })
            }
        }

        Button {
            visible: root.databaseExists

            Layout.fillWidth: true
            Layout.preferredHeight: 90

            background: Rectangle {
                color: parent.down
                       ? Theme.primary()
                       : Theme.surface
                radius: 6
                border.color: Theme.primary()
                border.width: 1
            }

            contentItem: ColumnLayout {
                spacing: 4

                Text {
                    text: qsTr("Choose Another Location")
                    color: parent.parent.down
                           ? "white"
                           : Theme.text
                    font.pixelSize: Theme.fontNormal
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr("Choose a different location for your database.")

                    color: parent.parent.down
                           ? "white"
                           : Theme.secondaryText
                    font.pixelSize: Theme.fontSmall
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            onClicked: {
                stackView.pop()
            }
        }

        Button {
            visible: root.databaseExists || root.databaseUnusable

            Layout.fillWidth: true
            Layout.preferredHeight: 70

            background: Rectangle {
                color: parent.down
                    ? Theme.error()
                    : "transparent"
                radius: 6
                border.color: Theme.error()
                border.width: 1
            }

            contentItem: Text {
                text: qsTr("Replace Existing Database")
                color: parent.down
                    ? "white"
                    : Theme.error()
                font.pixelSize: Theme.fontSmall
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
            }

            onClicked: replaceDialog.open()
        }

        Dialog {
            id: replaceDialog

            anchors.centerIn: parent
            modal: true
            width: 420
            padding: 24

            title: qsTr("Replace Existing Database")

            background: Rectangle {
                color: Theme.surface
            }

            header: Text {
                text: replaceDialog.title

                color: Theme.text
                font.pixelSize: Theme.fontLarge
                font.bold: true

                leftPadding: 24
                rightPadding: 24
                topPadding: 20
                bottomPadding: 4
            }

            contentItem: ColumnLayout {
                spacing: 14

                Text {
                    text: qsTr(
                        "This will permanently delete the existing database and create a new one."
                    )

                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr(
                        "All data stored in this database will be lost. This action cannot be undone."
                    )

                    color: Theme.error()
                    font.pixelSize: Theme.fontSmall
                    font.bold: true
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr('To continue, type "REPLACE" below.')

                    color: Theme.secondaryText
                    font.pixelSize: Theme.fontSmall
                    Layout.fillWidth: true
                }

                TextField {
                    id: replaceInput

                    Layout.fillWidth: true

                    color: Theme.text
                    font.pixelSize: Theme.fontNormal

                    background: Rectangle {
                        color: Theme.background
                        radius: 4
                        border.color: replaceInput.activeFocus
                            ? Theme.primary()
                            : Theme.secondaryText
                        border.width: 1
                    }

                    onTextChanged: {
                        replaceButton.enabled = text === "REPLACE"
                    }
                }

                Text {
                    text: root.currentPath

                    color: Theme.secondaryText
                    font.pixelSize: Theme.fontSmall
                    wrapMode: Text.Wrap
                    elide: Text.ElideMiddle
                    maximumLineCount: 2
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: qsTr("Cancel")

                        Layout.fillWidth: true
                        Layout.preferredHeight: 42

                        background: Rectangle {
                            color: parent.down
                                ? Theme.primary()
                                : Theme.surface

                            radius: 6
                            border.color: Theme.primary()
                            border.width: 1
                        }

                        contentItem: Text {
                            text: parent.text
                            color: parent.down
                                ? "white"
                                : Theme.text

                            font.pixelSize: Theme.fontSmall
                            font.bold: true

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: replaceDialog.close()
                    }

                    Button {
                        id: replaceButton

                        text: qsTr("Replace Database")
                        enabled: replaceInput.text === "REPLACE"

                        Layout.fillWidth: true
                        Layout.preferredHeight: 42

                        background: Rectangle {
                            color: parent.enabled
                                ? (parent.down
                                    ? Theme.error()
                                    : Theme.surface)
                                : Theme.background

                            radius: 6
                            border.color: parent.enabled ? Theme.error() : Qt.rgba(
                                Theme.error().r,
                                Theme.error().g,
                                Theme.error().b,
                                0.5
                            )
                            border.width: 1
                        }

                        contentItem: Text {
                            text: parent.text

                            color: parent.enabled
                                ? (parent.down ? "white" : Theme.error())
                                : Theme.secondaryText

                            font.pixelSize: Theme.fontSmall
                            font.bold: true

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            let success = DatabaseService.replaceDatabase(root.currentPath)

                            if (success) {
                                replaceDialog.close()
                                SetupService.restartApp()
                            }
                        }
                    }
                }
            }

            onOpened: {
                replaceInput.clear()
                replaceInput.forceActiveFocus()
            }
        }
    }

    Text {
        text: "v0.3.0-dev"
        font.pixelSize: Theme.fontSmall
        color: "#aaaaaa"

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 12
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        z: -1
    }
}
