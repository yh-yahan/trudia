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

    Component.onCompleted: {
        let docsUrl = StandardPaths.writableLocation(StandardPaths.DocumentsLocation);

        let path = docsUrl.toString();

        if (path.startsWith("file:///"))
            path = path.substring(8);
        else if (path.startsWith("file://"))
            path = path.substring(7);

        root.selectedPath = path + "/TrudiaPOS/data";
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: 450
        spacing: 16

        Text {
            text: qsTr("Choose database location")
            font.pixelSize: Theme.fontLarge
            font.bold: true
            color: Theme.text
            wrapMode: Text.WordWrap
        }

        Text {
            text: qsTr("Select where the database file will be stored.")
            color: Theme.secondaryText
            font.pixelSize: Theme.fontNormal
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: pathField
                text: root.selectedPath
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
                onClicked: folderDialog.open()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: qsTr("Done")
                Layout.fillWidth: true
                enabled: root.selectedPath.length > 0 && !running

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
                    text: qsTr("Done")
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
                    errorText = "";
                    running = true;

                    let fullPath = root.selectedPath + "/Trudia.db";

                    let success = SetupService.initializeSystem(fullPath);

                    if (!success) {
                        running = false;
                        errorText = qsTr("Setup failed. Please try again.");
                        return;
                    }

                    Qt.callLater(function () {
                        SetupService.restartApp();
                    });
                }
            }
        }

        Text {
            text: running ? qsTr("Setting up...") : errorText
            color: running ? "lightgray" : "red"
            visible: running || errorText.length > 0
            wrapMode: Text.WordWrap
            Layout.topMargin: 8
            font.pixelSize: Theme.fontNormal
        }
    }

    Text {
        text: "v0.2.1-dev"
        font.pixelSize: Theme.fontSmall
        color: "#aaaaaa"

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 12
    }

    FolderDialog {
        id: folderDialog
        title: qsTr("Select Database Folder")

        onAccepted: {
            if (folderDialog.selectedFolder) {
                let url = folderDialog.selectedFolder.toString();

                if (url.startsWith("file:///"))
                    root.selectedPath = url.substring(8);
                else if (url.startsWith("file://"))
                    root.selectedPath = url.substring(7);
                else
                    root.selectedPath = url;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        z: -1
    }
}
