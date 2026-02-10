import QtQuick
import QtQuick.Layouts
import "../common"

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
        onSelectionChanged: {
            handleSelectionChanged(sidebar.selectedIndex)
        }
    }

    function handleSelectionChanged(index) {
        loadPage(index)
    }

    function loadPage(index) {
        if (index === 0) {
            pageLoader.sourceComponent = orderTakingPage
        } else if (index === 1) {
            pageLoader.sourceComponent = kitchenPage
        } else if (index === 2) {
            pageLoader.sourceComponent = menuManagementPage
        } else if (index === 3) {
            pageLoader.sourceComponent = tableManagementPage
        }
    }

    Component {
        id: orderTakingPage
        OrderTaking {}
    }

    Component {
        id: kitchenPage
        KitchenOrders {}
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
