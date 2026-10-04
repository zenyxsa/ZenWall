import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: root

    property int mediaMode: 0
    property bool favoritesOnly: false
    property int colorFilter: -1
    property int sortMode: 0
    property string selectedOutput: ""
    property var availableOutputs: []
    property int rotationMinutes: 0

    property int visibleCount: 0
    property int totalCount: 0
    property string folderPath: ""

    property bool searchOpen: false

    signal mediaModeRequested(int mode)
    signal favoritesRequested(bool enabled)
    signal colorFilterRequested(int index)
    signal sortRequested()
    signal randomRequested()
    signal rotationRequested()
    signal outputRequested(string output)
    signal searchChanged(string query)
    signal folderSelected(string path)
    signal closeRequested()

    height: 58
    implicitWidth: controlRow.implicitWidth + 20

    RowLayout {
        id: controlRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        spacing: 3

        SkewBarButton {
            label: "ALL"
            active: root.mediaMode === 0

            onClicked: root.mediaModeRequested(0)
        }

        SkewBarButton {
            label: "PIC"
            active: root.mediaMode === 1

            onClicked: root.mediaModeRequested(1)
        }

        SkewBarButton {
            label: "VID"
            active: root.mediaMode === 2

            onClicked: root.mediaModeRequested(2)
        }

        SkewBarButton {
            label: "GIF"
            active: root.mediaMode === 3

            onClicked: root.mediaModeRequested(3)
        }

        SkewBarButton {
            label: root.sortMode === 0 ? "NEW" : "NAME"
            icon: "↕"

            onClicked: root.sortRequested()
        }

        SkewBarButton {
            label: "FAV"
            icon: "♥"
            active: root.favoritesOnly

            onClicked: {
                root.favoritesOnly = !root.favoritesOnly
                root.favoritesRequested(root.favoritesOnly)
            }
        }

        SkewBarButton {
            label: "RAND"
            icon: "⤨"

            onClicked: root.randomRequested()
        }

        SkewBarButton {
            label: root.selectedOutput === ""
                ? "ALL"
                : root.selectedOutput
            icon: "▣"

            onClicked: outputPopup.open()
        }

        SkewBarButton {
            label: rotationMinutes === 0
                ? "ROTATE"
                : (rotationMinutes === 60
                   ? "1H"
                   : rotationMinutes + "M")
            icon: "◷"
            active: rotationMinutes > 0

            onClicked: root.rotationRequested()
        }

        Item {
            Layout.preferredWidth: 10
        }

        Repeater {
            model: [
                "#d85858",
                "#e58b4a",
                "#dfc75a",
                "#72b85d",
                "#55b5a8",
                "#5f90d8",
                "#8c78d6",
                "#bd6ca8"
            ]

            Rectangle {
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18

                radius: 9
                color: modelData

                border.width:
                    index === root.colorFilter ? 2 : 0

                border.color: "white"

                MouseArea {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

                    onClicked: {
                        const next =
                            root.colorFilter === index
                                ? -1
                                : index

                        root.colorFilter = next
                        root.colorFilterRequested(next)
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        TextField {
            id: searchField

            visible: root.searchOpen

            Layout.preferredWidth: 220
            Layout.preferredHeight: 38

            placeholderText: "Search wallpapers…"

            color: "white"
            placeholderTextColor: "#70727a"

            background: Rectangle {
                color: "#181a20cc"
                radius: 8
                border.color: "#ffffff18"
            }

            onTextChanged:
                root.searchChanged(text)

            Keys.onEscapePressed: {
                text = ""
                root.searchOpen = false
                root.forceActiveFocus()
            }

            Component.onCompleted: {
                if (root.searchOpen)
                    forceActiveFocus()
            }
        }

        SkewBarButton {
            visible: !root.searchOpen

            label: "SEARCH"
            icon: "⌕"

            onClicked: {
                root.searchOpen = true
                searchField.forceActiveFocus()
            }
        }

        SkewBarButton {
            label: "SETTINGS"
            icon: "⚙"

            onClicked: settingsPopup.open()
        }

        SkewBarButton {
            label: "×"

            onClicked: root.closeRequested()
        }

        Rectangle {
            Layout.preferredWidth: 72
            Layout.preferredHeight: 28

            color: "#181a20bb"
            border.color: "#ffffff12"
            border.width: 1

            Text {
                anchors.centerIn: parent

                text: root.visibleCount +
                      " / " +
                      root.totalCount

                color: "#a3a5ad"
                font.pixelSize: 11
                font.bold: true
            }
        }
    }

    Popup {
        id: outputPopup

        width: 260
        height: Math.min(
            80 + root.availableOutputs.length * 44,
            360
        )

        x: 220
        y: 66

        padding: 12

        background: Rectangle {
            color: "#15171ccc"
            radius: 14
            border.color: "#ffffff18"
        }

        Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                text: "DISPLAY"
                color: "#8f9199"
                font.pixelSize: 11
                font.bold: true
            }

            Button {
                width: parent.width
                text: "All displays"
                onClicked: {
                    root.selectedOutput = ""
                    root.outputRequested("")
                    outputPopup.close()
                }
            }

            Repeater {
                model: root.availableOutputs

                Button {
                    width: parent.width
                    text: modelData

                    onClicked: {
                        root.selectedOutput = modelData
                        root.outputRequested(modelData)
                        outputPopup.close()
                    }
                }
            }
        }
    }

    Popup {
        id: settingsPopup

        width: 420
        height: 210

        x: parent.width - width - 20
        y: 66

        padding: 18

        background: Rectangle {
            color: "#15171ccc"
            radius: 14
            border.color: "#ffffff18"
        }

        ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Text {
                text: "ZenWall Settings"
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }

            Text {
                text: "Wallpaper folder"
                color: "#9b9da5"
                font.pixelSize: 12
            }

            Text {
                text: root.folderPath
                color: "#d5d6db"
                Layout.fillWidth: true

                elide: Text.ElideMiddle
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    text: "Choose folder"

                    onClicked:
                        folderDialog.open()
                }

                Button {
                    text: "Close"

                    onClicked:
                        settingsPopup.close()
                }
            }
        }
    }

    FolderDialog {
        id: folderDialog

        title: "Choose ZenWall wallpaper folder"

        onAccepted: {
            root.folderSelected(String(selectedFolder))
            settingsPopup.close()
        }
    }
}
