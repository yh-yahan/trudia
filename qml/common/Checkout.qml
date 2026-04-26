import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    width: 1200
    height: 700

    property string memberPhone: ""
    property int memberId: 0
    property int currentPoints: 0
    property bool membershipChecked: false
    property bool membershipEnabled: SettingService.membershipEnabled
    property int earnedPointsPreview: 0
    property int redeemPointsRequested: 0
    property double redeemDiscountPreview: 0
    property double finalTotalPreview: 0

    property var activeSessions: []
    property var recentOrders: []

    property var selectedSession: null
    property var selectedRecent: null
    property var checkoutDetails: []

    property bool canCheckout: false
    property bool requireReadyForCheckout: false
    property string kitchenMode: ""

    property string currencySymbol: SettingService.currencySymbol()

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

        redeemPointsRequested = 0;

        if (!memberPhone || memberPhone.length === 0)
            return;
        var member = MembershipService.getMemberByPhone(memberPhone);

        membershipChecked = true;

        if (member && member.id) {
            memberId = member.id;
            currentPoints = member.total_points;
        }

        if (selectedSession) {
            earnedPointsPreview = MembershipService.calculateEarnedPoints(selectedSession.subtotal * 100, selectedSession.total * 100);
            updateRedemptionPreview();
        }
    }

    function updateRedemptionPreview() {
        redeemDiscountPreview = 0;
        finalTotalPreview = selectedSession ? selectedSession.total : 0;

        if (!selectedSession || memberId <= 0 || currentPoints <= 0)
            return;

        var settings = SettingService.getMembershipSettings();
        if (!settings || settings.redeem_points <= 0)
            return;

        var points = redeemPointsRequested;

        if (points <= 0) {
            redeemDiscountPreview = 0;
            finalTotalPreview = selectedSession.total;
            return;
        }

        var valuePerPoint = settings.redeem_value / settings.redeem_points;

        var maxDiscount = points * valuePerPoint;

        redeemDiscountPreview = Math.min(maxDiscount, selectedSession.total);
        finalTotalPreview = selectedSession.total - redeemDiscountPreview;
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

    onSelectedSessionChanged: {
        updateRedemptionPreview();
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

                color: selectedSession === modelData ? Theme.surface : Theme.background
                border.color: selectedSession === modelData ? Theme.primary() : "transparent"
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
                        color: Theme.text
                        font.bold: true
                        font.pixelSize: Theme.fontNormal
                    }

                    Text {
                        text: modelData.table_number ? qsTr("Table ") + modelData.table_number : modelData.order_type
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontNormal
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 6
            color: Theme.background

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                ColumnLayout {
                    visible: selectedSession !== null
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        text: qsTr("Order #") + selectedSession.display_number
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
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
                                    text: qsTr("Order ") + modelData.display_number
                                    color: '#9f9fff'
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                    Layout.fillWidth: true
                                }

                                Text {
                                    visible: requireReadyForCheckout && !isOrderServed(modelData)
                                    text: qsTr("PENDING")
                                    color: Theme.orange
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                }

                                Text {
                                    visible: requireReadyForCheckout && isOrderServed(modelData)
                                    text: qsTr("SERVED")
                                    color: Theme.green
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                }
                            }

                            Repeater {
                                model: modelData.items
                                delegate: Row {
                                    spacing: 12
                                    width: parent.width

                                    Text {
                                        text: modelData.item_name + " x" + modelData.quantity
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                    }

                                    Text {
                                        visible: modelData.notes && modelData.notes.length > 0
                                        text: "(" + modelData.notes + ")"
                                        color: Theme.orange
                                        font.pixelSize: Theme.fontSmall
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

                                visible: selectedSession !== null && membershipEnabled

                                Text {
                                    text: qsTr("Member Phone (optional)")
                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontNormal
                                }

                                Row {
                                    spacing: 8

                                    TextField {
                                        id: memberPhoneField
                                        width: 200
                                        text: memberPhone

                                        onTextChanged: {
                                            memberPhone = text.trim();
                                            membershipChecked = false;
                                            memberId = 0;
                                            currentPoints = 0;
                                            earnedPointsPreview = 0;
                                        }
                                        onAccepted: updateMembershipInfo()

                                        background: Rectangle {
                                            radius: 4
                                            color: Theme.background
                                            border.color: Theme.border
                                        }

                                        color: Theme.text
                                    }

                                    Button {
                                        text: qsTr("Check")
                                        enabled: memberPhone.length > 0
                                        background: Rectangle {
                                            color: '#4faba1'
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: qsTr("Check")
                                            font.bold: true
                                            anchors.centerIn: parent
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            color: "white"
                                            font.pixelSize: Theme.fontNormal
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
                    }

                    Column {
                        visible: selectedSession !== null && membershipChecked
                        spacing: 4

                        Text {
                            text: memberId > 0 ? qsTr("Current Points: ") + currentPoints : qsTr("New member will be created")
                            color: memberId > 0 ? Theme.green : Theme.orange
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                        }

                        Text {
                            visible: selectedSession !== null
                            text: qsTr("Points to Earn: +") + earnedPointsPreview
                            color: Theme.primary()
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                        }
                    }

                    Column {
                        visible: selectedSession !== null && memberId > 0 && currentPoints > 0
                        spacing: 6

                        Row {
                            spacing: 8

                            Button {
                                text: qsTr("Redeem All")

                                background: Rectangle {
                                    radius: 4
                                    color: "#ffaa66"
                                }

                                contentItem: Text {
                                    text: qsTr("Redeem All")
                                    anchors.centerIn: parent
                                    color: "black"
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                }

                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus

                                onClicked: {
                                    redeemPointsRequested = currentPoints;
                                    updateRedemptionPreview();
                                }
                            }

                            Button {
                                text: qsTr("Clear")

                                background: Rectangle {
                                    radius: 4
                                    color: "#5F7DDC"
                                }

                                contentItem: Text {
                                    text: qsTr("Clear")
                                    anchors.centerIn: parent
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                }

                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus

                                onClicked: {
                                    redeemPointsRequested = 0;
                                    updateRedemptionPreview();
                                }
                            }
                        }
                    }

                    Column {
                        spacing: 6

                        Text {
                            text: qsTr("Subtotal: ") + currencySymbol + selectedSession.subtotal.toFixed(2)
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        Text {
                            text: qsTr("Tax: ") + currencySymbol + selectedSession.tax.toFixed(2)
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        Text {
                            visible: redeemDiscountPreview > 0
                            text: qsTr("Discount: -") + currencySymbol + redeemDiscountPreview.toFixed(2)
                            color: Theme.orange
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                        }

                        Text {
                            text: qsTr("Total: ") + currencySymbol + finalTotalPreview.toFixed(2)
                            color: Theme.text
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                        }
                    }

                    Button {
                        text: qsTr("Checkout")
                        enabled: canCheckout

                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10
                        Layout.topMargin: 15

                        background: Rectangle {
                            radius: 6
                            color: enabled ? Theme.primary() : Theme.surface
                        }

                        contentItem: Text {
                            text: qsTr("Checkout")
                            color: enabled ? "white" : Theme.secondaryText
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Theme.fontNormal
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            if (!selectedSession)
                                return;
                            if (CheckoutService.markOrderPaid(selectedSession.id, memberPhone, redeemPointsRequested)) {
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
                        text: qsTr("Recent Order #") + selectedRecent.display_number
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        font.bold: true
                    }

                    Button {
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10

                        text: qsTr("Reprint Receipt")

                        background: Rectangle {
                            radius: 6
                            color: enabled ? Theme.primary() : Theme.surface
                        }

                        contentItem: Text {
                            text: qsTr("Reprint Receipt")
                            color: enabled ? "white" : Theme.secondaryText
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Theme.fontNormal
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
                    font.pixelSize: Theme.fontNormal
                    font.bold: true
                    color: Theme.text
                }
            }

            delegate: Rectangle {
                width: parent.width
                height: 72
                radius: 6

                color: selectedRecent === modelData ? Theme.surface : Theme.background
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
                        color: Theme.text
                        font.bold: true
                        font.pixelSize: Theme.fontNormal
                    }

                    Text {
                        text: currencySymbol + modelData.total.toFixed(2)
                        color: Theme.green
                        font.pixelSize: Theme.fontNormal
                    }
                }
            }
        }
    }
}
