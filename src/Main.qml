import QtQuick
import QtQuick.Controls

Window {
    id: root

    visible: true
    visibility: Window.FullScreen

    flags:
        Qt.FramelessWindowHint |
        Qt.WindowStaysOnTopHint |
        Qt.Tool

    color: "transparent"

    TopBar {
        id: topBar

        anchors.horizontalCenter: parent.horizontalCenter
        y: (root.height - 400) / 2 - height - 32
        width: implicitWidth
        z: 100

        visibleCount: skewView.visibleCount
        totalCount: skewView.totalCount
        folderPath: skewView.wallpaperFolder
        rotationMinutes: skewView.rotationMinutes
        selectedOutput: skewView.selectedOutput
        availableOutputs: skewView.availableOutputs

        onMediaModeRequested: mode => {
            skewView.setMediaMode(mode)
        }

        onFavoritesRequested: enabled => {
            skewView.setFavoritesOnly(enabled)
        }

        onColorFilterRequested: index => {
            skewView.setColorFilter(index)
        }

        onSortRequested: {
            skewView.cycleSort()
            topBar.sortMode = skewView.sortMode
        }

        onRandomRequested: {
            skewView.selectRandom()
        }

        onRotationRequested: {
            skewView.cycleRotation()
            topBar.rotationMinutes = skewView.rotationMinutes
        }

        onOutputRequested: output => {
            skewView.selectedOutput = output
        }

        onSearchChanged: query => {
            skewView.setSearch(query)
        }

        onFolderSelected: path => {
            skewView.setFolder(path)
        }

        onCloseRequested: {
            root.close()
        }
    }

    SkewView {
        id: skewView
        z: 1

        anchors.fill: parent
    }

    Shortcut {
        sequence: "Escape"

        onActivated: root.close()
    }

    Connections {
        target: skewView

        function onWallpaperApplied(path) {
            console.log("ZenWall applied:", path)
        }
    }
}
