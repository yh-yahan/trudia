import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
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
        color: "#121212"
    }

    property var tables: []

    function loadTables() {
        tables = TableService.getAllTables()
    }

    Component.onCompleted: loadTables()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: qsTr("Table Management")
            font.bold: true
            font.pixelSize: 18
            color: "white"
        }

        Rectangle {
            Layout.fillWidth: true
            height: 36
            color: "#1f1f1f"
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 10

                Text {
                    text: qsTr("Table Name")
                    Layout.fillWidth: true
                    color: "#b0b0b0"
                    font.bold: true
                }
                Text {
                    text: qsTr("Capacity")
                    width: 80
                    color: "#b0b0b0"
                    font.bold: true
                }
                Item {
                    width: 150
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: tables
            clip: true
            spacing: 4

            delegate: Rectangle {
                id: tableRect
                height: 44
                width: ListView.view.width
                radius: 4
                color: "#1f1f1f"
                border.color: "#2a2a2a"

                property bool isEditing: false
                property string editedName: modelData.table_number
                property int editedCapacity: modelData.capacity
                property string originalName: modelData.table_number
                property int originalCapacity: modelData.capacity

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    TextField {
                        visible: tableRect.isEditing
                        text: tableRect.editedName
                        Layout.fillWidth: true
                        color: "white"
                        background: Rectangle {
                            color: "#292929"
                            radius: 4
                            border.color: "#888888"
                            border.width: 1
                        }
                        onTextChanged: tableRect.editedName = text
                        onActiveFocusChanged: {
                            background.border.color = activeFocus ? "#9a7bff" : "#888888"
                            background.color = activeFocus ? "#292929" : "#1f1f1f"
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
                        text: modelData.table_number
                        Layout.fillWidth: true
                        color: "white"
                    }

                    SpinBox {
                        visible: tableRect.isEditing
                        from: 1
                        to: 20
                        value: tableRect.editedCapacity
                        width: 80
                        onValueChanged: tableRect.editedCapacity = value
                    }

                    Text {
                        visible: !tableRect.isEditing
                        text: modelData.capacity
                        width: 80
                        color: "#d0d0d0"
                    }

                    Button {
                        text: tableRect.isEditing ? qsTr("Save") : qsTr("Edit")
                        background: Rectangle {
                            color: "#9a7bff"
                            radius: 4
                        }
                        contentItem: Text {
                            text: tableRect.isEditing ? qsTr("Save") : qsTr("Edit")
                            color: "white"
                            anchors.centerIn: parent
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
                        }
                        leftPadding: 15
                        rightPadding: 15
                        topPadding: 5
                        bottomPadding: 5
                        onClicked: {
                            confirmationDialog.title = "Delete Table"
                            confirmationDialog.message = qsTr(
                                        'Are you sure you want to delete table "%1"?').arg(
                                        modelData.table_number)
                            confirmationDialog.confirmCallback = function (confirmed) {
                                if (confirmed) {
                                    TableService.removeTable(modelData.id)
                                    loadTables()
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
                    var success = TableService.editTable(modelData.id,
                                                         editedName,
                                                         editedCapacity)
                    if (success)
                        loadTables()
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
                    color: "white"
                    placeholderTextColor: "#b5b5b5"
                    background: Rectangle {
                        color: "#1f1f1f"
                        radius: 4
                        border.color: "#888888"
                    }
                    onActiveFocusChanged: {
                        background.border.color = activeFocus ? "#9a7bff" : "#888888"
                        background.color = activeFocus ? "#292929" : "#1f1f1f"
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
                    background: Rectangle {
                        color: "#1f1f1f"
                        radius: 4
                        border.color: "#888888"
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
                    color: "#9a7bff"
                    radius: 4
                }
                contentItem: Text {
                    text: "Add Table"
                    color: "white"
                    font.bold: true
                    anchors.centerIn: parent
                }
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                onClicked: {
                    if (newTableName.text.trim().length === 0)
                        return
                    var success = TableService.addTable(newTableName.text,
                                                        newTableCapacity.value)
                    if (success) {
                        loadTables()
                        newTableName.text = ""
                        newTableCapacity.value = 4
                    }
                }
            }
        }
    }
}
