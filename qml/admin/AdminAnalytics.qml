import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Xeno.Services 1.0

Item {
    id: analyticsPage
    anchors.fill: parent

    property var snapshot: AnalyticsService.getSnapshot()

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
                    color: "#181818"
                    border.color: "#2c2c2c"

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Label {
                            text: "Revenue Today"
                            color: "#ffffff"
                            opacity: 0.7
                        }
                        Label {
                            text: "RM " + Number(
                                      snapshot.revenueToday).toFixed(2)
                            font.pixelSize: 28
                            font.bold: true
                            color: "#9a7bff"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    radius: 6
                    color: "#181818"
                    border.color: "#2c2c2c"

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Label {
                            text: "Orders"
                            color: "#ffffff"
                            opacity: 0.7
                        }
                        Label {
                            text: snapshot.ordersToday
                            font.pixelSize: 28
                            font.bold: true
                            color: "#ffffff"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    radius: 6
                    color: "#181818"
                    border.color: "#2c2c2c"

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Label {
                            text: "Average Order"
                            color: "#ffffff"
                            opacity: 0.7
                        }
                        Label {
                            text: "RM " + Number(
                                      snapshot.averageOrder).toFixed(2)
                            font.pixelSize: 28
                            font.bold: true
                            color: "#ffffff"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    radius: 6
                    color: "#181818"
                    border.color: "#2c2c2c"

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Label {
                            text: "Items Sold"
                            color: "#ffffff"
                            opacity: 0.7
                        }
                        Label {
                            text: snapshot.itemsSold
                            font.pixelSize: 28
                            font.bold: true
                            color: "#ffffff"
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
                    color: "#181818"
                    border.color: "#2c2c2c"
                    implicitHeight: 220

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Label {
                            text: "Top Items Today"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#ffffff"
                        }

                        Repeater {
                            model: snapshot.topItems
                            RowLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: (index + 1) + ". " + modelData.name
                                    Layout.fillWidth: true
                                    color: "#ffffff"
                                }

                                Label {
                                    text: modelData.count
                                    font.bold: true
                                    color: "#ffffff"
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 6
                    color: "#181818"
                    border.color: "#2c2c2c"
                    implicitHeight: 220

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Label {
                            text: "Revenue by Hour"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#ffffff"
                        }

                        Repeater {
                            model: snapshot.revenueByHour
                            RowLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: modelData.hour + ":00"
                                    Layout.fillWidth: true
                                    color: "#ffffff"
                                }

                                Label {
                                    text: "RM " + Number(
                                              modelData.amount).toFixed(2)
                                    font.bold: true
                                    color: "#ffffff"
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 6
                color: "#181818"
                border.color: "#2c2c2c"
                implicitHeight: 260

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Label {
                        text: "Last 7 Days Revenue"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#ffffff"
                    }

                    Repeater {
                        model: snapshot.last7Days
                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                text: modelData.day
                                Layout.fillWidth: true
                                color: "#ffffff"
                            }

                            Label {
                                text: "RM " + Number(
                                          modelData.amount).toFixed(2)
                                font.bold: true
                                color: "#ffffff"
                            }
                        }
                    }
                }
            }
        }
    }
}
