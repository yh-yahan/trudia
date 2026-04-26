import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Trudia.Services 1.0
import trudia.Theme 1.0

Item {
    id: analyticsPage
    anchors.fill: parent

    property var snapshot: AnalyticsService.getSnapshot()
    property string currencySymbol: SettingService.currencySymbol()

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: rootColumn.implicitHeight
        clip: true

        ColumnLayout {
            id: rootColumn
            width: parent.width
            spacing: 24

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

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
                            text: qsTr("Revenue Today")
                            color: Theme.text
                            font.pixelSize: Theme.fontLarge
                            opacity: 0.7
                        }
                        Label {
                            text: currencySymbol + Number(
                                      snapshot.revenueToday).toFixed(2)
                            font.pixelSize: Theme.fontXL
                            font.bold: true
                            color: Theme.primary()
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
                            text: qsTr("Orders")
                            color: Theme.text
                            font.pixelSize: Theme.fontLarge
                            opacity: 0.7
                        }
                        Label {
                            text: snapshot.ordersToday
                            font.pixelSize: Theme.fontXL
                            font.bold: true
                            color: Theme.text
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
                            text: qsTr("Average Order")
                            color: Theme.text
                            font.pixelSize: Theme.fontLarge
                            opacity: 0.7
                        }
                        Label {
                            text: currencySymbol + Number(
                                      snapshot.averageOrder).toFixed(2)
                            font.pixelSize: Theme.fontXL
                            font.bold: true
                            color: Theme.text
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
                            text: qsTr("Items Sold")
                            color: Theme.text
                            font.pixelSize: Theme.fontLarge
                            opacity: 0.7
                        }
                        Label {
                            text: snapshot.itemsSold
                            font.pixelSize: Theme.fontXL
                            font.bold: true
                            color: Theme.text
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    radius: 6
                    color: Theme.background
                    border.color: Theme.border
                    implicitHeight: 220

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Label {
                            text: qsTr("Top Items Today")
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                            color: Theme.text
                        }

                        Repeater {
                            model: snapshot.topItems
                            RowLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: (index + 1) + ". " + modelData.name
                                    Layout.fillWidth: true
                                    font.pixelSize: Theme.fontNormal
                                    color: Theme.text
                                }

                                Label {
                                    text: modelData.count
                                    font.bold: true
                                    font.pixelSize: Theme.fontNormal
                                    color: Theme.text
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 6
                    color: Theme.background
                    border.color: Theme.border
                    implicitHeight: 220

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Label {
                            text: qsTr("Revenue by Hour")
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                            color: Theme.text
                        }

                        Repeater {
                            model: snapshot.revenueByHour
                            RowLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: modelData.hour + ":00"
                                    Layout.fillWidth: true
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }

                                Label {
                                    text: currencySymbol + Number(
                                              modelData.amount).toFixed(2)
                                    font.bold: true
                                    color: Theme.text
                                    font.pixelSize: Theme.fontNormal
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 6
                color: Theme.background
                border.color: Theme.border
                implicitHeight: 320

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Label {
                        text: qsTr("Last 7 Days Revenue")
                        font.bold: true
                        color: Theme.text
                        font.pixelSize: Theme.fontNormal
                    }

                    Repeater {
                        model: snapshot.last7Days
                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                text: modelData.day
                                Layout.fillWidth: true
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }

                            Label {
                                text: currencySymbol + Number(
                                          modelData.amount).toFixed(2)
                                font.bold: true
                                color: Theme.text
                                font.pixelSize: Theme.fontNormal
                            }
                        }
                    }
                }
            }
        }
    }
}
