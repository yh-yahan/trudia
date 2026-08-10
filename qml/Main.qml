import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.15
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

    Component.onCompleted: {
        let state = AppService.determineState()

        switch (state) {
        case AppService.NeedsSetup:
            stackView.push("setup/SetupDBChoice.qml")
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
