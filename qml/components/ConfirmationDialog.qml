import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: confirmDialog

    width: 360
    height: 180
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose
    anchors.centerIn: Overlay.overlay

    property string title: qsTr("Confirm")
    property string message: qsTr("Are you sure?")
    property var confirmCallback: null

    background: Rectangle {
        color: "#1f1f1f"
        radius: 8
        border.color: "#2a2a2a"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: confirmDialog.title
            font.pixelSize: 18
            font.bold: true
            color: "white"
        }

        Text {
            text: confirmDialog.message
            color: "#d0d0d0"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Button {
                text: qsTr("Cancel")

                background: Rectangle {
                    color: "#2b2b2b"
                    radius: 4
                }

                contentItem: Text {
                    text: qsTr("Cancel")
                    color: "white"
                    anchors.centerIn: parent
                }

                onClicked: {
                    confirmDialog.close()
                    if (confirmDialog.confirmCallback)
                        confirmDialog.confirmCallback(false)
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus
            }

            Button {
                text: qsTr("Delete")

                background: Rectangle {
                    color: "#e53935"
                    radius: 4
                }

                contentItem: Text {
                    text: qsTr("Delete")
                    color: "white"
                    anchors.centerIn: parent
                    font.bold: true
                }

                onClicked: {
                    confirmDialog.close()
                    if (confirmDialog.confirmCallback)
                        confirmDialog.confirmCallback(true)
                }

                hoverEnabled: false
                focusPolicy: Qt.NoFocus
            }
        }
    }

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 120
        }
        NumberAnimation {
            property: "scale"
            from: 0.95
            to: 1
            duration: 120
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 100
        }
    }
}
