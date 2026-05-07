import QtQuick
import QtQuick.Controls
import trudia.Theme 1.0

Item {
    id: root

    property string label: ""
    property color borderColor: "black"
    property color color: "#3a7fff"

    property int capacity: 4

    property var meta: model.metadata ? JSON.parse(model.metadata) : {}
    property string tableType: meta.table_type ?? "square"

    signal moved(real x, real y)

    width: model.width ?? 80
    height: model.height ?? 80

    Loader {
        anchors.fill: parent
        sourceComponent: getShapeComponent(tableType)
    }

    function getShapeComponent(type) {
        if (type === "circle")
            return circleShape;
        if (type === "rectangle")
            return rectangleShape;
        return squareShape;
    }

    Component {
        id: squareShape

        Rectangle {
            anchors.fill: parent
            color: root.color
            border.width: 2
            border.color: root.borderColor
            radius: 6
        }
    }

    Component {
        id: rectangleShape

        Rectangle {
            anchors.fill: parent
            color: root.color
            border.width: 2
            border.color: root.borderColor
            radius: 3
        }
    }

    Component {
        id: circleShape

        Rectangle {
            anchors.fill: parent
            color: root.color
            border.width: 2
            border.color: root.borderColor
            radius: width / 2
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.label
        color: "#9c9c9c"
        font.bold: true
    }

    MouseArea {
        anchors.fill: parent
        drag.target: root
        cursorShape: Qt.DragMoveCursor

        onPositionChanged: {
            if (drag.active) {
                root.moved(root.x, root.y)
            }
        }

        onReleased: {
            root.moved(root.x, root.y)
        }
    }

    Repeater {
        model: capacity

        delegate: Rectangle {
            width: 12
            height: 12
            radius: 6
            color: "#cccccc"

            property real spacing: 20

            property real centerX: root.width / 2
            property real centerY: root.height / 2

            property real angle: (index / capacity) * 2 * Math.PI
            property real circleRadius: Math.max(root.width, root.height) / 2 + spacing

            property int side: Math.floor(index / Math.ceil(capacity / 4))
            property int perSide: Math.ceil(capacity / 4)
            property int posOnSide: index % perSide

            property real t: (posOnSide + 1) / (perSide + 1)

            visible: true

            x: {
                if (root.tableType === "circle") {
                    return centerX + Math.cos(angle) * circleRadius - width / 2;
                }

                if (side === 0)
                    return t * root.width - width / 2;
                if (side === 1)
                    return root.width + spacing - width / 2;
                if (side === 2)
                    return (1 - t) * root.width - width / 2;
                if (side === 3)
                    return -spacing - width / 2;
            }

            y: {
                if (root.tableType === "circle") {
                    return centerY + Math.sin(angle) * circleRadius - height / 2;
                }

                if (side === 0)
                    return -spacing - height / 2;
                if (side === 1)
                    return t * root.height - height / 2;
                if (side === 2)
                    return root.height + spacing - height / 2;
                if (side === 3)
                    return (1 - t) * root.height - height / 2;
            }
        }
    }
}
