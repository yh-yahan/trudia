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
        if (AuthService.isFirstAdminSetupNeeded()) {
            stackView.push("auth/FirstAdminRegister.qml")
        } else {
            stackView.push("auth/Login.qml")
        }
    }
}
