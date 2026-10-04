import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property string label: ""
    property string icon: ""
    property bool active: false
    property bool hovered: mouseArea.containsMouse

    signal clicked()

    implicitWidth: contentRow.implicitWidth + 26
    implicitHeight: 46
    width: implicitWidth
    height: implicitHeight

    property color baseColor: active
        ? "#9f8cff33"
        : hovered
            ? "#2b3040ff"
            : "#171a24f7"

    property color borderColor: active
        ? "#b9a8ff99"
        : hovered
            ? "#6f7890aa"
            : "#454b5d88"

    property color mainTextColor: active
        ? "#ffffff"
        : "#ffffff"

    property color secondaryTextColor: active
        ? "#ffffff"
        : "#f0f2f7"

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            fillColor: root.baseColor
            strokeColor: root.borderColor
            strokeWidth: 1.2

            startX: 9
            startY: 0

            PathLine {
                x: root.width
                y: 0
            }

            PathLine {
                x: root.width - 9
                y: root.height
            }

            PathLine {
                x: 0
                y: root.height
            }

            PathLine {
                x: 9
                y: 0
            }
        }
    }

    Rectangle {
        visible: root.active
        anchors.left: parent.left
        anchors.leftMargin: 7
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: 22
        radius: 1.5
        color: "#c7b7ff"
        opacity: 0.95
    }

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: 4

        Text {
            visible: root.icon.length > 0
            text: root.icon
            color: root.secondaryTextColor
            font.pixelSize: 15
            font.weight: Font.DemiBold
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: root.label
            color: root.mainTextColor
            font.pixelSize: 12
            font.weight: root.active ? Font.DemiBold : Font.Medium
            font.letterSpacing: 0.6
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        visible: root.hovered
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        width: parent.width * 0.55
        height: 2
        radius: 1
        color: "#b9a8ff"
        opacity: 0.55
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
