import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0
import "../../components"

Item {
    width: 800
    height: 600

    ConfirmationDialog {
        id: confirmationDialog
        anchors.centerIn: parent
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: qsTr("Table Management")
            font.bold: true
            font.pixelSize: Theme.fontLarge
            color: Theme.text
        }

        Rectangle {
            Layout.fillWidth: true
            height: 36
            color: Theme.surface
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 10

                Text {
                    text: qsTr("Table Name")
                    Layout.fillWidth: true
                    color: Theme.secondaryText
                    font.bold: true
                    font.pixelSize: Theme.fontSmall
                }
                Text {
                    text: qsTr("Capacity")
                    width: 80
                    color: Theme.secondaryText
                    font.bold: true
                    font.pixelSize: Theme.fontSmall
                }
                Item {
                    width: 150
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: TableService.tableModel
            clip: true
            spacing: 4

            delegate: Rectangle {
                id: tableRect
                height: 44
                width: ListView.view.width
                radius: 4
                color: Theme.background

                property bool isEditing: false
                property string editedName: name
                property int editedCapacity: capacity
                property string originalName: name
                property int originalCapacity: capacity

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    TextField {
                        visible: tableRect.isEditing
                        text: tableRect.editedName
                        Layout.fillWidth: true
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        background: Rectangle {
                            color: Theme.background
                            radius: 4
                            border.color: Theme.border
                            border.width: 1
                        }
                        onTextChanged: tableRect.editedName = text
                        onActiveFocusChanged: {
                            background.border.color = activeFocus ? Theme.primary() : Theme.secondaryText
                            background.color = activeFocus ? Theme.surface : Theme.background
                        }
                        Keys.onReturnPressed: {
                            commitEdit()
                            event.accepted = true
                        }
                        Keys.onEscapePressed: {
                            cancelEdit()
                            event.accepted = true
                        }
                    }

                    Text {
                        visible: !tableRect.isEditing
                        text: name
                        Layout.fillWidth: true
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                    }

                    SpinBox {
                        visible: tableRect.isEditing
                        from: 1
                        to: 20
                        value: tableRect.editedCapacity
                        width: 80
                        onValueChanged: tableRect.editedCapacity = value
                        font.pixelSize: Theme.fontNormal
                    }

                    Text {
                        visible: !tableRect.isEditing
                        text: capacity
                        width: 80
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontNormal
                    }

                    Button {
                        text: tableRect.isEditing ? qsTr("Save") : qsTr("Edit")
                        background: Rectangle {
                            color: Theme.primary()
                            radius: 4
                        }
                        contentItem: Text {
                            text: tableRect.isEditing ? qsTr("Save") : qsTr("Edit")
                            color: "white"
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontNormal
                        }
                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 5
                        bottomPadding: 5
                        onClicked: {
                            if (tableRect.isEditing)
                                commitEdit()
                            else
                                tableRect.isEditing = true
                        }
                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus
                    }

                    Button {
                        text: qsTr("Delete")
                        background: Rectangle {
                            color: "red"
                            radius: 4
                        }
                        contentItem: Text {
                            text: qsTr("Delete")
                            color: "white"
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontNormal
                        }
                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 5
                        bottomPadding: 5
                        onClicked: {
                            confirmationDialog.title = "Delete Table"
                            confirmationDialog.message = qsTr(
                                        'Are you sure you want to delete table "%1"?').arg(
                                        name)
                            confirmationDialog.confirmCallback = function (confirmed) {
                                if (confirmed) {
                                    TableService.removeTable(id)
                                }
                            }
                            confirmationDialog.open()
                        }
                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus
                    }
                }

                function commitEdit() {
                    if (editedName.trim().length === 0
                            || (editedName === originalName
                                && editedCapacity === originalCapacity)) {
                        isEditing = false
                        return
                    }
                    var success = TableService.editTable(id,
                                                         editedName,
                                                         editedCapacity)
                    isEditing = false
                }

                function cancelEdit() {
                    editedName = originalName
                    editedCapacity = originalCapacity
                    isEditing = false
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                spacing: 8

                TextField {
                    id: newTableName
                    placeholderText: qsTr("Table name")
                    Layout.fillWidth: true
                    height: 40
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                    placeholderTextColor: Theme.secondaryText
                    background: Rectangle {
                        color: Theme.surface
                        radius: 4
                        border.color: Theme.border
                    }
                    onActiveFocusChanged: {
                        background.border.color = activeFocus ? Theme.primary() : Theme.secondaryText
                        background.color = activeFocus ? Theme.surface : Theme.background
                    }
                }

                SpinBox {
                    id: newTableCapacity
                    value: 6
                    width: 80
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    font.pixelSize: Theme.fontNormal
                    background: Rectangle {
                        color: Theme.background
                        radius: 4
                        border.color: Theme.border
                    }
                }
            }

            Button {
                text: qsTr("Add Table")
                Layout.fillWidth: true
                Layout.topMargin: 15
                leftPadding: 15
                rightPadding: 15
                topPadding: 15
                bottomPadding: 15
                background: Rectangle {
                    color: Theme.primary()
                    radius: 4
                }
                contentItem: Text {
                    text: "Add Table"
                    color: "white"
                    font.bold: true
                    anchors.centerIn: parent
                    font.pixelSize: Theme.fontNormal
                }
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                onClicked: {
                    if (newTableName.text.trim().length === 0)
                        return
                    var success = TableService.addTable(newTableName.text,
                                                        newTableCapacity.value)
                    if (success) {
                        newTableName.text = ""
                        newTableCapacity.value = 4
                    }
                }
            }
        }
    }
}
