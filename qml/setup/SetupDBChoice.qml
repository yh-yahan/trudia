import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import trudia.Theme 1.0

Item {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        width: 450
        spacing: 16

        Text {
            text: qsTr("Set up Trudia")
            font.pixelSize: Theme.fontLarge
            font.bold: true
            color: Theme.text
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            text: qsTr(
                "Choose how you would like to set up your database."
            )

            color: Theme.secondaryText
            font.pixelSize: Theme.fontNormal
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item {
            Layout.preferredHeight: 8
        }

        Button {
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
