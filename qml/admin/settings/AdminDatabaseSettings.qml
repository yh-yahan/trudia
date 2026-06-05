import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Trudia.Services 1.0
import trudia.Theme 1.0

ScrollView {
    id: root

    property string selectedFolder: ""
    property string destinationPreview: ""

    property string errorMessage: ""
    property string successMessage: ""

    property bool moveInProgress: false

    readonly property string currentDatabasePath: AppService.databasePath()

    anchors.fill: parent
    contentWidth: parent.width
    clip: true

    function moveDatabase() {
        errorMessage = ""
        successMessage = ""

        moveInProgress = true

        let success = DatabaseService.moveDatabase(selectedFolder)

        moveInProgress = false

        if (success) {
            successMessage = qsTr("Database moved successfully.")
            SetupService.restartApp();
        } else {
            errorMessage = qsTr("Failed to move database.")
        }
    }

    function backupDatabase() {
        errorMessage = ""
        successMessage = ""

        let success = DatabaseService.backupDatabase()

        if (success) {
            successMessage = qsTr("Database backup created successfully.")
        } else {
            errorMessage = qsTr("Failed to create database backup.")
        }
    }

    FolderDialog {
        id: folderDialog

        title: qsTr("Select New Database Location")

        onAccepted: {
            root.selectedFolder = folderDialog.selectedFolder.toString().replace("file:///", "")

            if (root.selectedFolder === "")
                return

            let fileName = root.currentDatabasePath.split("/").pop()

            root.destinationPreview = root.selectedFolder + "/TrudiaPOS/data/" + fileName

            moveDatabaseDialog.open()
        }
    }

    Dialog {
        id: moveDatabaseDialog

        anchors.centerIn: Overlay.overlay
        modal: true
        width: 650
        height: 360

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            Text {
                text: qsTr("Move Database")
                font.bold: true
                font.pixelSize: Theme.fontLarge
                color: Theme.text
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("The database will be moved from its current location to the following location:")
                wrapMode: Text.WordWrap
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            Item { Layout.preferredHeight: 8 }

            Label {
                text: qsTr("Current Location")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                color: Theme.surface
                radius: 4

                Text {
                    anchors.fill: parent
                    anchors.margins: 10

                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle

                    color: Theme.text
                    font.pixelSize: Theme.fontNormal

                    text: root.currentDatabasePath
                }
            }

            Label {
                text: qsTr("New Location")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                color: Theme.surface
                radius: 4

                Text {
                    anchors.fill: parent
                    anchors.margins: 10

                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle

                    color: Theme.text
                    font.pixelSize: Theme.fontNormal

                    text: root.destinationPreview
                }
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("App will restart after moving.")
                wrapMode: Text.WordWrap
                color: Theme.secondaryText
                font.pixelSize: Theme.fontNormal
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                Button {
                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5

                    background: Rectangle {
                        color: Theme.primary()
                        radius: 4
                    }

                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus

                    contentItem: Text {
                        text: qsTr("Move Database")
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontNormal
                    }

                    onClicked: {
                        root.moveDatabase()
                        moveDatabaseDialog.close()
                    }
                }

                Button {
                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5

                    background: Rectangle {
                        color: "#6b6b6b"
                        radius: 4
                    }

                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus

                    contentItem: Text {
                        text: qsTr("Cancel")
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontNormal
                    }

                    onClicked: moveDatabaseDialog.close()
                }
            }
        }

        background: Rectangle {
            color: Theme.background
            radius: 6
        }
    }

    ColumnLayout {
        width: parent.width
        spacing: 30

        Label {
            text: qsTr("Database Settings")
            font.pixelSize: Theme.fontLarge
            font.bold: true
            color: Theme.text
        }

        ColumnLayout {
            spacing: 15

            Text {
                text: qsTr("Current Database")
                font.bold: true
                color: Theme.secondaryText
                font.pixelSize: Theme.fontNormal
            }

            ColumnLayout {
                spacing: 15

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                Rectangle {
                    Layout.preferredWidth: 700
                    Layout.preferredHeight: 50

                    radius: 4
                    color: Theme.background

                    Text {
                        anchors.fill: parent
                        anchors.margins: 10

                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideMiddle

                        color: Theme.text
                        font.pixelSize: Theme.fontNormal

                        text: root.currentDatabasePath
                    }
                }

                Text {
                    text: qsTr("This database contains restaurant information, orders, memberships, tables, reservations, application settings and other operational data.")

                    wrapMode: Text.WordWrap
                    color: Theme.secondaryText
                    font.pixelSize: Theme.fontNormal

                    Layout.preferredWidth: 650
                }
            }
        }

        ColumnLayout {
            spacing: 15

            Text {
                text: qsTr("Database Management")
                font.bold: true
                color: Theme.secondaryText
                font.pixelSize: Theme.fontNormal
            }

            Text {
                text: qsTr("Backups are stored in a 'backups' folder next to the database file.")
                wrapMode: Text.WordWrap
                color: Theme.secondaryText
                font.pixelSize: Theme.fontNormal

                Layout.preferredWidth: 650
            }

            ColumnLayout {
                spacing: 15

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                RowLayout {
                    spacing: 8

                    Button {
                        text: qsTr("Backup Database")

                        enabled: !root.moveInProgress

                        leftPadding: 20
                        rightPadding: 20
                        topPadding: 10
                        bottomPadding: 10

                        background: Rectangle {
                            color: "#4faba1"
                            radius: 4
                        }

                        contentItem: Text {
                            text: qsTr("Backup Database")
                            font.bold: true
                            anchors.centerIn: parent
                            color: "white"
                            font.pixelSize: Theme.fontNormal
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            root.backupDatabase()
                        }
                    }

                    Button {
                        text: qsTr("Move Database")

                        enabled: !root.moveInProgress

                        leftPadding: 20
                        rightPadding: 20
                        topPadding: 10
                        bottomPadding: 10

                        background: Rectangle {
                            color: "#5F7DDC"
                            radius: 4
                        }

                        contentItem: Text {
                            text: qsTr("Move Database")
                            font.bold: true
                            anchors.centerIn: parent
                            color: "white"
                            font.pixelSize: Theme.fontNormal
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            root.errorMessage = ""
                            root.successMessage = ""

                            folderDialog.open()
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    background: Rectangle {
        color: Theme.background
    }

    RowLayout {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 20

        spacing: 10

        Text {
            visible: root.errorMessage !== ""

            text: root.errorMessage
            color: "red"
            font.bold: true

            wrapMode: Text.WordWrap
            Layout.fillWidth: true

            font.pixelSize: Theme.fontNormal
        }

        Text {
            visible: root.successMessage !== ""

            text: root.successMessage
            color: "green"
            font.bold: true

            wrapMode: Text.WordWrap
            Layout.fillWidth: true

            font.pixelSize: Theme.fontNormal
        }
    }
}
