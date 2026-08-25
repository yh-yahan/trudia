import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    width: 900
    height: 600

    Component.onCompleted: {
        MemberService.loadMembers()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: qsTr("Member Management")
                font.pixelSize: Theme.fontLarge
                font.bold: true
                color: Theme.text
                Layout.fillWidth: true
            }
        }

        TextField {
            id: searchField

            Layout.fillWidth: true

            placeholderText: qsTr("Search phone number")
            color: Theme.text
            placeholderTextColor: Theme.secondaryText

            background: Rectangle {
                color: Theme.surface
                radius: 4
            }

            leftPadding: 10
            rightPadding: 10

            onTextChanged: {
                MemberService.searchMembers(text)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: Theme.background
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8

                Text {
                    text: qsTr("Phone Number")
                    color: Theme.secondaryText
                    font.bold: true
                    font.pixelSize: Theme.fontSmall
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr("Points")
                    color: Theme.secondaryText
                    font.bold: true
                    font.pixelSize: Theme.fontSmall
                    Layout.preferredWidth: 120
                }

                Text {
                    text: qsTr("Status")
                    color: Theme.secondaryText
                    font.bold: true
                    font.pixelSize: Theme.fontSmall
                    Layout.preferredWidth: 120
                }

                Text {
                    text: qsTr("Actions")
                    color: Theme.secondaryText
                    font.bold: true
                    font.pixelSize: Theme.fontSmall
                    Layout.preferredWidth: 300
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: MemberService.membersModel

            clip: true
            spacing: 4

            delegate: Rectangle {
                width: ListView.view.width
                height: 44
                radius: 4
                color: Theme.background

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        memberDialog.memberId = id
                        memberDialog.open()
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    Text {
                        text: phoneNumber
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        Layout.fillWidth: true
                    }

                    Text {
                        text: totalPoints
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                        Layout.preferredWidth: 120
                    }

                    Text {
                        text: status
                        color: status === "active"
                            ? Theme.green
                            : Theme.error()

                        font.pixelSize: Theme.fontNormal
                        Layout.preferredWidth: 120
                    }

                    RowLayout {
                        Layout.preferredWidth: 300
                        spacing: 4

                        Button {
                            text: qsTr("Add Points")

                            enabled: status === "active"
                            opacity: enabled ? 1.0 : 0.45

                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 5
                            bottomPadding: 5

                            background: Rectangle {
                                radius: 4
                                color: "#5bb8d6"
                            }

                            contentItem: Text {
                                text: qsTr("Add Points")
                                color: "white"
                                anchors.centerIn: parent
                                font.pixelSize: Theme.fontNormal
                            }

                            onClicked: {
                                pointsDialog.memberId = id
                                pointsDialog.memberPhone = phoneNumber
                                pointsDialog.mode = "add"
                                pointsDialog.open()
                            }
                        }
                        Button {
                            text: qsTr("Redeem")

                            enabled: status === "active"
                            opacity: enabled ? 1.0 : 0.45

                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 5
                            bottomPadding: 5

                            background: Rectangle {
                                radius: 4
                                color: "#4faba1"
                            }

                            contentItem: Text {
                                text: qsTr("Redeem")
                                color: "white"
                                anchors.centerIn: parent
                                font.pixelSize: Theme.fontNormal
                            }

                            onClicked: {
                                pointsDialog.memberId = id
                                pointsDialog.memberPhone = phoneNumber
                                pointsDialog.mode = "redeem"
                                pointsDialog.open()
                            }
                        }
                        Button {
                            text: qsTr("Edit")

                            enabled: status === "active"
                            opacity: enabled ? 1.0 : 0.45

                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 5
                            bottomPadding: 5

                            background: Rectangle {
                                radius: 4
                                color: "#ffaa66"
                            }

                            contentItem: Text {
                                text: qsTr("Edit")
                                color: "white"
                                anchors.centerIn: parent
                                font.pixelSize: Theme.fontNormal
                            }

                            onClicked: {
                                editMemberDialog.memberId = id
                                editMemberDialog.open()
                            }
                        }
                        Button {
                            text: qsTr("Revoke")

                            enabled: status === "active"
                            opacity: enabled ? 1.0 : 0.45

                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 5
                            bottomPadding: 5

                            background: Rectangle {
                                radius: 4
                                color: "#5F7DDC"
                            }

                            contentItem: Text {
                                text: qsTr("Revoke")
                                color: "white"
                                anchors.centerIn: parent
                                font.pixelSize: Theme.fontNormal
                            }

                            onClicked: {
                                revokeDialog.memberId = id
                                revokeDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    // member dialog
    Dialog {
        id: memberDialog

        property int memberId: 0
        property var member

        anchors.centerIn: Overlay.overlay

        width: 700
        height: 500
        modal: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16

            Label {
                text: qsTr("Member Phone: %1").arg(memberDialog.member.phoneNumber)
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            Label {
                text: qsTr("Points: %1").arg(memberDialog.member.totalPoints)
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            Label {
                text: qsTr("Status: %1").arg(memberDialog.member.status)
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            Label {
                text: qsTr("Transactions")
                font.bold: true
                font.pixelSize: Theme.fontLarge
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                border.width: 1
                border.color: Theme.border
                radius: 4
                color: Theme.surface

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        color: Theme.surfaceVariant

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            Label {
                                Layout.preferredWidth: 120
                                text: qsTr("Type")
                                font.bold: true
                            }

                            Label {
                                Layout.preferredWidth: 80
                                text: qsTr("Points")
                                font.bold: true
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }

                            Label {
                                Layout.preferredWidth: 120
                                text: qsTr("Source")
                                font.bold: true
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }

                            Label {
                                Layout.fillWidth: true
                                text: qsTr("Date")
                                font.bold: true
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        clip: true
                        model: MemberService.transactionModel

                        ScrollBar.vertical: ScrollBar {}

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 40

                            color: index % 2 === 0
                                ? Theme.background
                                : Theme.surface

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8

                                Label {
                                    Layout.preferredWidth: 120
                                    text: type === "earn"
                                        ? qsTr("Earn")
                                        : qsTr("Redeem")
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }

                                Label {
                                    Layout.preferredWidth: 80
                                    text: (type === "redeem" ? "-" : "+") + points
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }

                                Label {
                                    Layout.preferredWidth: 120
                                    text: orderDisplayNumber > 0
                                        ? "#" + orderDisplayNumber
                                        : qsTr("Manual")
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }

                                Label {
                                    Layout.fillWidth: true
                                    text: Qt.formatDateTime(
                                        createdAt,
                                        "dd/MM/yyyy hh:mm"
                                    )
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }
                            }
                        }
                    }
                }
            }
        }

        onOpened: {
            member = MemberService.getMemberDetails(memberId)
            MemberService.loadTransactions(memberId)
        }

        background: Rectangle {
            color: Theme.background
            radius: 6
        }
    }

    // points dialog
    Dialog {
        id: pointsDialog

        property int memberId: 0
        property string memberPhone: ""
        property string mode: "add"
        property var member: ({})

        anchors.centerIn: Overlay.overlay

        width: 400
        height: 300
        modal: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: pointsDialog.mode === "add" ? qsTr("Add Points") : qsTr("Redeem Points")
                font.pixelSize: Theme.fontLarge
                font.bold: true
                color: Theme.text
            }

            Label {
                text: pointsDialog.mode === "add"
                    ? qsTr("Add points to member.")
                    : qsTr("Redeem points from member.")

                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            Label {
                text: qsTr("Member: %1").arg(pointsDialog.member.phoneNumber || "")

                color: Theme.secondaryText
                font.pixelSize: Theme.fontSmall
            }

            Label {
                text: qsTr("Available points: %1").arg(pointsDialog.member.totalPoints || 0)

                color: Theme.secondaryText
                font.pixelSize: Theme.fontSmall
            }

            TextField {
                id: pointsField

                Layout.fillWidth: true

                placeholderText: qsTr("Points")
                color: Theme.text

                validator: IntValidator {
                    bottom: 1
                }

                inputMethodHints: Qt.ImhDigitsOnly

                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                }
            }

            Label {
                id: pointsError

                Layout.fillWidth: true

                visible: false

                color: Theme.error()
                font.pixelSize: Theme.fontSmall
                wrapMode: Text.WordWrap
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: pointsDialog.mode === "add" ? qsTr("Add Points") : qsTr("Redeem")

                    background: Rectangle {
                        color: Theme.primary()
                        radius: 4
                    }

                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15

                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus

                    contentItem: Text {
                        text: pointsDialog.mode === "add" ? qsTr("Add Points") : qsTr("Redeem")
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontNormal
                    }

                    onClicked: {
                        var points = parseInt(pointsField.text)

                        if (isNaN(points) || points <= 0) {
                            pointsError.text = qsTr("Please enter a valid number of points.")
                            pointsError.visible = true
                            return
                        }

                        if (pointsDialog.mode === "redeem" &&
                            points > pointsDialog.member.totalPoints) {

                            pointsError.text = qsTr("Not enough points.")
                            pointsError.visible = true
                            return
                        }

                        var success = false

                        if (pointsDialog.mode === "add") {
                            success = MemberService.manualAddPoints(
                                pointsDialog.memberId,
                                points
                            )
                        } else {
                            success = MemberService.manualRedeemPoints(
                                pointsDialog.memberId,
                                points
                            )
                        }

                        if (!success) {
                            pointsError.text = pointsDialog.mode === "add"
                                    ? qsTr("Failed to add points.")
                                    : qsTr("Failed to redeem points.")

                            pointsError.visible = true
                            return
                        }

                        pointsDialog.close()

                        MemberService.loadMembers()
                    }
                }

                Button {
                    text: qsTr("Cancel")

                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    background: Rectangle {
                        color: '#6b6b6b'
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("Cancel")
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontNormal
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus

                    onClicked: {
                        pointsDialog.close()
                    }
                }
            }
        }

        onOpened: {
            member = MemberService.getMemberDetails(memberId)

            pointsField.clear()
            pointsError.visible = false
        }

        background: Rectangle {
            color: Theme.background
            radius: 6
        }
    }

    // edit member dialog
    Dialog {
        id: editMemberDialog

        property int memberId: 0
        property var member

        anchors.centerIn: Overlay.overlay

        width: 400
        height: 240
        modal: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: qsTr("Edit Member")
                font.pixelSize: Theme.fontLarge
                font.bold: true
                color: Theme.text
            }

            Label {
                text: qsTr("Phone Number")
                color: Theme.secondaryText
                font.pixelSize: Theme.fontSmall
            }

            TextField {
                id: editPhoneField

                Layout.fillWidth: true

                color: Theme.text
                placeholderText: qsTr("Phone number")

                background: Rectangle {
                    color: Theme.surface
                    radius: 4
                }
            }

            Label {
                id: editMemberError

                visible: false
                text: qsTr("Please enter a phone number.")
                color: Theme.error()
                font.pixelSize: Theme.fontSmall
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Save")

                    background: Rectangle {
                        color: Theme.primary()
                        radius: 4
                    }

                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15

                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus

                    contentItem: Text {
                        text: qsTr("Save")
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontNormal
                    }

                    onClicked: {
                        var phone = editPhoneField.text.trim()

                        if (phone.length === 0) {
                            editMemberError.text = qsTr("Please enter a phone number.")
                            editMemberError.visible = true
                            return
                        }

                        editMemberError.visible = false

                        var success = MemberService.editMember(editMemberDialog.memberId, phone)

                        if (!success) {
                            editMemberError.text = qsTr("Failed to update member.")
                            editMemberError.visible = true
                            return
                        }

                        editMemberDialog.close()

                        MemberService.loadMembers()
                    }
                }

                Button {
                    text: qsTr("Cancel")

                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    background: Rectangle {
                        color: '#6b6b6b'
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("Cancel")
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontNormal
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus

                    onClicked: {
                        editMemberDialog.close()
                    }
                }
            }
        }

        onOpened: {
            member = MemberService.getMemberDetails(memberId)

            editPhoneField.text = member.phoneNumber

            editMemberError.visible = false
        }

        background: Rectangle {
            color: Theme.background
            radius: 6
        }
    }

    // revoke dialog
    Dialog {
        id: revokeDialog

        property int memberId: 0
        property var member

        anchors.centerIn: Overlay.overlay

        width: 400
        height: 260
        modal: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: qsTr("Revoke Member")
                font.pixelSize: Theme.fontLarge
                font.bold: true
                color: Theme.text
            }

            Label {
                Layout.fillWidth: true

                text: qsTr("Are you sure you want to revoke member %1?").arg(revokeDialog.member.phoneNumber)

                wrapMode: Text.WordWrap
                color: Theme.text
                font.pixelSize: Theme.fontNormal
            }

            Label {
                Layout.fillWidth: true

                text: qsTr("The member will no longer be able to earn or redeem points.")

                wrapMode: Text.WordWrap
                color: Theme.secondaryText
                font.pixelSize: Theme.fontSmall
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Revoke")

                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15

                    background: Rectangle {
                        color: "#e53935"
                        radius: 4
                    }

                    contentItem: Text {
                        text: qsTr("Revoke")
                        color: "white"
                        anchors.centerIn: parent
                        font.bold: true
                        font.pixelSize: Theme.fontNormal
                    }

                    onClicked: {
                        var success = MemberService.revokeMember(revokeDialog.memberId)

                        if (!success) return

                        revokeDialog.close()

                        MemberService.loadMembers()
                    }
                }

                Button {
                    text: qsTr("Cancel")

                    leftPadding: 15
                    rightPadding: 15
                    topPadding: 5
                    bottomPadding: 5
                    Layout.topMargin: 15
                    background: Rectangle {
                        color: '#6b6b6b'
                        radius: 4
                    }
                    contentItem: Text {
                        text: qsTr("Cancel")
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontNormal
                    }
                    hoverEnabled: false
                    focusPolicy: Qt.NoFocus

                    onClicked: {
                        revokeDialog.close()
                    }
                }
            }
        }

        onOpened: {
            member = MemberService.getMemberDetails(memberId)
        }

        background: Rectangle {
            color: Theme.background
            radius: 6
        }
    }
}
