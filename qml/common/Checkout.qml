import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    id: root
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

    // "open" shows unpaid sessions, "paid" shows recent receipts
    property string listMode: "open"

    readonly property bool hasOpenSelection: selectedSession !== null
    readonly property bool hasPaidSelection: selectedRecentDetails !== null
    readonly property bool paymentReady: splitPayment
                                         || paymentMethod === "cash"
                                         || paymentMethod === "card"
    readonly property bool checkoutReady: hasOpenSelection && canCheckout && paymentReady

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

    function clearMembershipState() {
        memberPhone = ""
        memberId = 0
        currentPoints = 0
        earnedPointsPreview = 0
        redeemPointsRequested = 0
        redeemDiscountPreview = 0
        membershipChecked = false
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

    function pendingOrderCount(details) {
        if (!details || details.length === 0)
            return 0

        var count = 0
        for (var i = 0; i < details.length; i++) {
            if (!isOrderServed(details[i]))
                count++
        }
        return count
    }

    function formatMoney(value) {
        var amount = Number(value)
        if (!isFinite(amount))
            amount = 0
        return currencySymbol + amount.toFixed(2)
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

    function selectOpenSession(session) {
        selectedRecent = null
        selectedRecentDetails = null
        selectedSession = session
        clearMembershipState()
        checkoutDetails = CheckoutService.loadCheckoutDetails(session.id)
        updateMembershipPreview()
    }

    function selectPaidOrder(order) {
        selectedSession = null
        selectedRecent = order
        selectedRecentDetails = CheckoutService.loadPaidOrderDetails(order.id)
        clearMembershipState()
        paymentMethod = ""
        splitPayment = false
        splitCashAmount = ""
        splitCardAmount = ""
    }

    function performCheckout() {
        if (!selectedSession || !checkoutReady)
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
                                                "orderSessionId": selectedSession.id,
                                                "memberPhone": memberPhone,
                                                "pointsToRedeem": redeemPointsRequested,
                                                "payments": payments
                                            })) {
            CheckoutService.printReceipt(selectedSession.id, false)
            reloadData()
        }
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
        finalTotalPreview = selectedSession ? selectedSession.total : 0
        paymentMethod = ""
        splitPayment = false
        splitCashAmount = ""
        splitCardAmount = ""
        updatingSplitPayment = false
        updateMembershipPreview()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Top bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Column {
                spacing: 2
                Layout.fillWidth: true

                Text {
                    text: qsTr("Checkout")
                    color: Theme.text
                    font.pixelSize: Theme.fontNormal + 4
                    font.bold: true
                }

                Text {
                    text: listMode === "open"
                          ? qsTr("%1 open tickets").arg(activeSessions.length)
                          : qsTr("%1 recent receipts").arg(recentOrders.length)
                    color: Theme.secondaryText
                    font.pixelSize: Theme.fontSmall
                }
            }

            Button {
                text: qsTr("Refresh")
                hoverEnabled: false
                focusPolicy: Qt.NoFocus
                leftPadding: 14
                rightPadding: 14
                topPadding: 8
                bottomPadding: 8

                background: Rectangle {
                    radius: 4
                    color: Theme.background
                    border.color: Theme.border
                    border.width: 1
                }

                contentItem: Text {
                    text: qsTr("Refresh")
                    color: Theme.text
                    font.bold: true
                    font.pixelSize: Theme.fontNormal
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: reloadData()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // Left: tickets
            Rectangle {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                radius: 8
                color: Theme.background
                border.color: Theme.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 10
                        color: Theme.background

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 4

                            Repeater {
                                model: [
                                    { key: "open", label: qsTr("Open") },
                                    { key: "paid", label: qsTr("Paid") }
                                ]

                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 4
                                    color: listMode === modelData.key ? Theme.primary() : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        color: listMode === modelData.key ? "white" : Theme.secondaryText
                                        font.bold: true
                                        font.pixelSize: Theme.fontNormal
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: listMode = modelData.key
                                    }
                                }
                            }
                        }
                    }

                    ListView {
                        id: ticketList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: listMode === "open" ? activeSessions : recentOrders

                        delegate: Rectangle {
                            width: ticketList.width
                            height: 78
                            radius: 10
                            color: {
                                if (listMode === "open" && selectedSession === modelData)
                                    return Theme.background
                                if (listMode === "paid" && selectedRecent === modelData)
                                    return Theme.background
                                return "transparent"
                            }
                            border.width: 2
                            border.color: {
                                if (listMode === "open" && selectedSession === modelData)
                                    return Theme.primary()
                                if (listMode === "paid" && selectedRecent === modelData)
                                    return Theme.green
                                return "transparent"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (listMode === "open")
                                        selectOpenSession(modelData)
                                    else
                                        selectPaidOrder(modelData)
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                Rectangle {
                                    width: 6
                                    Layout.fillHeight: true
                                    radius: 3
                                    color: listMode === "open" ? Theme.primary() : Theme.green
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        text: "#" + modelData.display_number
                                        color: Theme.text
                                        font.bold: true
                                        font.pixelSize: Theme.fontNormal
                                    }

                                    Text {
                                        text: listMode === "open"
                                              ? (modelData.table_name ? qsTr("Table ") + modelData.table_name
                                                                      : modelData.order_type)
                                              : formatMoney(modelData.total)
                                        color: listMode === "paid" ? Theme.green : Theme.secondaryText
                                        font.pixelSize: Theme.fontSmall
                                    }
                                }

                                Text {
                                    visible: listMode === "open" && modelData.total !== undefined
                                    text: formatMoney(modelData.total)
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontSmall
                                }
                            }
                        }

                        Label {
                            anchors.centerIn: parent
                            visible: ticketList.count === 0
                            text: listMode === "open" ? qsTr("No open tickets")
                                                      : qsTr("No recent receipts")
                            color: Theme.secondaryText
                            font.pixelSize: Theme.fontNormal
                        }
                    }
                }
            }

            // Center: bill
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: Theme.background
                border.color: Theme.border
                border.width: 1

                // Empty state
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: !hasOpenSelection && !hasPaidSelection
                    width: parent.width * 0.7

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Select a ticket")
                        color: Theme.text
                        font.bold: true
                        font.pixelSize: Theme.fontNormal + 2
                    }

                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Choose an open ticket to take payment, or a paid ticket to reprint a receipt.")
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontSmall
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    visible: hasOpenSelection || hasPaidSelection

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: hasOpenSelection
                                      ? qsTr("Ticket #%1").arg(selectedSession.display_number)
                                      : qsTr("Receipt #%1").arg(selectedRecentDetails.display_number)
                                color: Theme.text
                                font.bold: true
                                font.pixelSize: Theme.fontNormal + 2
                            }

                            Text {
                                text: hasOpenSelection
                                      ? (selectedSession.table_name ? qsTr("Table %1").arg(selectedSession.table_name)
                                                                    : selectedSession.order_type)
                                      : qsTr("Paid order")
                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontSmall
                            }
                        }

                        Rectangle {
                            visible: hasOpenSelection && requireReadyForCheckout && kitchenMode !== "tickets"
                            radius: 8
                            implicitHeight: 28
                            implicitWidth: chipLabel.implicitWidth + 16
                            color: sessionIsFullyServed(checkoutDetails) ? Theme.green : Theme.orange

                            Text {
                                id: chipLabel
                                anchors.centerIn: parent
                                text: sessionIsFullyServed(checkoutDetails)
                                      ? qsTr("Ready")
                                      : qsTr("%1 pending").arg(pendingOrderCount(checkoutDetails))
                                color: "white"
                                font.bold: true
                                font.pixelSize: Theme.fontSmall
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.border
                    }

                    ListView {
                        id: billList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 14
                        model: hasOpenSelection
                               ? checkoutDetails
                               : (selectedRecentDetails ? selectedRecentDetails.orders : [])

                        delegate: Column {
                            width: billList.width
                            spacing: 8

                            RowLayout {
                                width: parent.width
                                spacing: 8

                                Text {
                                    text: qsTr("Order %1").arg(modelData.display_number)
                                    color: Theme.primary()
                                    font.bold: true
                                    font.pixelSize: Theme.fontSmall
                                    Layout.fillWidth: true
                                }

                                Text {
                                    visible: hasOpenSelection && requireReadyForCheckout
                                    text: isOrderServed(modelData) ? qsTr("SERVED") : qsTr("PENDING")
                                    color: isOrderServed(modelData) ? Theme.green : Theme.orange
                                    font.bold: true
                                    font.pixelSize: Theme.fontSmall
                                }
                            }

                            Repeater {
                                model: modelData.items

                                delegate: RowLayout {
                                    width: parent.width
                                    spacing: 8

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            width: parent.width
                                            text: modelData.item_name
                                                  + (modelData.portion_size ? " (" + modelData.portion_size + ")" : "")
                                            color: Theme.text
                                            font.pixelSize: Theme.fontNormal
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            visible: modelData.notes && modelData.notes.length > 0
                                            text: modelData.notes
                                            color: Theme.orange
                                            font.pixelSize: Theme.fontSmall
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Text {
                                        text: "×" + modelData.quantity
                                        color: Theme.secondaryText
                                        font.pixelSize: Theme.fontNormal
                                        Layout.preferredWidth: 40
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Text {
                                        text: Number(modelData.total_price).toFixed(2)
                                        color: Theme.text
                                        font.pixelSize: Theme.fontNormal
                                        Layout.preferredWidth: 72
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Right: pay / reprint
            Rectangle {
                Layout.preferredWidth: 340
                Layout.fillHeight: true
                radius: 8
                color: Theme.background
                border.color: Theme.border
                border.width: 1

                // Placeholder when nothing is selected
                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    visible: !hasOpenSelection && !hasPaidSelection
                    width: parent.width - 32

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Payment")
                        color: Theme.text
                        font.bold: true
                        font.pixelSize: Theme.fontNormal
                    }

                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Totals and payment options will appear here.")
                        color: Theme.secondaryText
                        font.pixelSize: Theme.fontSmall
                    }
                }

                // Open ticket payment panel
                Flickable {
                    id: payFlick
                    anchors.fill: parent
                    anchors.margins: 16
                    visible: hasOpenSelection
                    contentWidth: width
                    contentHeight: payColumn.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: payColumn
                        width: payFlick.width
                        spacing: 14

                        Text {
                            text: qsTr("Payment")
                            color: Theme.text
                            font.bold: true
                            font.pixelSize: Theme.fontNormal + 2
                        }

                        ColumnLayout {
                            visible: membershipEnabled
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: qsTr("Member phone")
                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontSmall
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                TextField {
                                    id: memberPhoneField
                                    Layout.fillWidth: true
                                    text: memberPhone
                                    placeholderText: qsTr("Optional")
                                    font.pixelSize: Theme.fontNormal

                                    onTextChanged: {
                                        memberPhone = text.trim()
                                        membershipChecked = false
                                        memberId = 0
                                        currentPoints = 0
                                        earnedPointsPreview = 0
                                    }
                                    onAccepted: updateMembershipPreview()

                                    background: Rectangle {
                                        radius: 2
                                        color: Theme.background
                                        border.color: Theme.border
                                    }

                                    color: Theme.text
                                }

                                Button {
                                    text: qsTr("Check")
                                    enabled: memberPhone.length > 0
                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus
                                    Layout.preferredHeight: memberPhoneField.height

                                    background: Rectangle {
                                        radius: 4
                                        color: enabled ? Theme.primary() : Theme.background
                                    }

                                    contentItem: Text {
                                        text: qsTr("Check")
                                        color: enabled ? "white" : Theme.secondaryText
                                        font.bold: true
                                        font.pixelSize: Theme.fontNormal
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: updateMembershipPreview()
                                }
                            }

                            Text {
                                visible: membershipChecked
                                text: memberId > 0 ? qsTr("Points: %1").arg(currentPoints)
                                                   : qsTr("New member will be created")
                                color: memberId > 0 ? Theme.green : Theme.orange
                                font.pixelSize: Theme.fontNormal
                                font.bold: true
                            }

                            Text {
                                visible: membershipChecked
                                text: qsTr("Will earn +%1").arg(earnedPointsPreview)
                                color: Theme.primary()
                                font.pixelSize: Theme.fontNormal
                                font.bold: true
                            }

                            RowLayout {
                                visible: memberId > 0 && currentPoints > 0
                                Layout.fillWidth: true
                                spacing: 8

                                Button {
                                    text: qsTr("Redeem all")
                                    Layout.fillWidth: true
                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus

                                    background: Rectangle {
                                        radius: 4
                                        color: Theme.orange
                                    }

                                    contentItem: Text {
                                        text: qsTr("Redeem all")
                                        anchors.centerIn: parent
                                        color: "white"
                                        font.bold: true
                                        font.pixelSize: Theme.fontNormal
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        redeemPointsRequested = currentPoints
                                        updateMembershipPreview()
                                    }
                                }

                                Button {
                                    text: qsTr("Clear")
                                    Layout.fillWidth: true
                                    hoverEnabled: false
                                    focusPolicy: Qt.NoFocus

                                    background: Rectangle {
                                        radius: 8
                                        color: Theme.background
                                        border.color: Theme.border
                                        border.width: 1
                                    }

                                    contentItem: Text {
                                        text: qsTr("Clear")
                                        anchors.centerIn: parent
                                        color: Theme.text
                                        font.bold: true
                                        font.pixelSize: Theme.fontNormal
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        redeemPointsRequested = 0
                                        updateMembershipPreview()
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: qsTr("Method")
                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontSmall
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Repeater {
                                    model: [
                                        { key: "cash", label: qsTr("Cash") },
                                        { key: "card", label: qsTr("Card") },
                                        { key: "split", label: qsTr("Split") }
                                    ]

                                    delegate: Button {
                                        Layout.fillWidth: true
                                        hoverEnabled: false
                                        focusPolicy: Qt.NoFocus
                                        topPadding: 10
                                        bottomPadding: 10

                                        readonly property bool selected: modelData.key === "split"
                                                                         ? splitPayment
                                                                         : paymentMethod === modelData.key

                                        background: Rectangle {
                                            radius: 8
                                            color: parent.selected ? Theme.primary() : Theme.background
                                            border.color: parent.selected ? Theme.primary() : Theme.border
                                            border.width: 1
                                        }

                                        contentItem: Text {
                                            text: modelData.label
                                            color: parent.selected ? "white" : Theme.text
                                            font.bold: true
                                            font.pixelSize: Theme.fontSmall
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: {
                                            if (modelData.key === "split") {
                                                paymentMethod = ""
                                                splitPayment = true
                                                if (selectedSession) {
                                                    splitCashAmount = (finalTotalPreview / 2).toFixed(2)
                                                    splitCardAmount = (finalTotalPreview - Number(splitCashAmount)).toFixed(2)
                                                }
                                            } else {
                                                paymentMethod = modelData.key
                                                splitPayment = false
                                                splitCashAmount = ""
                                                splitCardAmount = ""
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            visible: splitPayment
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: qsTr("Cash amount")
                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontSmall
                            }

                            TextField {
                                id: splitCashField
                                Layout.fillWidth: true
                                text: splitCashAmount
                                placeholderText: currencySymbol + "0.00"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly

                                font.pixelSize: Theme.fontNormal

                                background: Rectangle {
                                    radius: 2
                                    color: Theme.background
                                    border.color: Theme.border
                                }
                                color: Theme.text

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
                                text: qsTr("Card amount")
                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontSmall
                            }

                            TextField {
                                id: splitCardField
                                Layout.fillWidth: true
                                text: splitCardAmount
                                placeholderText: currencySymbol + "0.00"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly

                                font.pixelSize: Theme.fontNormal

                                background: Rectangle {
                                    radius: 2
                                    color: Theme.background
                                    border.color: Theme.border
                                }
                                color: Theme.text

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

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Theme.border
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: qsTr("Subtotal")
                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontSmall
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: selectedSession ? formatMoney(selectedSession.subtotal) : ""
                                    color: Theme.text
                                    font.pixelSize: Theme.fontSmall
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: qsTr("Tax")
                                    color: Theme.secondaryText
                                    font.pixelSize: Theme.fontSmall
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: selectedSession ? formatMoney(selectedSession.tax) : ""
                                    color: Theme.text
                                    font.pixelSize: Theme.fontSmall
                                }
                            }

                            RowLayout {
                                visible: redeemDiscountPreview > 0
                                Layout.fillWidth: true
                                Text {
                                    text: qsTr("Discount")
                                    color: Theme.orange
                                    font.pixelSize: Theme.fontSmall
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: selectedSession ? "-" + formatMoney(redeemDiscountPreview) : ""
                                    color: Theme.orange
                                    font.pixelSize: Theme.fontSmall
                                    font.bold: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: qsTr("Total")
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: selectedSession ? formatMoney(finalTotalPreview) : ""
                                    color: Theme.text
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal + 2
                                }
                            }
                        }

                        Text {
                            visible: hasOpenSelection && !canCheckout
                            text: qsTr("Kitchen items are still pending.")
                            color: Theme.orange
                            font.pixelSize: Theme.fontSmall
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: hasOpenSelection && canCheckout && !paymentReady
                            text: qsTr("Choose a payment method to continue.")
                            color: Theme.secondaryText
                            font.pixelSize: Theme.fontSmall
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            text: qsTr("Checkout")
                            enabled: checkoutReady
                            hoverEnabled: false
                            focusPolicy: Qt.NoFocus

                            background: Rectangle {
                                radius: 10
                                color: parent.enabled ? Theme.primary() : Theme.background
                            }

                            contentItem: Text {
                                text: qsTr("Checkout")
                                color: parent.enabled ? "white" : Theme.secondaryText
                                font.bold: true
                                font.pixelSize: Theme.fontNormal
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: performCheckout()
                        }
                    }
                }

                // Paid ticket reprint panel
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14
                    visible: hasPaidSelection

                    Text {
                        text: qsTr("Receipt")
                        color: Theme.text
                        font.bold: true
                        font.pixelSize: Theme.fontNormal + 2
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: qsTr("Subtotal")
                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontSmall
                                Layout.fillWidth: true
                            }
                            Text {
                                text: selectedRecentDetails ? formatMoney(selectedRecentDetails.subtotal) : ""
                                color: Theme.text
                                font.pixelSize: Theme.fontSmall
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: qsTr("Tax")
                                color: Theme.secondaryText
                                font.pixelSize: Theme.fontSmall
                                Layout.fillWidth: true
                            }
                            Text {
                                text: selectedRecentDetails ? formatMoney(selectedRecentDetails.tax) : ""
                                color: Theme.text
                                font.pixelSize: Theme.fontSmall
                            }
                        }

                        RowLayout {
                            visible: selectedRecentDetails && selectedRecentDetails.discount > 0
                            Layout.fillWidth: true
                            Text {
                                text: qsTr("Discount")
                                color: Theme.orange
                                font.pixelSize: Theme.fontSmall
                                font.bold: true
                                Layout.fillWidth: true
                            }
                            Text {
                                text: selectedRecentDetails ? "-" + formatMoney(selectedRecentDetails.discount) : ""
                                color: Theme.orange
                                font.pixelSize: Theme.fontSmall
                                font.bold: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: qsTr("Total")
                                color: Theme.text
                                font.bold: true
                                font.pixelSize: Theme.fontNormal
                                Layout.fillWidth: true
                            }
                            Text {
                                text: selectedRecentDetails ? formatMoney(selectedRecentDetails.total) : ""
                                color: Theme.green
                                font.bold: true
                                font.pixelSize: Theme.fontNormal + 2
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        hoverEnabled: false
                        focusPolicy: Qt.NoFocus

                        background: Rectangle {
                            radius: 10
                            color: Theme.primary()
                        }

                        contentItem: Text {
                            text: qsTr("Reprint receipt")
                            color: "white"
                            font.bold: true
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            CheckoutService.printReceipt(selectedRecentDetails.id, true)
                        }
                    }
                }
            }
        }
    }
}
