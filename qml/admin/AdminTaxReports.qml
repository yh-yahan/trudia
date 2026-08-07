import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import trudia.Theme 1.0
import Trudia.Services 1.0

Item {
    id: root

    property var summary: ({})
    property var dailyBreakdown: []
    property var sessions: []

    property date fromDate: new Date()
    property date toDate: new Date()

    property string currencySymbol: SettingService.currencySymbol()

    function loadReport() {
        summary = TaxReportService.getSummary(fromDate, toDate)
        dailyBreakdown = TaxReportService.getDailyBreakdown(fromDate, toDate)
        sessions = TaxReportService.getSessions(fromDate, toDate)
    }

    function loadPreset(preset) {
        var today = new Date()
        var start = new Date(today)
        var end = new Date(today)

        if (preset === "today") {
            // already today
        } else if (preset === "yesterday") {
            start.setDate(start.getDate() - 1)
            end.setDate(end.getDate() - 1)
        } else if (preset === "week") {
            var day = start.getDay()
            var daysFromMonday = day === 0 ? 6 : day - 1
            start.setDate(start.getDate() - daysFromMonday)
        } else if (preset === "month") {
            start = new Date(today.getFullYear(), today.getMonth(), 1)
        } else if (preset === "lastMonth") {
            start = new Date(today.getFullYear(), today.getMonth() - 1, 1)
            end = new Date(today.getFullYear(), today.getMonth(), 0)
        }

        fromDate = start
        toDate = end

        loadReport()
    }

    function loadCustomRange() {
        var from = new Date(fromField.text + "T00:00:00")
        var to = new Date(toField.text + "T00:00:00")

        if (isNaN(from.getTime()) || isNaN(to.getTime()))
            return

        if (from > to)
            return

        fromDate = from
        toDate = to

        loadReport()
    }

    function formatMoney(value) {
        return Number(value || 0) / 100
    }

    function formatMoneyString(value) {
        return formatMoney(value).toFixed(2)
    }

    function formatDate(dateString) {
        if (!dateString)
            return ""

        var parts = dateString.split("-")

        if (parts.length !== 3)
            return dateString

        return parts[2] + "/" + parts[1] + "/" + parts[0]
    }

    Component.onCompleted: {
        loadPreset("today")
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Column {
                spacing: 2

                Label {
                    text: qsTr("Tax Report")
                    color: Theme.text
                    font.pixelSize: Theme.fontXL
                    font.bold: true
                }

                Label {
                    text: summary.from && summary.to
                          ? formatDate(summary.from) + " - " + formatDate(summary.to)
                          : qsTr("Select a date range")
                    color: Theme.text
                    opacity: 0.7
                    font.pixelSize: Theme.fontLarge
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Today")
                onClicked: loadPreset("today")
            }

            Button {
                text: qsTr("Yesterday")
                onClicked: loadPreset("yesterday")
            }

            Button {
                text: qsTr("This Week")
                onClicked: loadPreset("week")
            }

            Button {
                text: qsTr("This Month")
                onClicked: loadPreset("month")
            }

            Button {
                text: qsTr("Last Month")
                onClicked: loadPreset("lastMonth")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            radius: 6
            color: Theme.background
            border.color: Theme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 10

                Label {
                    text: qsTr("From")
                    color: Theme.text
                }

                TextField {
                    id: fromField

                    Layout.preferredWidth: 130
                    text: Qt.formatDate(root.fromDate, "yyyy-MM-dd")
                    placeholderText: "yyyy-MM-dd"

                    onEditingFinished: {
                        root.loadCustomRange()
                    }
                }

                Label {
                    text: qsTr("To")
                    color: Theme.text
                }

                TextField {
                    id: toField

                    Layout.preferredWidth: 130
                    text: Qt.formatDate(root.toDate, "yyyy-MM-dd")
                    placeholderText: "yyyy-MM-dd"

                    onEditingFinished: {
                        root.loadCustomRange()
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 6
                color: Theme.background
                border.color: Theme.border

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Sales Before Tax")
                        color: Theme.text
                        font.pixelSize: Theme.fontLarge
                        opacity: 0.7
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: currencySymbol + formatMoneyString(summary.subtotal)
                        color: Theme.text
                        font.pixelSize: Theme.fontXL
                        font.bold: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 6
                color: Theme.background
                border.color: Theme.border

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: summary.taxName || qsTr("Tax Collected")
                        color: Theme.text
                        font.pixelSize: Theme.fontLarge
                        opacity: 0.7
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: currencySymbol + formatMoneyString(summary.taxCollected)
                        color: Theme.text
                        font.pixelSize: Theme.fontXL
                        font.bold: true
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: summary.taxRate !== undefined
                        text: summary.taxRate !== undefined
                              ? summary.taxRate / 100 + "%"
                              : ""
                        color: Theme.text
                        opacity: 0.6
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 6
                color: Theme.background
                border.color: Theme.border

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Discount")
                        color: Theme.text
                        font.pixelSize: Theme.fontLarge
                        opacity: 0.7
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: currencySymbol + formatMoneyString(summary.discount)
                        color: Theme.text
                        font.pixelSize: Theme.fontXL
                        font.bold: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 6
                color: Theme.background
                border.color: Theme.border

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Total Sales")
                        color: Theme.text
                        font.pixelSize: Theme.fontLarge
                        opacity: 0.7
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: currencySymbol + formatMoneyString(summary.totalSales)
                        color: Theme.text
                        font.pixelSize: Theme.fontXL
                        font.bold: true
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: (summary.transactionCount || 0)
                              + " "
                              + qsTr("transactions")
                        color: Theme.text
                        opacity: 0.6
                    }
                }
            }
        }

        Label {
            text: qsTr("Daily Breakdown")
            color: Theme.text
            font.pixelSize: Theme.fontLarge
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 180
            radius: 6
            color: Theme.background
            border.color: Theme.border
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    color: Theme.surfaceVariant

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16

                        Label {
                            Layout.preferredWidth: 140
                            text: qsTr("Date")
                            font.bold: true
                            color: Theme.text
                        }

                        Label {
                            Layout.preferredWidth: 110
                            text: qsTr("Transactions")
                            font.bold: true
                            color: Theme.text
                        }

                        Label {
                            Layout.preferredWidth: 130
                            text: qsTr("Subtotal")
                            font.bold: true
                            color: Theme.text
                        }

                        Label {
                            Layout.preferredWidth: 130
                            text: qsTr("Tax")
                            font.bold: true
                            color: Theme.text
                        }

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Total")
                            font.bold: true
                            color: Theme.text
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.dailyBreakdown

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 42

                        color: index % 2 === 0
                               ? Theme.background
                               : Theme.surface

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16

                            Label {
                                Layout.preferredWidth: 140
                                text: formatDate(modelData.date)
                                color: Theme.text
                            }

                            Label {
                                Layout.preferredWidth: 110
                                text: modelData.transactionCount
                                color: Theme.text
                            }

                            Label {
                                Layout.preferredWidth: 130
                                text: currencySymbol + formatMoneyString(modelData.subtotal)
                                color: Theme.text
                            }

                            Label {
                                Layout.preferredWidth: 130
                                text: currencySymbol + formatMoneyString(modelData.taxCollected)
                                color: Theme.text
                            }

                            Label {
                                Layout.fillWidth: true
                                text: currencySymbol + formatMoneyString(modelData.totalSales)
                                color: Theme.text
                            }
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        visible: root.dailyBreakdown.length === 0
                        text: qsTr("No data for this period")
                        color: Theme.text
                        opacity: 0.6
                    }
                }
            }
        }
    }
}
