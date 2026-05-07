import QtQuick
import QtQuick.Controls
import trudia.Theme 1.0

Item {
    id: root
    property var model

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    Repeater {
        model: root.model

        delegate: FloorItem {
            id: itemDelegate

            x: model.x ?? 0
            y: model.y ?? 0
            capacity: model.capacity ?? 4
            width: model.width ?? 80
            height: model.height ?? 80
            rotation: model.rotation ?? 0
            label: model.label ?? ""
            color: model.color ?? "#3a3a3a"
            borderColor: model.border_color ?? "#555555"
            opacity: model.opacity ?? 1.0
            z: model.z_order ?? 0

            property var metadata: model.metadata ? JSON.parse(model.metadata) : {}

            onMoved: (newX, newY) => {
                if (model) {
                    model.x = newX
                    model.y = newY
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
        }
    }
}
