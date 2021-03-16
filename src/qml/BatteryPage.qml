import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import MeuiKit 1.0 as Meui
import Cutefish.Settings 1.0

ItemPage {
    id: batteryPage
    headerTitle: qsTr("Battery")

    property int historyType: BatteryHistoryModel.ChargeType
    readonly property var timespanComboChoices: [qsTr("Last hour"),qsTr("Last 2 hours"),qsTr("Last 12 hours"),qsTr("Last 24 hours"),qsTr("Last 48 hours"), qsTr("Last 7 days")]
    readonly property var timespanComboDurations: [3600, 7200, 43200, 86400, 172800, 604800]

    Battery {
        id: battery

        Component.onCompleted: {
            battery.refresh()
            batteryBackground.value = battery.chargePercent
        }
    }

    BatteryHistoryModel {
        id: history
        duration: timespanComboDurations[3]
        device: battery.udi
        type: BatteryHistoryModel.ChargeType
    }

    Connections {
        target: battery

        function onChargePercentChanged(value) {
            batteryBackground.value = battery.chargePercent
        }
    }

    Scrollable {
        anchors.fill: parent
        anchors.bottomMargin: Meui.Units.largeSpacing
        contentHeight: layout.implicitHeight
        visible: battery.available

        ColumnLayout {
            id: layout
            anchors.fill: parent
            spacing: Meui.Units.largeSpacing

            // Battery Info
            BatteryItem {
                id: batteryBackground
                Layout.fillWidth: true
                enableAnimation: !battery.onBattery
                height: 150

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: batteryBackground.radius + Meui.Units.smallSpacing

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Label {
                            id: percentLabel
                            text: battery.chargePercent
                            color: "white"
                            font.pointSize: 40
                            font.weight: Font.DemiBold
                        }

                        Label {
                            text: "%"
                            color: "white"
                            font.pointSize: 12
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        Image {
                            id: sensorsVoltage
                            width: 30
                            height: width
                            sourceSize: Qt.size(width, height)
                            source: "qrc:/images/sensors-voltage-symbolic.svg"
                            visible: !battery.onBattery
                        }
                    }

                    Label {
                        text: battery.statusString
                        color: "white"
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }

            Item {
                height: Meui.Units.largeSpacing
            }

            Label {
                text: qsTr("History")
                color: Meui.Theme.disabledTextColor
            }

            HistoryGraph {
                Layout.fillWidth: true
                height: 300

                data: history.points

                readonly property real xTicksAtDontCare: 0
                readonly property real xTicksAtTwelveOClock: 1
                readonly property real xTicksAtFullHour: 2
                readonly property real xTicksAtHalfHour: 3
                readonly property real xTicksAtFullSecondHour: 4
                readonly property real xTicksAtTenMinutes: 5
                readonly property var xTicksAtList: [xTicksAtTenMinutes, xTicksAtHalfHour, xTicksAtHalfHour,
                                                     xTicksAtFullHour, xTicksAtFullSecondHour, xTicksAtTwelveOClock]

                // Set grid lines distances which directly correspondent to the xTicksAt variables
                readonly property var xDivisionWidths: [1000 * 60 * 10, 1000 * 60 * 60 * 12, 1000 * 60 * 60, 1000 * 60 * 30, 1000 * 60 * 60 * 2, 1000 * 60 * 10]
                xTicksAt: xTicksAtList[4]
                xDivisionWidth: xDivisionWidths[xTicksAt]

                xMin: history.firstDataPointTime
                xMax: history.lastDataPointTime
                xDuration: history.duration

                yUnits: batteryPage.historyType === BatteryHistoryModel.RateType ? qsTr("W") : "%"
                yMax: {
                    if (batteryPage.historyType === BatteryHistoryModel.RateType) {
                        // ceil to nearest 10
                        var max = Math.floor(history.largestValue)
                        max = max - max % 10 + 10

                        return max;
                    } else {
                        return 100;
                    }
                }
                yStep: batteryPage.historyType === BatteryHistoryModel.RateType ? 10 : 20
                visible: history.count > 1
            }

            Item {
                height: Meui.Units.smallSpacing
            }

            StandardItem {
                key: qsTr("Last Charged to") + " " + battery.lastChargedPercent + "%"
                value: battery.lastChargedTime
                visible: battery.lastChargedPercent !== 0
            }

            StandardItem {
                key: qsTr("Maximum Capacity")
                value: battery.capacity + "%"
            }
        }
    }

    Label {
        anchors.centerIn: parent
        text: qsTr("No battery found")
        visible: !battery.available
    }
}
