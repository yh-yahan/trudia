import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

ScrollView {
    id: root

    property var tableData: ({})
    property string errorMessage: ""

    Component.onCompleted: {
        tableData = SettingService.getTableSettings()

        if (!tableData || Object.keys(tableData).length === 0)
            return

        layoutModeCombo.currentValue = tableData.layout_mode || "simple"
    }

    anchors.fill: parent
    contentWidth: parent.width
    clip: true

    ColumnLayout {
        width: parent.width
        spacing: 30

        Label {
            text: qsTr("Table Settings")
            font.pixelSize: Theme.fontLarge
            font.bold: true
            color: Theme.text
        }

        ColumnLayout {
            spacing: 15

            Text {
                text: qsTr("Table Layout")
                font.bold: true
                color: Theme.secondaryText
                font.pixelSize: Theme.fontNormal
            }

            ColumnLayout {
                spacing: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Layout Mode")
                        color: Theme.text
                        Layout.preferredWidth: 230
                        font.pixelSize: Theme.fontNormal
                    }

                    ComboBox {
                        id: layoutModeCombo

                        Layout.preferredWidth: 240
                        font.pixelSize: Theme.fontNormal

                        model: [
                            {
                                "value": "simple",
                                "label": qsTr("Simple Layout")
                            },
                            {
                                "value": "floor_plan",
                                "label": qsTr("Visual Floor Plan")
                            }
                        ]

                        textRole: "label"
                        valueRole: "value"
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 15
            visible: layoutModeCombo.currentValue === "floor_plan"

            ColumnLayout {
                spacing: 10
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20

                Text {
                    text: qsTr(
                              "Visual floor plans allow tables to be positioned freely and support advanced restaurant layouts.")
                    wrapMode: Text.WordWrap
                    color: Theme.secondaryText
                    font.pixelSize: Theme.fontNormal

                    Layout.preferredWidth: 500
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    background: Rectangle {
        color: Theme.background
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 20

        spacing: 10

        Button {
            text: qsTr("Save")

            width: 80

            leftPadding: 20
            rightPadding: 20
            topPadding: 10
            bottomPadding: 10

            background: Rectangle {
                color: Theme.primary()
                radius: 4
            }

            contentItem: Text {
                text: qsTr("Save")
                font.bold: true
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: Theme.fontNormal
            }

            hoverEnabled: false
            focusPolicy: Qt.NoFocus

            onClicked: {
                root.errorMessage = ""

                var payload = {}

                payload.id = tableData.id || 1
                payload.layout_mode = layoutModeCombo.currentValue

                let success = SettingService.saveTableSettings(payload)

                if (!success)
                    root.errorMessage = qsTr(
                                "Failed to save table settings.")
            }
        }

        Text {
            text: root.errorMessage
            color: "red"
            font.bold: true
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            font.pixelSize: Theme.fontNormal
        }
    }
}
