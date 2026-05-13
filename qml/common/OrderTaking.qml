import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0

Item {
    id: root

    Loader {
        id: orderTakingLoader
        anchors.fill: parent

        sourceComponent: SettingService.tableLayoutMode === "floor_plan"
                         ? floorPlanComponent
                         : simpleComponent
    }

    Component {
        id: simpleComponent

        OrderTakingSimple {
            anchors.fill: parent
        }
    }

    Component {
        id: floorPlanComponent

        OrderTakingFloorPlan {
            anchors.fill: parent
        }
    }
}
