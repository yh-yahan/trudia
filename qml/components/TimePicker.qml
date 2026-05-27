import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import trudia.Theme 1.0

Item {
    id: root

    property int startHour: 9
    property int endHour: 22
    property int minuteStep: 15

    property int hour: startHour + hourPicker.currentIndex
    property int minute: minutePicker.currentIndex * minuteStep

    property bool restrictPastTimeToday: false

    signal timeChanged(int hour, int minute)

    width: 260
    height: 160

    readonly property int totalHours: endHour - startHour + 1

    RowLayout {
        anchors.centerIn: parent
        spacing: 12

        Tumbler {
            id: hourPicker
            model: root.totalHours
            visibleItemCount: 5
            wrap: false

            background: Rectangle {
                color: Theme.surface
                radius: 6
                border.color: Theme.border
                border.width: 1
            }

            delegate: Label {
                required property int index
                required property var modelData

                text: (root.startHour + index).toString().padStart(2, "0")

                color: Theme.text
                font.pixelSize: Theme.fontNormal

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                opacity: 1.0 - Math.abs(Tumbler.displacement) * 0.6
                scale: 1.0 - Math.abs(Tumbler.displacement) * 0.12

                height: 48
            }

            onCurrentIndexChanged: root.timeChanged(root.hour, root.minute)
        }

        Label {
            text: ":"
            color: Theme.text
            font.pixelSize: 32
            Layout.alignment: Qt.AlignVCenter
            opacity: 0.9
        }

        Tumbler {
            id: minutePicker
            model: Math.floor(60 / root.minuteStep)
            visibleItemCount: 5
            wrap: false

            background: Rectangle {
                color: Theme.surface
                radius: 6
                border.color: Theme.border
                border.width: 1
            }

            delegate: Label {
                required property int index
                required property var modelData

                text: (index * root.minuteStep).toString().padStart(2, "0")

                color: Theme.text
                font.pixelSize: Theme.fontNormal

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                opacity: 1.0 - Math.abs(Tumbler.displacement) * 0.6
                scale: 1.0 - Math.abs(Tumbler.displacement) * 0.12

                height: 48
            }

            onCurrentIndexChanged: root.timeChanged(root.hour, root.minute)
        }
    }

    Component.onCompleted: {
        let now = new Date()
        let currentHour = now.getHours()
        let currentMinute = now.getMinutes()

        currentMinute = Math.ceil(currentMinute / minuteStep) * minuteStep

        if (currentMinute >= 60) {
            currentMinute = 0
            currentHour += 1
        }

        currentHour = Math.max(startHour, Math.min(endHour, currentHour))

        hourPicker.currentIndex = currentHour - startHour
        minutePicker.currentIndex = Math.floor(currentMinute / minuteStep)
    }
}
