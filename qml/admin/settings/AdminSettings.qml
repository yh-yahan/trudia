import QtQuick
import QtQuick.Layouts

Item {
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        spacing: 0

        AdminSettingsSidebar {
            id: settingsSidebar
            Layout.preferredWidth: 220
            Layout.fillHeight: true
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
        onSelectionChanged: {
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
            pageLoader.sourceComponent = printerSettingsPage
        } else if (index === 2) {
            pageLoader.sourceComponent = taxSettingsPage
        } else if (index === 3) {
            pageLoader.sourceComponent = membershipSettingsPage
        }
    }

    Component {
        id: storeSettingsPage
        AdminStoreSettings {}
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
}
