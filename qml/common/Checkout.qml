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

    property var activeSessions: []
    property var recentOrders: []

    property var selectedSession: null
    property var selectedRecent: null
    property var checkoutDetails: []

    property bool canCheckout: false
    property bool requireReadyForCheckout: false
    property string kitchenMode: ""

    function reloadData() {
        activeSessions = CheckoutService.getActiveOrdersForCheckout();
        recentOrders = CheckoutService.getRecentPaidOrders();

        selectedSession = null;
        selectedRecent = null;
        checkoutDetails = [];

        memberPhone = "";
        memberId = 0;
        currentPoints = 0;
        earnedPointsPreview = 0;
    }

    function normalizeStatus(status) {
        if (!status)
            return "";
        return (status + "").trim().toLowerCase();
    }

    function isOrderServed(order) {
        return normalizeStatus(order ? order.status : "") === "served";
    }

    function sessionIsFullyServed(details) {
        if (!details || details.length === 0)
            return false;

        for (var i = 0; i < details.length; i++) {
            if (!isOrderServed(details[i])) {
                return false;
            }
        }

        return true;
    }

    function updateMembershipInfo() {
        memberId = 0;
        currentPoints = 0;
        earnedPointsPreview = 0;
        membershipChecked = false;

        if (!memberPhone || memberPhone.length === 0)
            return;
        var member = MembershipService.getMemberByPhone(memberPhone);

        membershipChecked = true;

        if (member && member.id) {
            memberId = member.id;
            currentPoints = member.total_points;
        }

        if (selectedSession) {
            earnedPointsPreview = MembershipService.calculateEarnedPoints(selectedSession.total, "total");
        }
    }

    Component.onCompleted: {
        reloadData();

        var kitchenSettings = SettingService.getKitchenSettings();

        if (kitchenSettings) {
            if (kitchenSettings.require_ready_for_checkout !== undefined) {
                requireReadyForCheckout = kitchenSettings.require_ready_for_checkout;
            }

            if (kitchenSettings.mode !== undefined) {
                kitchenMode = kitchenSettings.mode;
            }
        }
    }

    onCheckoutDetailsChanged: {
        if (kitchenMode === "tickets") {
            canCheckout = true;
            return;
        }

        if (requireReadyForCheckout) {
            canCheckout = sessionIsFullyServed(checkoutDetails);
        } else {
            canCheckout = true;
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 6

        // active orders
        ListView {
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            model: activeSessions
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
                        selectedRecent = null;
                        selectedSession = modelData;
                        checkoutDetails = CheckoutService.getCheckoutDetails(modelData.id);
                        updateMembershipInfo();
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
                        text: modelData.table_id ? "Table " + modelData.table_id : modelData.order_type
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

                ColumnLayout {
                    visible: selectedSession !== null
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        text: "Order #" + selectedSession.display_number
                        color: "white"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
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
                                    text: "PENDING"
                                    color: "#ffaa66"
                                    font.bold: true
                                }

                                Text {
                                    visible: isOrderServed(modelData)
                                    text: "SERVED"
                                    color: "#88ffaa"
                                    font.bold: true
                                }
                            }

                            Repeater {
                                model: modelData.items
                                delegate: Row {
                                    spacing: 12
                                    width: parent.width

                                    Text {
                                        text: modelData.item_name + " ×" + modelData.quantity
                                        color: "white"
                                        font.pixelSize: 16
                                    }

                                    Text {
                                        visible: modelData.notes && modelData.notes.length > 0
                                        text: "(" + modelData.notes + ")"
                                        color: "#ffdd99"
                                        font.pixelSize: 15
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        spacing: 6

                        Text {
                            text: "Subtotal: RM" + selectedSession.subtotal.toFixed(2)
                            color: "white"
                        }

                        Text {
                            text: "Tax: RM" + selectedSession.tax.toFixed(2)
                            color: "white"
                        }

                        Text {
                            text: "Total: RM" + selectedSession.total.toFixed(2)
                            color: "white"
                            font.bold: true
                            font.pixelSize: 18
                        }
                    }

                    Button {
                        text: "Checkout"
                        enabled: canCheckout

                        background: Rectangle {
                            radius: 6
                            color: enabled ? "#9a7bff" : "#444444"
                        }

                        contentItem: Text {
                            text: "Checkout"
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            if (!selectedSession)
                                return;
                            if (CheckoutService.markOrderPaid(selectedSession.id, memberPhone, 0)) {
                                var printed = CheckoutService.printReceipt(selectedSession.id);

                                if (!printed) {
                                    console.log("Receipt printing failed");
                                }

                                reloadData();
                            }
                        }
                    }
                }

                Column {
                    visible: selectedRecent !== null
                    spacing: 10

                    Text {
                        text: "Recent Order #" + selectedRecent.display_number
                        color: "white"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Button {
                        text: "Reprint Receipt"

                        background: Rectangle {
                            radius: 6
                            color: enabled ? "#9a7bff" : "#444444"
                        }

                        contentItem: Text {
                            text: "Reprint Receipt"
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            var printed = CheckoutService.printReceipt(selectedRecent.id);

                            if (!printed) {
                                console.log("Receipt printing failed");
                            }
                        }
                    }
                }
            }
        }

        // recent orders
        ListView {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            model: recentOrders
            spacing: 10

            header: Column {
                spacing: 10

                Label {
                    text: qsTr("Recent Paid Orders")
                    font.pixelSize: 26
                    font.bold: true
                    color: "white"
                }
            }

            delegate: Rectangle {
                width: parent.width
                height: 72
                radius: 6

                color: selectedRecent === modelData ? "#2a2a2a" : "#1e1e1e"
                border.color: selectedRecent === modelData ? "#66ddaa" : "transparent"
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedSession = null;
                        selectedRecent = modelData;
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
                        text: "RM " + modelData.total.toFixed(2)
                        color: "#88ffaa"
                        font.pixelSize: 13
                    }
                }
            }
        }
    }
}
