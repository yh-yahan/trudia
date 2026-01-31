import QtQuick
import QtQuick.Controls

Dialog {
    id: confirmDialog
    title: "Confirm"
    standardButtons: Dialog.Ok | Dialog.Cancel
    modal: true

    contentItem: Column {
        Text {
            text: qsTr("Do you wish to continue?")
            font.pixelSize: 16
            color: "#121212"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    onAccepted: {
        if (confirmDialog.confirmCallback) {
            confirmDialog.confirmCallback(true)
        }
    }

    onRejected: {
        if (confirmDialog.confirmCallback) {
            confirmDialog.confirmCallback(false)
        }
    }

    property var confirmCallback: null
}
