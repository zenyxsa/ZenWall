import QtQuick
import QtMultimedia

Item {
    id: root

    property bool selected: false
    property bool hovered: false
    property string mediaKind: "image"
    property url mediaSource

    readonly property bool isVideo: mediaKind === "video"

    readonly property bool imageReady:
        !root.isVideo && image.status === Image.Ready

    readonly property bool videoReady:
        root.isVideo &&
        (videoPlayer.mediaStatus === MediaPlayer.LoadedMedia ||
         videoPlayer.mediaStatus === MediaPlayer.BufferedMedia ||
         videoPlayer.mediaStatus === MediaPlayer.BufferingMedia)

    readonly property bool mediaReady:
        root.isVideo ? videoReady : imageReady

    readonly property real skewExtent: 32
    readonly property real skewFactor:
        root.height > 0 ? -root.skewExtent / root.height : 0

    Item {
        id: frame

        width: root.width
        height: root.height

        transform: Shear {
            xFactor: root.skewFactor

            origin.x: root.skewExtent
            origin.y: 0
        }

        Rectangle {
            anchors.fill: parent

            color: "#111318"

            radius: root.selected ? 14 : 8
        }

        Image {
            id: image

            anchors.fill: parent

            visible: !root.isVideo && root.mediaSource !== ""

            source: root.isVideo ? "" : root.mediaSource

            fillMode: Image.PreserveAspectCrop

            asynchronous: true
            cache: true
            sourceSize: Qt.size(Math.ceil(width * 1.5), Math.ceil(height * 1.5))
            smooth: true
        }

        MediaPlayer {
            id: videoPlayer

            source: root.isVideo ? root.mediaSource : ""

            loops: MediaPlayer.Infinite

            audioOutput: AudioOutput {
                volume: 0
            }

            videoOutput: videoOutput

            onMediaStatusChanged: {
                if (root.isVideo &&
                    (mediaStatus === MediaPlayer.LoadedMedia ||
                     mediaStatus === MediaPlayer.BufferedMedia ||
                     mediaStatus === MediaPlayer.BufferingMedia)) {
                    updatePlayback()
                }
            }

            onErrorOccurred: function(error, errorString) {
                console.warn(
                    "ZenWall video error:",
                    error,
                    errorString,
                    root.mediaSource
                )
            }

            function updatePlayback() {
                if (!root.isVideo)
                    return

                if (root.selected || root.hovered)
                    play()
                else
                    pause()
            }

            Component.onCompleted: {
                Qt.callLater(updatePlayback)
            }
        }

        VideoOutput {
            id: videoOutput

            anchors.fill: parent

            visible: root.isVideo

            fillMode: VideoOutput.PreserveAspectCrop
        }

        Rectangle {
            anchors.fill: parent

            visible: root.mediaReady

            color: root.selected
                ? "#00000010"
                : "#00000025"
        }

        Text {
            anchors.centerIn: parent

            visible: root.isVideo && !root.videoReady

            text: "LOADING"

            color: "#8d9098"

            font.pixelSize: 12
            font.bold: true
        }

        Rectangle {
            anchors.fill: parent

            color: "transparent"

            border.width: root.mediaReady
                ? (root.selected ? 2 : 1)
                : 0

            border.color: root.selected
                ? "#ffffffdd"
                : "#ffffff45"

            radius: root.selected ? 14 : 8
        }
    }

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true

        onEntered:
            root.hovered = true

        onExited:
            root.hovered = false
    }

    onSelectedChanged:
        Qt.callLater(videoPlayer.updatePlayback)

    onHoveredChanged:
        Qt.callLater(videoPlayer.updatePlayback)

    onMediaSourceChanged:
        Qt.callLater(videoPlayer.updatePlayback)
}
