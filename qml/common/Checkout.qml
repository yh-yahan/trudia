import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Xeno.Services 1.0

Item {
    width: 1200
    height: 700

    property string memberPhone: ""
    property int memberId: 0
    property int currentPoints: 0
    property bool membershipChecked: false
    property bool membershipEnabled: SettingService.membershipEnabled
    property int earnedPointsPreview: 0
    property var sessions: []
    property var selectedSession: null
    property var checkoutDetails: []

    property bool canCheckout: false

    function reloadSessions() {
        sessions = CheckoutService.getActiveOrdersForCheckout()
        selectedSession = null
        checkoutDetails = []
        memberPhone = ""
        memberId = 0
        currentPoints = 0
        earnedPointsPreview = 0
    }

    function normalizeStatus(status) {
        if (!status)
            return ""
        return (status + "").trim().toLowerCase()
    }

    function isOrderServed(order) {
        return normalizeStatus(order ? order.status : "") === "served"
    }

    function sessionIsFullyServed(details) {
        if (!details || details.length === 0)
            return false
        for (var i = 0; i < details.length; i++) {
            if (!isOrderServed(details[i])) {
                return false
            }
        }
        return true
    }

    function updateMembershipInfo() {
        memberId = 0
        currentPoints = 0
        earnedPointsPreview = 0
        membershipChecked = false

        if (!memberPhone || memberPhone.length === 0)
            return
        var member = MembershipService.getMemberByPhone(memberPhone)

        membershipChecked = true

        if (member && member.id) {
            memberId = member.id
            currentPoints = member.total_points
        }

        if (selectedSession) {
            earnedPointsPreview = MembershipService.calculateEarnedPoints(
                        selectedSession.total, "total")
        }
    }

    Component.onCompleted: {
        reloadSessions()
    }

    onCheckoutDetailsChanged: {
        canCheckout = sessionIsFullyServed(checkoutDetails)
    }

    RowLayout {
        anchors.fill: parent
        spacing: 6

        ListView {
            Layout.preferredWidth: 420
            Layout.fillHeight: true
            model: sessions
            spacing: 10

            delegate: Rectangle {
                width: parent.width
                height: 72
                radius: 6
                color: selectedSession === modelData ? "#2a2a2a" : "#1e1e1e"
                border.color: selectedSession === modelData ? "#9a7bff" : "transparent"
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (selectedSession === modelData) {
                            checkoutDetails = []
                        }
                        selectedSession = modelData
                        checkoutDetails = CheckoutService.getCheckoutDetails(
                                    modelData.id)
                        updateMembershipInfo()
                    }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    Text {
                        text: "#" + modelData.display_number
                        color: "white"
                        font.bold: true
                    }
                    Text {
                        text: modelData.table_id ? "Table "
                                                   + modelData.table_id : modelData.order_type
                        color: "#cccccc"
                        font.pixelSize: 12
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 6
            color: "#1e1e1e"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                Text {
                    visible: selectedSession !== null
                    text: selectedSession ? "Order #" + selectedSession.display_number : ""
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 120
                    model: checkoutDetails
                    spacing: 16
                    clip: true

                    delegate: Column {
                        spacing: 8
                        width: parent.width

                        RowLayout {
                            spacing: 12
                            width: parent.width

                            Text {
                                text: "Order " + modelData.display_number
                                color: "#bbbbff"
                                font.bold: true
                                font.pixelSize: 16
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: !isOrderServed(modelData)
                                text: qsTr("PENDING")
                                color: "#ffaa66"
                                font.bold: true
                                font.pixelSize: 15
                            }

                            Text {
                                visible: isOrderServed(modelData)
                                text: qsTr("SERVED")
                                color: "#88ffaa"
                                font.bold: true
                                font.pixelSize: 15
                            }
                        }

                        Repeater {
                            model: modelData.items
                            delegate: Row {
                                spacing: 12
                                width: parent ? parent.width : 0

                                Text {
                                    text: modelData.item_name + " ×" + modelData.quantity
                                    color: isOrderServed(
                                               modelData.parentModelData) ? "white" : "#888888"
                                    font.pixelSize: 16
                                }

                                Text {
                                    visible: modelData.notes
                                             && modelData.notes.length > 0
                                    text: "(" + modelData.notes + ")"
                                    color: isOrderServed(
                                               modelData.parentModelData) ? "#ffdd99" : "#aa8844"
                                    font.pixelSize: 15
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                    spacing: 12

                    Row {
                        visible: selectedSession !== null
                        spacing: 8

                        Column {
                            spacing: 6

                            visible: selectedSession !== null
                                     && membershipEnabled

                            Text {
                                text: "Member Phone (optional)"
                                color: "#cccccc"
                                font.pixelSize: 13
                            }

                            Row {
                                spacing: 8

                                TextField {
                                    id: memberPhoneField
                                    width: 200
                                    text: memberPhone

                                    onTextChanged: {
                                        memberPhone = text.trim()
                                        membershipChecked = false
                                        memberId = 0
                                        currentPoints = 0
                                        earnedPointsPreview = 0
                                    }
                                    onAccepted: updateMembershipInfo()

                                    background: Rectangle {
                                        radius: 4
                                        color: "#2a2a2a"
                                        border.color: "#555555"
                                    }

                                    color: "white"
                                }

                                Button {
                                    text: qsTr("Check")
                                    enabled: memberPhone.length > 0
                                    background: Rectangle {
                                        color: '#929292'
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: qsTr("Check")
                                        font.bold: true
                                        anchors.centerIn: parent
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        color: "white"
                                    }
                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus
                                    onClicked: updateMembershipInfo()
                                    height: memberPhoneField.height
                                    anchors.verticalCenter: memberPhoneField.verticalCenter
                                }
                            }
                        }
                    }

                    Column {
                        visible: selectedSession !== null && membershipChecked
                        spacing: 4

                        Text {
                            text: memberId > 0 ? "Current Points: "
                                                 + currentPoints : "New member will be created"
                            color: memberId > 0 ? "#88ffaa" : "#ffaa66"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Text {
                            visible: selectedSession !== null
                            text: "Points to Earn: +" + earnedPointsPreview
                            color: "#9a7bff"
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    Column {
                        visible: selectedSession !== null
                        spacing: 6

                        Text {
                            text: qsTr("Subtotal: RM") + selectedSession.subtotal.toFixed(
                                      2)
                            color: "white"
                            font.pixelSize: 15
                        }
                        Text {
                            text: qsTr("Tax: RM") + selectedSession.tax.toFixed(
                                      2)
                            color: "white"
                            font.pixelSize: 15
                        }
                        Text {
                            text: qsTr("Total: RM") + selectedSession.total.toFixed(
                                      2)
                            color: "white"
                            font.bold: true
                            font.pixelSize: 18
                        }
                    }

                    Button {
                        visible: selectedSession !== null
                        text: qsTr("Checkout")

                        enabled: canCheckout

                        background: Rectangle {
                            radius: 6
                            color: enabled ? "#9a7bff" : "#444444"
                        }

                        contentItem: Text {
                            text: qsTr("Checkout")
                            color: "white"
                            font.bold: true
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            if (!selectedSession)
                                return
                            if (CheckoutService.markOrderPaid(
                                        selectedSession.id, memberPhone, 0)) {
                                var printed = CheckoutService.printReceipt(
                                            selectedSession.id)

                                if (!printed) {
                                    console.log("Receipt printing failed for #"
                                                + selectedSession.display_number)
                                }

                                reloadSessions()
                                memberPhone = ""
                            }
                        }
                    }
                }
            }
        }
    }
}
