import QtQuick
import QtQuick.Layouts

Item {
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        AdminSettingsTabs {
            id: settingsSidebar
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            Layout.maximumHeight: 56
        }

        Loader {
            id: pageLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: loadPage(settingsSidebar.selectedIndex)

    Connections {
        target: settingsSidebar
        function onSelectionChanged() {
            handleSelectionChanged(settingsSidebar.selectedIndex)
        }
    }

    function handleSelectionChanged(index) {
        loadPage(index)
    }

    function loadPage(index) {
        if (index === 0) {
            pageLoader.sourceComponent = storeSettingsPage
        } else if (index === 1) {
            pageLoader.sourceComponent = tableSettingsPage
        } else if (index === 2) {
            pageLoader.sourceComponent = printerSettingsPage
        } else if (index === 3) {
            pageLoader.sourceComponent = taxSettingsPage
        } else if (index === 4) {
            pageLoader.sourceComponent = membershipSettingsPage
        } else if (index === 5) {
            pageLoader.sourceComponent = kitchenSettingsPage
        } else if (index === 6) {
            pageLoader.sourceComponent = regionalSettingsPage
        } else if (index === 7) {
            pageLoader.sourceComponent = databaseSettingsPage
        }
    }

    Component {
        id: storeSettingsPage
        AdminStoreSettings {}
    }

    Component {
        id: tableSettingsPage
        AdminTableSettings {}
    }

    Component {
        id: printerSettingsPage
        AdminPrinterSettings {}
    }

    Component {
        id: taxSettingsPage
        AdminTaxSettings {}
    }

    Component {
        id: membershipSettingsPage
        AdminMembershipSettings {}
    }

    Component {
        id: kitchenSettingsPage
        AdminKitchenSettings {}
    }

    Component {
        id: regionalSettingsPage
        AdminRegionalSettings {}
    }

    Component {
        id: databaseSettingsPage
        AdminDatabaseSettings {}
    }
}
