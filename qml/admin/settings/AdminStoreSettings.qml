import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Xeno.Services 1.0

ScrollView {
    id: root
    anchors.fill: parent
    contentWidth: parent.width

    property string restaurantName: ""
    property string restaurantAddress: ""
    property string restaurantPhone: ""
    property string restaurantEmail: ""
    property string restaurantWebsite: ""
    property string errorMessage: ""

    function loadRestaurant() {
        var data = SettingService.getRestaurant()
        restaurantName = data["name"] || ""
        restaurantAddress = data["address"] || ""
        restaurantPhone = data["phone_number"] || ""
        restaurantEmail = data["email"] || ""
        restaurantWebsite = data["website"] || ""
    }

    Component.onCompleted: loadRestaurant()

    ColumnLayout {
        width: parent.width
        spacing: 30

        // section title
        Text {
            text: qsTr("Restaurant Settings")
            font.bold: true
            font.pixelSize: 26
            color: "white"
        }

        // basic information
        ColumnLayout {
            spacing: 15

            Text {
                Layout.fillWidth: true
                text: qsTr("Basic Information")
                font.bold: true
                color: "#c9c9c9"
                font.pointSize: 16
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                spacing: 10

                Label {
                    text: qsTr("Restaurant Name")
                    color: "white"
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter Restaurant Name")
                    text: root.restaurantName
                    onTextChanged: root.restaurantName = text
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
                }

                Label {
                    text: qsTr("Address")
                    color: "white"
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter Address")
                    text: root.restaurantAddress
                    onTextChanged: root.restaurantAddress = text
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
                }

                Label {
                    text: qsTr("Phone Number (optional)")
                    color: "white"
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter Phone Number")
                    text: root.restaurantPhone
                    onTextChanged: root.restaurantPhone = text
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
                }

                Label {
                    text: qsTr("Email (optional)")
                    color: "white"
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter Email")
                    text: root.restaurantEmail
                    onTextChanged: root.restaurantEmail = text
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
                }

                Label {
                    text: qsTr("Website (optional)")
                    color: "white"
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter Website")
                    text: root.restaurantWebsite
                    onTextChanged: root.restaurantWebsite = text
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
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 20

        Button {
            text: qsTr("Save")
            width: 60
            leftPadding: 20
            rightPadding: 20
            topPadding: 10
            bottomPadding: 10
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            Layout.leftMargin: 20
            background: Rectangle {
                color: "#9a7bff"
                radius: 4
            }
            contentItem: Text {
                text: qsTr("Save")
                font.bold: true
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white"
            }
            hoverEnabled: false
            focusPolicy: Qt.NoFocus
            onClicked: {
                var map = {
                    "name": root.restaurantName,
                    "address": root.restaurantAddress,
                    "phone_number": root.restaurantPhone,
                    "email": root.restaurantEmail,
                    "website": root.restaurantWebsite
                }
                if (SettingService.saveRestaurantSetting(map)) {
                    console.log("Saved successfully")
                    loadRestaurant()
                } else {
                    root.errorMessage = "Failed to save restaurant settings."
                }
            }
        }

        Text {
            text: root.errorMessage
            color: "red"
            font.bold: true
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}
