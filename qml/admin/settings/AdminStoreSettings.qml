import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

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
            font.pixelSize: Theme.fontLarge
            color: Theme.text
        }

        // basic information
        ColumnLayout {
            spacing: 15

            Text {
                Layout.fillWidth: true
                text: qsTr("Basic Information")
                font.bold: true
                color: Theme.secondaryText
                font.pixelSize: Theme.fontNormal
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                spacing: 10

                Label {
                    text: qsTr("Restaurant Name")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
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
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                    placeholderTextColor: Theme.secondaryText
                    background: Rectangle {
                        color: Theme.background
                        radius: 4
                        border.color: Theme.border
                    }
                }

                Label {
                    text: qsTr("Address")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter Address")
                    text: root.restaurantAddress
                    font.pixelSize: Theme.fontNormal
                    onTextChanged: root.restaurantAddress = text
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    color: Theme.text
                    placeholderTextColor: Theme.secondaryText
                    background: Rectangle {
                        color: Theme.background
                        radius: 4
                        border.color: Theme.border
                    }
                }

                Label {
                    text: qsTr("Phone Number (optional)")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter Phone Number")
                    font.pixelSize: Theme.fontNormal
                    text: root.restaurantPhone
                    onTextChanged: root.restaurantPhone = text
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    color: Theme.text
                    placeholderTextColor: Theme.secondaryText
                    background: Rectangle {
                        color: Theme.background
                        radius: 4
                        border.color: Theme.border
                    }
                }

                Label {
                    text: qsTr("Email (optional)")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter Email")
                    font.pixelSize: Theme.fontNormal
                    text: root.restaurantEmail
                    onTextChanged: root.restaurantEmail = text
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    color: Theme.text
                    placeholderTextColor: Theme.secondaryText
                    background: Rectangle {
                        color: Theme.background
                        radius: 4
                        border.color: Theme.border
                    }
                }

                Label {
                    text: qsTr("Website (optional)")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter Website")
                    font.pixelSize: Theme.fontNormal
                    text: root.restaurantWebsite
                    onTextChanged: root.restaurantWebsite = text
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 10
                    bottomPadding: 10
                    color: Theme.text
                    placeholderTextColor: Theme.secondaryText
                    background: Rectangle {
                        color: Theme.background
                        radius: 4
                        border.color: Theme.border
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
                color: Theme.primary()
                radius: 4
            }
            contentItem: Text {
                text: qsTr("Save")
                font.bold: true
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white"
                font.pixelSize: Theme.fontNormal
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
            font.pixelSize: Theme.fontNormal
        }
    }
}
