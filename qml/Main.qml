import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Window {
    id: appWindow
    width: 850
    height: 520
    visible: true
    title: "Trudia"

    Rectangle {
        anchors.fill: parent
        color: Theme.background

        StackView {
            id: stackView
            anchors.fill: parent
        }
    }

    Rectangle {
        id: aboutButton

        width: 32
        height: 32

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 16
        anchors.bottomMargin: 16

        radius: 6
        color: Theme.surface
        border.color: Theme.border

        Text {
            anchors.centerIn: parent
            text: "i"
            color: Theme.secondaryText
            font.pixelSize: Theme.fontNormal
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: aboutDialog.open()
        }

        ToolTip.visible: mouseArea.containsMouse
        ToolTip.text: "About Trudia"
        ToolTip.delay: 500
    }

    Dialog {
        id: aboutDialog

        title: "About"
        modal: true
        anchors.centerIn: Overlay.overlay

        width: Math.min(500, appWindow.width - 40)
        height: Math.min(500, appWindow.height - 40)

        padding: 20

        background: Rectangle {
            color: Theme.surface
            border.color: Theme.border
            radius: 8
        }

        contentItem: Flickable {
            contentWidth: width
            contentHeight: contentColumn.implicitHeight
            clip: true

            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: 16

                Label {
                    text: "Trudia"
                    font.pixelSize: Theme.fontMedium
                    color: Theme.text
                }

                Label {
                    text: "Version 0.4.0"
                    font.pixelSize: Theme.fontSmall
                    color: Theme.secondaryText
                }

                Label {
                    text: "Copyright © 2026 Trudia"
                    font.pixelSize: Theme.fontSmall
                    color: Theme.secondaryText
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.border
                }

                Label {
                    text: "This application uses the Qt libraries under the GNU Lesser General Public License version 3 (LGPLv3)."
                    font.pixelSize: Theme.fontNormal
                    color: Theme.text
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: 'Full third-party license texts are available in THIRD_PARTY_LICENSES.txt in the application installation folder.'
                    textFormat: Text.RichText
                    font.pixelSize: Theme.fontNormal
                    color: Theme.text
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: "You may obtain the corresponding source code of the Qt libraries used in this version by contacting:"
                    font.pixelSize: Theme.fontNormal
                    color: Theme.text
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: '<a href="mailto:yahanyang46@outlook.com">yahanyang46@outlook.com</a>'
                    textFormat: Text.RichText
                    onLinkActivated: Qt.openUrlExternally(link)
                    font.pixelSize: Theme.fontNormal
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: "This offer is valid for at least 3 years from the date of distribution."
                    font.pixelSize: Theme.fontNormal
                    color: Theme.text
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        footer: DialogButtonBox {
            Button {
                text: "Close"
                font.pixelSize: Theme.fontNormal
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
        }
    }

    Component.onCompleted: {
        let state = AppService.determineState()

        switch (state) {
        case AppService.NeedsSetup:
            stackView.push("setup/SetupDBChoice.qml")
            break
        case AppService.FileNotFoundNeedsSetup:
            stackView.push("setup/SetupDBChoice.qml", { "mode": "missing" })
            break
        case AppService.UnableToOpenNeedsSetup:
        case AppService.NotTrudiaDBNeedsSetup:
            stackView.push("setup/SetupDBChoice.qml", { "mode": "unusable" })
            break
        case AppService.NeedsAdminSetup:
            stackView.push("setup/SetupAdmin.qml")
            break
        case AppService.Ready:
            stackView.push("auth/Login.qml")
            break
        default:
            stackView.push("auth/Login.qml")
            break
        }
    }
}
