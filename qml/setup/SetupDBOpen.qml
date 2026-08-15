import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    id: root

    property string selectedPath: ""
    property bool running: false
    property string errorText: ""

    Button {
        id: backButton

        anchors {
            top: parent.top
            left: parent.left
            topMargin: 16
            leftMargin: 16
        }

        text: qsTr("Back")
        enabled: !root.running

        background: Rectangle {
            color: "transparent"
        }

        contentItem: Text {
            text: qsTr("Back")
            color: Theme.secondaryText
            font.pixelSize: Theme.fontNormal
            verticalAlignment: Text.AlignVCenter
        }

        hoverEnabled: false
        focusPolicy: Qt.NoFocus

        onClicked: stackView.pop()
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: 450
        spacing: 16

        Text {
            text: qsTr("Open Existing Database")
            font.pixelSize: Theme.fontLarge
            font.bold: true
            color: Theme.text
            wrapMode: Text.WordWrap
        }

        Text {
            text: qsTr(
                "Select an existing Trudia database to use."
            )

            color: Theme.secondaryText
            font.pixelSize: Theme.fontNormal
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: pathField

                text: root.selectedPath
                placeholderText: qsTr("No database selected")
                readOnly: true
                Layout.fillWidth: true
                font.pixelSize: Theme.fontNormal

                leftPadding: 5
                rightPadding: 5
                topPadding: 5
                bottomPadding: 5
            }

            Button {
                text: qsTr("Browse")

                background: Rectangle {
                    color: "#6c8cff"
                    radius: 2
                }

                contentItem: Text {
                    text: qsTr("Browse")
                    font.bold: true
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: Theme.fontNormal
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus

                onClicked: databaseDialog.open()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: qsTr("Open Database")
                Layout.fillWidth: true
                enabled: root.selectedPath.length > 0
                         && !root.running

                leftPadding: 8
                rightPadding: 8
                topPadding: 8
                bottomPadding: 8
                Layout.topMargin: 8

                background: Rectangle {
                    color: Theme.primary()
                    radius: 4
                }

                contentItem: Text {
                    text: qsTr("Open Database")
                    font.bold: true
                    anchors.centerIn: parent
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontNormal
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus

                onClicked: {
                        root.errorText = ""
                        root.running = true

                        let success = DatabaseService.openDatabase(root.selectedPath)

                        if (!success) {
                            root.running = false
                            root.errorText = qsTr(
                                "The selected file could not be opened as a Trudia database."
                            )
                            return
                        }

                        Qt.callLater(function () {
                            SetupService.restartApp()
                        })
                }
            }
        }

        Text {
            text: root.running
                  ? qsTr("Opening database...")
                  : root.errorText

            color: root.running ? "lightgray" : "red"
            visible: root.running || root.errorText.length > 0
            wrapMode: Text.WordWrap
            Layout.topMargin: 8
            Layout.fillWidth: true
            font.pixelSize: Theme.fontNormal
        }
    }

    Text {
        text: "v0.3.0"
        font.pixelSize: Theme.fontSmall
        color: "#aaaaaa"

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 12
    }

    FileDialog {
        id: databaseDialog

        title: qsTr("Select Trudia Database")

        nameFilters: [
            qsTr("Trudia Database (*.db)"),
            qsTr("All Files (*)")
        ]

        onAccepted: {
            if (!databaseDialog.selectedFile)
                return

            let url = databaseDialog.selectedFile.toString()

            if (url.startsWith("file:///"))
                root.selectedPath = url.substring(8)
            else if (url.startsWith("file://"))
                root.selectedPath = url.substring(7)
            else
                root.selectedPath = url
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        z: -1
    }
}
