import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.15
import Xeno.Services 1.0

Window {
    width: 850
    height: 480
    visible: true
    title: qsTr("Xeno")

    Rectangle {
        anchors.fill: parent
        color: "#181818"

        StackView {
            id: stackView
            anchors.fill: parent
        }
    }

    Component.onCompleted: {
        let state = AppService.determineState()

        switch (state) {
        case AppService.NeedsSetup:
            stackView.push("setup/SetupDBLocation.qml")
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
