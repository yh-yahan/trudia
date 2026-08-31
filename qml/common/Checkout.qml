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

    property string paymentMethod: ""

    property bool splitPayment: false
    property string splitCashAmount: ""
    property string splitCardAmount: ""
    property bool updatingSplitPayment: false

    property var activeSessions: []
    property var recentOrders: []

    property var selectedSession: null
    property var selectedRecent: null
    property var selectedRecentDetails: null
    property var checkoutDetails: []

    property bool canCheckout: false
    property bool requireReadyForCheckout: false
    property string kitchenMode: ""

    property string currencySymbol: SettingService.currencySymbol()

    function reloadData() {
        activeSessions = CheckoutService.loadActiveCheckoutSessions()
        recentOrders = CheckoutService.getRecentPaidOrders()

        selectedSession = null
        selectedRecent = null
        selectedRecentDetails = null
        checkoutDetails = []

        memberPhone = ""
        memberId = 0
        currentPoints = 0
        earnedPointsPreview = 0

        paymentMethod = ""
        splitPayment = false
        splitCashAmount = ""
        splitCardAmount = ""
        updatingSplitPayment = false
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

    function updateMembershipPreview() {
        membershipChecked = false

        if (!memberPhone || !selectedSession)
            return

        var preview = MembershipService.preview(memberPhone,
                                                selectedSession.subtotal * 100,
                                                selectedSession.total * 100,
                                                redeemPointsRequested)

        membershipChecked = true

        memberId = preview.memberId || 0
        currentPoints = preview.currentPoints || 0

        earnedPointsPreview = preview.earnedPoints || 0

        redeemDiscountPreview = (preview.redeemDiscountCents || 0) / 100.0

        finalTotalPreview = (preview.finalTotalCents
                             || selectedSession.total * 100) / 100.0
    }

    function normalizeMoney(value) {
        var amount = Number(value)

        if (!isFinite(amount))
            return ""

        return (Math.round(amount * 100) / 100).toFixed(2)
    }

    Component.onCompleted: {
        reloadData()

        var kitchenSettings = SettingService.getKitchenSettings()

        if (kitchenSettings) {
            if (kitchenSettings.require_ready_for_checkout !== undefined) {
                requireReadyForCheckout = kitchenSettings.require_ready_for_checkout
            }

            if (kitchenSettings.mode !== undefined) {
                kitchenMode = kitchenSettings.mode
            }
        }
    }

    onCheckoutDetailsChanged: {
        if (kitchenMode === "tickets") {
            canCheckout = true
            return
        }

        if (requireReadyForCheckout) {
            canCheckout = sessionIsFullyServed(checkoutDetails)
        } else {
            canCheckout = true
        }
    }

    onSelectedSessionChanged: {
        finalTotalPreview = selectedSession.total
        paymentMethod = ""
        splitPayment = false
        splitCashAmount = ""
        splitCardAmount = ""
        updatingSplitPayment = false
        updateMembershipPreview()
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
                border.color: selectedSession === modelData ? Theme.primary(
                                                                  ) : "transparent"
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedRecent = null
                        selectedRecentDetails = null
                        selectedSession = modelData
                        memberPhone = ""
                        memberId = 0
                        currentPoints = 0
                        earnedPointsPreview = 0
                        redeemPointsRequested = 0
                        redeemDiscountPreview = 0
                        checkoutDetails = CheckoutService.loadCheckoutDetails(
                                    modelData.id)
                        updateMembershipPreview()
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
                        text: modelData.table_name ? qsTr("Table ")
                                                     + modelData.table_name : modelData.order_type
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
                        text: selectedSession ? qsTr(
                                                    "Order #") + selectedSession.display_number : ""
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
                                    visible: requireReadyForCheckout
                                             && !isOrderServed(modelData)
                                    text: qsTr("PENDING")
                                    color: Theme.orange
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                }

                                Text {
                                    visible: requireReadyForCheckout
                                             && isOrderServed(modelData)
                                    text: qsTr("SERVED")
                                    color: Theme.green
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                }
                            }

                            readonly property int qtyCol: 60
                            readonly property int unitCol: 80
                            readonly property int totalCol: 80
                            readonly property int itemCol: parent.width
                                                           - (qtyCol + unitCol + totalCol)

                            RowLayout {
                                width: parent.width
                                spacing: 0

                                Text {
                                    text: qsTr("Item")
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontSmall
                                    Layout.preferredWidth: itemCol
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: qsTr("Qty")
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontSmall
                                    Layout.preferredWidth: qtyCol
                                    horizontalAlignment: Text.AlignRight
                                }

                                Text {
                                    text: qsTr("Unit")
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontSmall
                                    Layout.preferredWidth: unitCol
                                    horizontalAlignment: Text.AlignRight
                                }

                                Text {
                                    text: qsTr("Total")
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontSmall
                                    Layout.preferredWidth: totalCol
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            Repeater {
                                model: modelData.items

                                delegate: RowLayout {
                                    width: parent.width
                                    spacing: 0
                                    height: 32

                                    Row {
                                        Layout.preferredWidth: itemCol
                                        spacing: 6
                                        Layout.alignment: Qt.AlignVCenter

                                        Text {
                                            text: modelData.item_name
                                            color: Theme.text
                                            font.pixelSize: Theme.fontNormal
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            visible: modelData.portion_size
                                            text: "(" + modelData.portion_size + ")"
                                            color: Theme.text
                                            font.pixelSize: Theme.fontNormal
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            visible: modelData.notes
                                                     && modelData.notes.length > 0
                                            text: "(" + modelData.notes + ")"
                                            color: Theme.orange
                                            font.pixelSize: Theme.fontSmall
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Text {
                                        Layout.preferredWidth: qtyCol
                                        text: "x" + modelData.quantity
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        horizontalAlignment: Text.AlignRight
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Text {
                                        Layout.preferredWidth: unitCol
                                        text: Number(
                                                  modelData.unit_price).toFixed(
                                                  2)
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        horizontalAlignment: Text.AlignRight
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Text {
                                        Layout.preferredWidth: totalCol
                                        text: Number(
                                                  modelData.total_price).toFixed(
                                                  2)
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        horizontalAlignment: Text.AlignRight
                                        verticalAlignment: Text.AlignVCenter
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
                                            memberPhone = text.trim()
                                            membershipChecked = false
                                            memberId = 0
                                            currentPoints = 0
                                            earnedPointsPreview = 0
                                        }
                                        onAccepted: updateMembershipPreview()

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
                                        onClicked: updateMembershipPreview()
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
                            text: memberId > 0 ? qsTr("Current Points: ") + currentPoints : qsTr(
                                                     "New member will be created")
                            color: memberId > 0 ? Theme.green : Theme.orange
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                        }

                        Text {
                            visible: selectedSession !== null
                            text: qsTr(
                                      "Points to Earn: +") + earnedPointsPreview
                            color: Theme.primary()
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                        }
                    }

                    Column {
                        visible: selectedSession !== null && memberId > 0
                                 && currentPoints > 0
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
                                    redeemPointsRequested = currentPoints
                                    updateMembershipPreview()
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
                                    redeemPointsRequested = 0
                                    updateMembershipPreview()
                                }
                            }
                        }
                    }

                    Column {
                        visible: selectedSession !== null
                        spacing: 6

                        Text {
                            text: qsTr("Payment Method")
                            color: Theme.secondaryText
                            font.pixelSize: Theme.fontNormal
                        }

                        Row {
                            spacing: 8

                            Button {
                                text: qsTr("Cash")

                                background: Rectangle {
                                    radius: 4
                                    color: paymentMethod === "cash"
                                        ? Theme.primary()
                                        : Theme.surface
                                }

                                contentItem: Text {
                                    text: qsTr("Cash")
                                    color: paymentMethod === "cash"
                                        ? "white"
                                        : Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus

                                onClicked: {
                                    paymentMethod = "cash"
                                    splitPayment = false
                                    splitCashAmount = ""
                                    splitCardAmount = ""
                                }
                            }

                            Button {
                                text: qsTr("Card")

                                background: Rectangle {
                                    radius: 4
                                    color: paymentMethod === "card"
                                        ? Theme.primary()
                                        : Theme.surface
                                }

                                contentItem: Text {
                                    text: qsTr("Card")
                                    color: paymentMethod === "card"
                                        ? "white"
                                        : Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus

                                onClicked: {
                                    paymentMethod = "card"
                                    splitPayment = false
                                    splitCashAmount = ""
                                    splitCardAmount = ""
                                }
                            }

                            Button {
                                text: qsTr("Split")

                                background: Rectangle {
                                    radius: 4
                                    color: splitPayment
                                        ? Theme.primary()
                                        : Theme.surface
                                }

                                contentItem: Text {
                                    text: qsTr("Split")
                                    color: splitPayment
                                        ? "white"
                                        : Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                hoverEnabled: false
                                focusPolicy: Qt.NoFocus

                                onClicked: {
                                    paymentMethod = ""
                                    splitPayment = true

                                    if (selectedSession) {
                                        splitCashAmount = (
                                            finalTotalPreview / 2
                                        ).toFixed(2)

                                        splitCardAmount = (
                                            finalTotalPreview -
                                            Number(splitCashAmount)
                                        ).toFixed(2)
                                    }
                                }
                            }
                        }

                        Column {
                            visible: splitPayment
                            spacing: 6
                            width: parent.width

                            Text {
                                text: qsTr("Cash Amount")
                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontNormal
                            }

                            TextField {
                                id: splitCashField

                                width: parent.width
                                text: splitCashAmount
                                placeholderText: currencySymbol + "0.00"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly

                                onTextChanged: {
                                    if (!activeFocus || updatingSplitPayment)
                                        return

                                    var cash = Number(text)

                                    if (!isFinite(cash))
                                        return

                                    if (cash < 0)
                                        cash = 0

                                    if (cash > finalTotalPreview)
                                        cash = finalTotalPreview

                                    splitCashAmount = text

                                    updatingSplitPayment = true

                                    var cashCents = Math.round(cash * 100)
                                    var totalCents = Math.round(finalTotalPreview * 100)
                                    var cardCents = Math.max(0, totalCents - cashCents)

                                    splitCardAmount = (cardCents / 100).toFixed(2)

                                    updatingSplitPayment = false
                                }

                                onEditingFinished: {
                                    if (splitCashAmount !== "")
                                        splitCashAmount = normalizeMoney(splitCashAmount)
                                }
                            }

                            Text {
                                text: qsTr("Card Amount")
                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontNormal
                            }

                            TextField {
                                id: splitCardField

                                width: parent.width
                                text: splitCardAmount
                                placeholderText: currencySymbol + "0.00"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly

                                onTextChanged: {
                                    if (!activeFocus || updatingSplitPayment)
                                        return

                                    var card = Number(text)

                                    if (!isFinite(card))
                                        return

                                    if (card < 0)
                                        card = 0

                                    if (card > finalTotalPreview)
                                        card = finalTotalPreview

                                    splitCardAmount = text

                                    updatingSplitPayment = true

                                    var cardCents = Math.round(card * 100)
                                    var totalCents = Math.round(finalTotalPreview * 100)
                                    var cashCents = Math.max(0, totalCents - cardCents)

                                    splitCashAmount = (cashCents / 100).toFixed(2)

                                    updatingSplitPayment = false
                                }

                                onEditingFinished: {
                                    if (splitCardAmount !== "")
                                        splitCardAmount = normalizeMoney(splitCardAmount)
                                }
                            }
                        }
                    }

                    Column {
                        spacing: 6

                        Text {
                            text: selectedSession ? qsTr("Subtotal: ") + currencySymbol
                                                    + selectedSession.subtotal.toFixed(
                                                        2) : ""
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        Text {
                            text: selectedSession ? qsTr("Tax: ") + currencySymbol
                                                    + selectedSession.tax.toFixed(
                                                        2) : ""
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        Text {
                            visible: redeemDiscountPreview > 0
                            text: selectedSession ? qsTr("Discount: -") + currencySymbol
                                                    + redeemDiscountPreview.toFixed(
                                                        2) : ""
                            color: Theme.orange
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                        }

                        Text {
                            text: selectedSession ? qsTr("Total: ") + currencySymbol
                                                    + finalTotalPreview.toFixed(
                                                        2) : ""
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
                                return

                            var payments = []

                            if (splitPayment) {
                                var cashAmount = Number(splitCashAmount)
                                var cardAmount = Number(splitCardAmount)

                                if (!isFinite(cashAmount) || !isFinite(cardAmount))
                                    return

                                if (cashAmount <= 0 || cardAmount <= 0)
                                    return

                                var totalPaid = cashAmount + cardAmount

                                if (Math.abs(totalPaid - finalTotalPreview) > 0.005)
                                    return

                                payments = [
                                    {
                                        method: "cash",
                                        amount: Math.round(cashAmount * 100)
                                    },
                                    {
                                        method: "card",
                                        amount: Math.round(cardAmount * 100)
                                    }
                                ]
                            } else {
                                payments = [
                                    {
                                        method: paymentMethod,
                                        amount: Math.round(finalTotalPreview * 100)
                                    }
                                ]
                            }

                            if (CheckoutService.completeCheckout({
                                orderSessionId: selectedSession.id,
                                memberPhone: memberPhone,
                                pointsToRedeem: redeemPointsRequested,
                                payments: payments
                            })) {
                                var printed = CheckoutService.printReceipt(
                                    selectedSession.id, false)

                                reloadData()
                            }
                        }
                    }
                }

                // recent orders detail
                ColumnLayout {
                    visible: selectedRecentDetails !== null
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        text: selectedRecentDetails
                              !== null ? qsTr("Order #") + selectedRecentDetails.display_number : ""
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        font.bold: true
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 16
                        clip: true

                        model: selectedRecentDetails ? selectedRecentDetails.orders : []

                        delegate: Column {
                            width: parent.width
                            spacing: 8

                            RowLayout {
                                width: parent.width
                                spacing: 12

                                Text {
                                    text: qsTr("Order ") + modelData.display_number
                                    color: '#9f9fff'
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                    Layout.fillWidth: true
                                }
                            }

                            readonly property int qtyCol: 60
                            readonly property int unitCol: 80
                            readonly property int totalCol: 80
                            readonly property int itemCol: parent.width
                                                           - (qtyCol + unitCol + totalCol)

                            RowLayout {
                                width: parent.width
                                spacing: 0

                                Text {
                                    text: qsTr("Item")
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontSmall
                                    Layout.preferredWidth: itemCol
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: qsTr("Qty")
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontSmall
                                    Layout.preferredWidth: qtyCol
                                    horizontalAlignment: Text.AlignRight
                                }

                                Text {
                                    text: qsTr("Unit")
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontSmall
                                    Layout.preferredWidth: unitCol
                                    horizontalAlignment: Text.AlignRight
                                }

                                Text {
                                    text: qsTr("Total")
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontSmall
                                    Layout.preferredWidth: totalCol
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            Repeater {
                                model: modelData.items

                                delegate: RowLayout {
                                    width: parent.width
                                    spacing: 0
                                    height: 32

                                    Row {
                                        Layout.preferredWidth: itemCol
                                        spacing: 6

                                        Text {
                                            text: modelData.item_name
                                            color: Theme.text
                                            font.pixelSize: Theme.fontNormal
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            visible: modelData.portion_size
                                            text: "(" + modelData.portion_size + ")"
                                            color: Theme.text
                                            font.pixelSize: Theme.fontNormal
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            visible: modelData.notes
                                                     && modelData.notes.length > 0
                                            text: "(" + modelData.notes + ")"
                                            color: Theme.orange
                                            font.pixelSize: Theme.fontSmall
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Text {
                                        Layout.preferredWidth: qtyCol
                                        text: "x" + modelData.quantity
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Text {
                                        Layout.preferredWidth: unitCol
                                        text: Number(
                                                  modelData.unit_price).toFixed(
                                                  2)
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Text {
                                        Layout.preferredWidth: totalCol
                                        text: Number(
                                                  modelData.total_price).toFixed(
                                                  2)
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.border
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: selectedRecentDetails ? qsTr("Subtotal: ") + currencySymbol
                                                    + selectedRecentDetails.subtotal.toFixed(
                                                        2) : ""
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        Text {
                            text: selectedRecentDetails ? qsTr("Tax: ") + currencySymbol
                                                    + selectedRecentDetails.tax.toFixed(
                                                        2) : ""
                            color: Theme.text
                            font.pixelSize: Theme.fontNormal
                        }

                        Text {
                            visible: selectedRecentDetails
                                     && selectedRecentDetails.discount > 0
                            text: selectedRecentDetails
                                  && selectedRecentDetails.discount
                                  > 0 ? qsTr("Discount: -") + currencySymbol
                                        + selectedRecentDetails.discount.toFixed(
                                            2) : ""
                            color: Theme.orange
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                        }

                        Text {
                            text: selectedRecentDetails ? qsTr("Total: ") + currencySymbol
                                                    + selectedRecentDetails.total.toFixed(
                                                        2) : ""
                            color: Theme.green
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                        }
                    }

                    Button {
                        Layout.topMargin: 15

                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10

                        text: qsTr("Reprint Receipt")

                        background: Rectangle {
                            radius: 6
                            color: Theme.primary()
                        }

                        contentItem: Text {
                            text: qsTr("Reprint Receipt")
                            color: "white"
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        onClicked: {
                            var printed = CheckoutService.printReceipt(
                                        selectedRecentDetails.id, true)
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
                        selectedSession = null

                        selectedRecent = modelData

                        selectedRecentDetails = CheckoutService.loadPaidOrderDetails(
                                    modelData.id)
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
