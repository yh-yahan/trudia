import QtQuick
import QtQuick.Layouts
import "./settings"
import "./management"
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
            pageLoader.sourceComponent = checkoutPage
        } else if (index === 2) {
            pageLoader.sourceComponent = kitchenPage
        } else if (index === 3) {
            pageLoader.sourceComponent = managementPage
        } else if (index === 4) {
            pageLoader.sourceComponent = settingsPage
        }
    }

    Component {
        id: orderTakingPage
        OrderTaking {}
    }

    Component {
        id: checkoutPage
        Checkout {}
    }

    Component {
        id: kitchenPage
        KitchenOrders {}
    }

    Component {
        id: managementPage
        AdminManagement {}
    }

    Component {
        id: settingsPage
        AdminSettings {}
    }
}
