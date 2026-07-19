import QtQuick
import QtQuick.Layouts
import Trudia.Services 1.0

Item {
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        spacing: 0

        AdminManagementSidebar {
            id: managementSidebar
            Layout.preferredWidth: 150
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
        function onSelectionChanged() {
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

            if (SettingService.tableLayoutMode === "floor_plan") {
                pageLoader.sourceComponent = floorPlan
            } else {
                pageLoader.sourceComponent = table
            }
        } else if (index === 2) {
            pageLoader.sourceComponent = user
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

    Component {
        id: user
        AdminUserManagement {}
    }

    Component {
        id: floorPlan
        AdminFloorPlanManagement {}
    }
}
