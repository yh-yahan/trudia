import QtQuick
import QtQuick.Layouts

Item {
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        spacing: 0

        AdminSidebar {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#121212"

            AdminMenuManagement {
                Layout.fillHeight: true
                anchors.fill: parent
            }
        }
    }
}
