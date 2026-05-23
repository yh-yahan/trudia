import QtQuick
import QtQuick.Controls
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    id: root

    property var model
    property int selectedIndex: -1

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    Repeater {
        model: root.model

        delegate: FloorItem {
            id: itemDelegate

            metadata: model.metadata
                ? JSON.parse(model.metadata)
                : {}

            x: model.x ?? 0
            y: model.y ?? 0

            type: model.type ?? "table"

            width: model.width ?? 80
            height: model.height ?? 80

            rotation: model.rotation ?? 0

            opacity: model.opacity ?? 1.0
            z: model.z_order ?? 0

            capacity: model.capacity ?? 4

            label: model.label ?? ""

            color: {
                switch (model.status) {
                case "occupied":
                    return "#e74c3c"
                case "reserved":
                    return "#f39c12"
                case "available":
                    return '#66BB6A'
                default:
                    return Theme.surface
                }
            }

            borderColor: root.selectedIndex === index
                         ? Theme.primary()
                         : "#555555"

            onMoved: (newX, newY, newRotation) => {
                if (model) {
                    model.x = newX
                    model.y = newY
                    model.rotation = newRotation
                }
            }

            MouseArea {
                anchors.fill: parent

                drag.target: parent

                drag.minimumX: 0
                drag.minimumY: 0

                onReleased: {
                    if (model) {
                        model.x = parent.x
                        model.y = parent.y
                    }
                }
            }

            Menu {
                id: contextMenu

                MenuItem {
                    text: qsTr("Delete")

                    onTriggered: {
                        FloorPlanService.deleteItem(index)
                    }
                }
            }

            TapHandler {
                acceptedButtons: Qt.RightButton

                onTapped: {
                    root.selectedIndex = index
                    contextMenu.popup()
                }
            }
        }
    }
}
