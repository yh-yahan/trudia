import QtQuick
import QtQuick.Layouts

Item {
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        spacing: 0

        AdminManagementSidebar {
            id: managementSidebar
            Layout.preferredWidth: 220
            Layout.fillHeight: true
        }

        Loader {
            id: pageLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: loadPage(managementSidebar.selectedIndex)

    Connections {
        target: managementSidebar
        onSelectionChanged: {
            handleSelectionChanged(managementSidebar.selectedIndex)
        }
    }

    function handleSelectionChanged(index) {
        loadPage(index)
    }

    function loadPage(index) {
        if (index === 0) {
            pageLoader.sourceComponent = menu
        } else if (index === 1) {
            pageLoader.sourceComponent = table
        }
    }

    Component {
        id: menu
        AdminMenuManagement {}
    }

    Component {
        id: table
        AdminTableManagement {}
    }
}
