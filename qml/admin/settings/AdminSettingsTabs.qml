import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import trudia.Theme 1.0

Rectangle {
    id: root

    property int selectedIndex: 0
    property int membershipIndex: 4

    signal selectionChanged(int index)

    color: Theme.background
    implicitHeight: 56

    ListModel {
        id: buttonModel
    }

    function populateModel() {
        const savedIndex = root.selectedIndex
        buttonModel.clear()
        buttonModel.append({ "text": qsTr("Restaurant") })
        buttonModel.append({ "text": qsTr("Tables") })
        buttonModel.append({ "text": qsTr("Printer") })
        buttonModel.append({ "text": qsTr("Tax") })
        buttonModel.append({ "text": qsTr("Membership") })
        buttonModel.append({ "text": qsTr("Kitchen") })
        buttonModel.append({ "text": qsTr("Region & Formats") })
        buttonModel.append({ "text": qsTr("Database") })
        if (savedIndex >= 0 && savedIndex < buttonModel.count)
            root.selectedIndex = savedIndex
    }

    Component.onCompleted: populateModel()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Flickable {
            id: tabFlick
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            contentWidth: Math.max(width, tabRow.implicitWidth)
            contentHeight: height

            Row {
                id: tabRow
                height: tabFlick.height
                leftPadding: 12
                rightPadding: 12
                topPadding: 8
                bottomPadding: 8
                spacing: 6

                Repeater {
                    model: buttonModel

                    delegate: Button {
                        id: tabButton
                        height: tabRow.height - tabRow.topPadding - tabRow.bottomPadding
                        width: Math.max(110, (tabFlick.width - 24 - (buttonModel.count - 1) * tabRow.spacing) / Math.max(buttonModel.count, 1))

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        background: Rectangle {
                            radius: 6
                            color: root.selectedIndex === index ? Theme.primary() : Theme.surface
                        }

                        contentItem: Text {
                            text: model.text
                            color: root.selectedIndex === index ? "white" : Theme.text
                            font.bold: true
                            font.family: "Arial"
                            font.pixelSize: Theme.fontNormal
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            root.selectedIndex = index
                            root.selectionChanged(index)
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.border
        }
    }
}
