import QtQuick
import QtQuick.Controls
import QtCore
import Qt.labs.folderlistmodel

Item {
    id: root

    property int mediaMode: 0
    property bool favoritesOnly: false
    property int colorFilter: -1
    property string searchQuery: ""
    property int sortMode: 0
    property string selectedOutput: ""

    property int rotationMinutes: 0
    readonly property bool rotationEnabled: rotationMinutes > 0

    property string wallpaperFolder:
        StandardPaths.writableLocation(StandardPaths.PicturesLocation) + "/Wallpapers"

    readonly property int visibleCount: displayModel.count
    readonly property int totalCount: sourceModel.count
    readonly property var availableOutputs: wallpaperBackend.screenNames()

    readonly property string currentUrl:
        displayModel.count > 0 &&
        skewList.currentIndex >= 0
            ? String(displayModel.get(skewList.currentIndex).url)
            : ""

    readonly property string currentName:
        displayModel.count > 0 &&
        skewList.currentIndex >= 0
            ? String(displayModel.get(skewList.currentIndex).name)
            : ""

    signal wallpaperApplied(string path)

    WallpaperBackend {
        id: wallpaperBackend
    }

    FolderListModel {
        id: sourceModel

        folder: root.wallpaperFolder

        showDirs: false
        showFiles: true
        showHidden: false

        nameFilters: [
            "*.jpg",
            "*.jpeg",
            "*.png",
            "*.webp",
            "*.bmp",
            "*.gif",
            "*.mp4",
            "*.webm",
            "*.mkv",
            "*.avi",
            "*.mov"
        ]

        sortField: FolderListModel.Time
        sortReversed: true
    }

    ListModel {
        id: displayModel
    }

    readonly property int sliceWidth: 135
    readonly property int expandedCardWidth: 720
    readonly property int cardHeight: 500
    readonly property int sliceSpacing: -22
    readonly property int visibleSliceCount: 12

    function mediaKind(name) {
        const n = name.toLowerCase()

        if (n.endsWith(".mp4") ||
            n.endsWith(".webm") ||
            n.endsWith(".mkv") ||
            n.endsWith(".avi") ||
            n.endsWith(".mov"))
            return "video"

        if (n.endsWith(".gif"))
            return "gif"

        return "image"
    }

    function colorGroup(hue) {
        if (hue < 0 || hue === 99)
            return -1

        if (hue === 11 || hue === 0)
            return 0       // red

        if (hue === 1)
            return 1       // orange

        if (hue === 2)
            return 2       // yellow

        if (hue === 3 || hue === 4)
            return 3       // green

        if (hue === 5 || hue === 6)
            return 4       // cyan

        if (hue === 7 || hue === 8)
            return 5       // blue

        if (hue === 9)
            return 6       // purple

        return 7           // pink
    }

    function passesFilters(name, url) {
        const kind = mediaKind(name)

        if (mediaMode === 1 && kind !== "image")
            return false

        if (mediaMode === 2 && kind !== "video")
            return false

        if (mediaMode === 3 && kind !== "gif")
            return false

        if (favoritesOnly && !wallpaperBackend.isFavorite(url))
            return false

        const query = searchQuery.trim().toLowerCase()

        if (query.length > 0 &&
            name.toLowerCase().indexOf(query) === -1)
            return false

        if (colorFilter !== -1) {
            const hue = wallpaperBackend.hueForFile(url)

            if (colorGroup(hue) !== colorFilter)
                return false
        }

        return true
    }

    function rebuildModel() {
        const oldUrl = root.currentUrl

        displayModel.clear()

        for (let i = 0; i < sourceModel.count; ++i) {
            const name = sourceModel.get(i, "fileName") || ""
            const url = sourceModel.get(i, "fileUrl") || ""

            if (!passesFilters(name, url))
                continue

            displayModel.append({
                name: name,
                url: String(url),
                kind: mediaKind(name)
            })
        }

        if (displayModel.count === 0) {
            skewList.currentIndex = -1
            return
        }

        let target = 0

        if (oldUrl.length > 0) {
            for (let i = 0; i < displayModel.count; ++i) {
                if (String(displayModel.get(i).url) === oldUrl) {
                    target = i
                    break
                }
            }
        }

        skewList.currentIndex =
            Math.max(0, Math.min(target, displayModel.count - 1))
    }

    function setMediaMode(mode) {
        root.mediaMode = mode
        rebuildModel()
    }

    function setFavoritesOnly(enabled) {
        root.favoritesOnly = enabled
        rebuildModel()
    }

    function setColorFilter(index) {
        root.colorFilter = index
        rebuildModel()
    }

    function setSearch(query) {
        root.searchQuery = query
        rebuildModel()
    }

    function cycleSort() {
        root.sortMode = (root.sortMode + 1) % 2

        if (root.sortMode === 0) {
            sourceModel.sortField = FolderListModel.Time
            sourceModel.sortReversed = true
        } else {
            sourceModel.sortField = FolderListModel.Name
            sourceModel.sortReversed = false
        }

        Qt.callLater(rebuildModel)
    }

    function selectRandom() {
        if (displayModel.count <= 0)
            return

        const index = Math.floor(Math.random() * displayModel.count)

        skewList.currentIndex = index
        applyCurrent()
    }

    function cycleRotation() {
        const modes = [0, 5, 15, 30, 60]
        const current = modes.indexOf(rotationMinutes)
        rotationMinutes = modes[(current + 1) % modes.length]
        rotationTimer.interval = rotationMinutes > 0
            ? rotationMinutes * 60 * 1000
            : 0
        rotationTimer.restart()
    }

    Timer {
        id: rotationTimer
        interval: root.rotationMinutes > 0
            ? root.rotationMinutes * 60 * 1000
            : 0
        repeat: true
        running: root.rotationEnabled

        onTriggered: root.selectRandom()
    }

    function applyCurrent() {
        if (currentUrl.length === 0)
            return false

        const success = wallpaperBackend.applyToOutput(
            currentUrl,
            root.selectedOutput
        )

        if (success) {
            wallpaperApplied(currentUrl)
            return true
        }

        console.warn(
            "ZenWall:",
            wallpaperBackend.errorString()
        )

        return false
    }

    function toggleFavoriteCurrent() {
        if (currentUrl.length === 0)
            return

        wallpaperBackend.toggleFavorite(currentUrl)
        rebuildModel()
    }

    function setFolder(folder) {
        root.wallpaperFolder = String(folder)
        Qt.callLater(rebuildModel)
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    ListView {
        id: skewList

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        width: root.expandedCardWidth +
               (root.visibleSliceCount - 1) *
               (root.sliceWidth + root.sliceSpacing)

        height: root.cardHeight

        orientation: ListView.Horizontal
        spacing: root.sliceSpacing

        clip: false

        model: displayModel

        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin:
            (width - root.expandedCardWidth) / 2
        preferredHighlightEnd:
            (width + root.expandedCardWidth) / 2

        boundsBehavior: Flickable.StopAtBounds
        focus: true

        header: Item {
            width: Math.max(
                0,
                (skewList.width - root.expandedCardWidth) / 2
            )
            height: 1
        }

        footer: Item {
            width: Math.max(
                0,
                (skewList.width - root.expandedCardWidth) / 2
            )
            height: 1
        }

        delegate: Item {
            width: ListView.isCurrentItem
                ? root.expandedCardWidth
                : root.sliceWidth

            height: root.cardHeight

            Behavior on width {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            SkewCard {
                anchors.fill: parent

                selected: ListView.isCurrentItem
                mediaSource: model.url
                mediaKind: model.kind
                property int skewDistance: Math.abs(index - skewList.currentIndex)
                z: Math.max(0, 20 - skewDistance)
                transformOrigin: Item.Center
                scale: Math.max(0.78, 1.0 - skewDistance * 0.055)
                opacity: Math.max(0.45, 1.0 - skewDistance * 0.08)

                Behavior on scale {
                    NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        skewList.currentIndex = index
                        root.applyCurrent()
                        skewList.forceActiveFocus()
                    }
                }
            }
        }

        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Left:
                skewList.currentIndex =
                    Math.max(0, skewList.currentIndex - 1)
                event.accepted = true
                break

            case Qt.Key_Right:
                skewList.currentIndex =
                    Math.min(
                        displayModel.count - 1,
                        skewList.currentIndex + 1
                    )
                event.accepted = true
                break

            case Qt.Key_Return:
            case Qt.Key_Enter:
                root.applyCurrent()
                event.accepted = true
                break

            case Qt.Key_F:
                root.toggleFavoriteCurrent()
                event.accepted = true
                break

            case Qt.Key_R:
                root.selectRandom()
                event.accepted = true
                break

            default:
                break
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22

        text: root.visibleCount > 0
              ? (root.currentName.length > 0
                 ? root.currentName
                 : "ZenWall")
              : "No wallpapers match the current filters"

        color: "#b6b8c0"
        font.pixelSize: 14
        elide: Text.ElideMiddle
        width: Math.min(parent.width - 80, 700)
        horizontalAlignment: Text.AlignHCenter
    }

    Connections {
        target: sourceModel

        function onCountChanged() {
            root.rebuildModel()
        }
    }

    Connections {
        target: wallpaperBackend

        function onFavoritesChanged() {
            root.rebuildModel()
        }
    }

    Component.onCompleted: {
        root.rebuildModel()
        Qt.callLater(() => skewList.forceActiveFocus())
    }
}
