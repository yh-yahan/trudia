import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import trudia.Theme 1.0

Item {
    id: root

    property date selectedDate: new Date()
    property alias placeholderText: textField.placeholderText

    implicitWidth: 300
    implicitHeight: 50

    function getMaxDate() {
        var d = new Date()
        d.setFullYear(d.getFullYear() + 2, 11, 31)
        return d
    }

    function formatDisplayDate() {
        return Qt.formatDate(root.selectedDate, "dd MMM yyyy")
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        TextField {
            id: textField
            Layout.fillWidth: true
            readOnly: true
            text: formatDisplayDate()
            font.pointSize: 14

            MouseArea {
                anchors.fill: parent
                onClicked: popup.open()
            }
        }

        Button {
            text: "📅"
            font.pixelSize: 18
            onClicked: popup.open()
        }
    }

    Popup {
        id: popup
        width: 340
        height: 420
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        x: (root.width - width) / 2
        y: root.height + 5

        background: Rectangle {
            color: Theme.surface
            radius: 12
            border.color: Theme.border
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                Button {
                    text: "<"
                    flat: true
                    onClicked: changeMonth(-1)
                    contentItem: Text {
                        text: "<"
                        font.pixelSize: 20
                        color: Theme.text
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Label {
                    text: Qt.formatDate(calendar.currentDate, "MMMM yyyy")
                    font.bold: true
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.text
                }

                Button {
                    text: ">"
                    flat: true
                    onClicked: changeMonth(1)
                    contentItem: Text {
                        text: ">"
                        font.pixelSize: 20
                        color: Theme.text
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Repeater {
                    model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                    delegate: Text {
                        text: modelData
                        font.bold: true
                        color: Theme.secondaryText
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }
                }
            }

            GridLayout {
                columns: 7
                rowSpacing: 4
                columnSpacing: 4
                Layout.fillWidth: true
                Layout.fillHeight: true

                Repeater {
                    model: 42

                    delegate: Rectangle {
                        id: dayRect
                        width: 40
                        height: 40
                        radius: 6

                        property var thisDate: getDateForIndex(index)
                        property bool isCurrentMonth: thisDate.getMonth(
                                                          ) === calendar.currentDate.getMonth()
                        property bool isToday: isSameDate(thisDate, new Date())
                        property bool isSelected: isSameDate(thisDate,
                                                             root.selectedDate)
                        property bool isPast: thisDate < new Date(new Date().setHours(
                                                                      0, 0, 0,
                                                                      0))
                        property bool isFutureAllowed: thisDate <= root.getMaxDate()

                        color: {
                            if (isSelected)
                                return Theme.primary
                            if (isToday)
                                return Theme.surface
                            return isCurrentMonth ? "transparent" : Theme.surface
                        }

                        border.color: isSelected ? Theme.primary : "transparent"
                        border.width: 2

                        enabled: !isPast && isFutureAllowed && isCurrentMonth

                        Text {
                            anchors.centerIn: parent
                            text: dayRect.thisDate.getDate()

                            color: {
                                if (!dayRect.isCurrentMonth)
                                    return Theme.secondaryText
                                if (dayRect.isPast || !dayRect.isFutureAllowed)
                                    return Theme.secondaryText
                                return dayRect.isSelected ? "white" : Theme.text
                            }

                            font.bold: dayRect.isToday || dayRect.isSelected
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: dayRect.enabled

                            onClicked: {
                                root.selectedDate = dayRect.thisDate
                                popup.close()
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    text: "Today"
                    onClicked: {
                        root.selectedDate = new Date()
                        calendar.currentDate = new Date()
                        popup.close()
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "Cancel"
                    onClicked: popup.close()
                }
            }
        }
    }

    QtObject {
        id: calendar
        property date currentDate: new Date()
    }

    function changeMonth(delta) {
        var d = new Date(calendar.currentDate)
        d.setMonth(d.getMonth() + delta)
        calendar.currentDate = d
    }

    function getDateForIndex(index) {
        var firstDay = new Date(calendar.currentDate.getFullYear(),
                                calendar.currentDate.getMonth(), 1)
        var startDay = firstDay.getDay()

        var date = new Date(firstDay)
        date.setDate(date.getDate() - startDay + index)
        return date
    }

    function isSameDate(date1, date2) {
        return date1.getFullYear() === date2.getFullYear() && date1.getMonth(
                    ) === date2.getMonth() && date1.getDate(
                    ) === date2.getDate()
    }
}
