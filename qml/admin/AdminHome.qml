import QtQuick
import QtQuick.Layouts

Item {
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        spacing: 0

        AdminSidebar {
            id: sidebar
            Layout.preferredWidth: 220
            Layout.fillHeight: true
        }

        Loader {
            id: pageLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: loadPage(sidebar.selectedIndex)

    Connections {
        target: sidebar
        onSelectionChanged: loadPage(index)
    }

    function loadPage(index) {
        if (index === 0) {
            pageLoader.sourceComponent = menuManagementPage
        } else if (index === 1) {
            pageLoader.sourceComponent = tableManagementPage
        }
    }

    Component {
        id: menuManagementPage
        AdminMenuManagement {}
    }

    Component {
        id: tableManagementPage
        AdminTableManagement {}
    }
}
