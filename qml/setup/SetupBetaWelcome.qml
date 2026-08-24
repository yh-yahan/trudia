import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    id: root

    property bool submitting: false

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: 420
        spacing: 18

        Text {
            text: qsTr("Thanks for setting up Trudia")
            font.pixelSize: Theme.fontXL
            font.bold: true
            color: Theme.text
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            text: qsTr("This is an early beta. If you'd like updates, leave your email below.")
            color: Theme.secondaryText
            font.pixelSize: Theme.fontNormal
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            lineHeight: 1.3
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Label {
                text: qsTr("Name / Business (optional)")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            TextField {
                id: nameField
                placeholderText: qsTr("e.g. Alice’s Cafe")
                Layout.fillWidth: true
                font.pixelSize: Theme.fontNormal
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Label {
                text: qsTr("Email (optional)")
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            TextField {
                id: emailField
                placeholderText: qsTr("email@example.com")
                Layout.fillWidth: true
                font.pixelSize: Theme.fontNormal
                leftPadding: 10
                rightPadding: 10
                topPadding: 10
                bottomPadding: 10
                inputMethodHints: Qt.ImhEmailCharactersOnly
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 16
            spacing: 14

            Button {
                text: submitting ? qsTr("Sending...") : qsTr("Continue")
                Layout.fillWidth: true
                enabled: !submitting

                leftPadding: 12
                rightPadding: 12
                topPadding: 12
                bottomPadding: 12

                background: Rectangle {
                    color: Theme.primary()
                    radius: 4
                }

                contentItem: Text {
                    text: submitting ? qsTr("Sending...") : qsTr("Continue")
                    font.bold: true
                    font.pixelSize: Theme.fontNormal
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus

                onClicked: {
                    const name = nameField.text.trim()
                    const email = emailField.text.trim()

                    if (email.length > 0) {
                        submitting = true
                        BetaService.submitBetaInfo(name, email)
                    } else {
                        goToApp()
                    }
                }
            }

            Button {
                text: qsTr("Skip for now")
                Layout.alignment: Qt.AlignHCenter
                enabled: !submitting

                flat: true
                background: null
                padding: 4

                contentItem: Text {
                    text: qsTr("Skip for now")
                    font.pixelSize: Theme.fontSmall
                    color: Theme.secondaryText
                    horizontalAlignment: Text.AlignHCenter
                    font.underline: true
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus

                onClicked: {
                    goToApp()
                }
            }
        }

    }

    Text {
        text: "v0.4.0-dev"
        font.pixelSize: Theme.fontSmall
        color: "#aaaaaa"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 12
    }

    Connections {
        target: BetaService

        function onSubmitFinished(success) {
            submitting = false
            goToApp()
        }
    }

    function goToApp() {
        stackView.push("../admin/AdminHome.qml")
        appWindow.showMaximized()
    }
}
