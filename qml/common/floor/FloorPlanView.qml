import QtQuick
import QtQuick.Controls
import trudia.Theme 1.0

Item {
    id: root

    property var model
    property int selectedTableId: -1

    signal tableSelected(int tableId)

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    Repeater {
        model: root.model

        delegate: FloorItem {
            id: tableItem

            x: model.x ?? 0
            y: model.y ?? 0

            capacity: model.capacity ?? 4

            width: model.width ?? 80
            height: model.height ?? 80

            rotation: model.rotation ?? 0

            label: model.label ?? ""

            color: Theme.surface

            borderColor: root.selectedTableId === model.id
                         ? Theme.primary()
                         : "#555555"

            opacity: 1.0
            z: model.z_order ?? 0

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.tableSelected(model.id)
                }
            }
        }
    }
}
