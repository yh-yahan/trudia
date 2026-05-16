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

            property var metadata: model.metadata
                ? JSON.parse(model.metadata)
                : {}

            x: model.x ?? 0
            y: model.y ?? 0

            width: model.width ?? 80
            height: model.height ?? 80

            rotation: model.rotation ?? 0

            opacity: 1.0
            z: model.z_order ?? 0

            capacity: metadata.capacity ?? 4

            label: model.label ?? ""

            color: {
                switch (metadata.status) {
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

            borderColor: root.selectedTableId === metadata.table_id
                         ? Theme.primary()
                         : "#555555"

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.tableSelected(metadata.table_id)
                }
            }
        }
    }
}
