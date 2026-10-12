import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kcmutils as KCM
import org.kde.taskmanager as TaskManager
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: true

    preferredRepresentation: fullRepresentation
    compactRepresentation: fullRepresentation
    
    readonly property QtObject virtualDesktopInfo: TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }
    
    property int currentDesktop: {
        let desktop = virtualDesktopInfo.currentDesktop
        if (typeof desktop === 'string') {
            return Math.max(0, virtualDesktopInfo.desktopIds.indexOf(desktop))
        }
        return Math.max(0, (desktop || 1) - 1)
    }
    
    property int desktopCount: (plasmoid.configuration.fixedDotCountEnabled === true) ? (plasmoid.configuration.fixedDotCount || 5) : (virtualDesktopInfo.numberOfDesktops || 1)
    
    property int dotSize: Math.max(8, plasmoid.configuration.dotSizeCustom || 8)
    property real spacingFactor: Math.max(0.1, Math.min(0.9, (plasmoid.configuration.spacingFactor !== undefined && !isNaN(plasmoid.configuration.spacingFactor)) ? plasmoid.configuration.spacingFactor : 0.1))
    property int activeWidth: Math.max(dotSize, plasmoid.configuration.activeSizeW || 24)
    property int activeHeight: Math.max(dotSize, plasmoid.configuration.activeSizeH || 8)
    property int navigationMode: (plasmoid.configuration.navigationMode !== undefined)
        ? plasmoid.configuration.navigationMode
        : (plasmoid.configuration.desktopWrapOn === false ? 1 : 0)
    property bool wrapOn: navigationMode === 0

    property bool dynamicColors: plasmoid.configuration.dynamicColorsEnabled || false
    property bool customColors: !dynamicColors && (plasmoid.configuration.customColorsEnabled || false)

    property color dynamicActiveColor: Kirigami.Theme.highlightColor || "#3daee9"
    property color dynamicInactiveColor: Kirigami.Theme.textColor || "#808080"
    property string currentWallpaperPath: ""

    onDynamicColorsChanged: {
        if (dynamicColors) checkWallpaper()
    }
    onCurrentDesktopChanged: {
        if (dynamicColors) checkWallpaper()
    }

    property color activeColor: {
        if (dynamicColors) return dynamicActiveColor
        if (!customColors) {
            let c = Kirigami.Theme.highlightColor
            return (c && c !== "#000000") ? c : "#3daee9"
        }
        return plasmoid.configuration.activeColor || "#3daee9"
    }

    property color inactiveColor: {
        if (dynamicColors) return dynamicInactiveColor
        if (!customColors) {
            let c = Kirigami.Theme.textColor
            return (c && c !== "#000000") ? c : "#ffffff"
        }
        return plasmoid.configuration.inactiveColor || "#808080"
    }

    property int animDuration: Math.max(0, plasmoid.configuration.animationDuration !== undefined ? plasmoid.configuration.animationDuration : 300)
    property bool canAddDesktops: plasmoid.configuration.canAddDesktops !== false
    property int dotShape: plasmoid.configuration.dotShape || 0
    property var desktopIconNames: (plasmoid.configuration.desktopIcons || "home,code,gaming,work,media,chat,music,browser,design,files").split(",")
    property var desktopCustomNames: {
        var raw = plasmoid.configuration.desktopNames || ""
        return raw.trim().length > 0 ? raw.split(",") : []
    }

    // Available icon catalog (includes 3 fallback/general-purpose icons)
    readonly property var availableIcons: ["home", "code", "gaming", "work", "media", "chat", "music", "browser", "design", "files", "window", "app", "grid"]

    function iconForDesktop(idx) {
        if (idx >= 0 && idx < desktopIconNames.length && desktopIconNames[idx].trim().length > 0) {
            return Qt.resolvedUrl("icons/" + desktopIconNames[idx].trim() + ".svg")
        }
        // Fallback: use grid icon for unmapped desktops
        return Qt.resolvedUrl("icons/grid.svg")
    }

    function nameForDesktop(idx) {
        // Prefer custom names from widget config
        if (idx >= 0 && idx < desktopCustomNames.length && desktopCustomNames[idx].trim().length > 0) {
            return desktopCustomNames[idx].trim()
        }
        // Fall back to system desktop name
        if (virtualDesktopInfo.desktopNames && virtualDesktopInfo.desktopNames[idx]) {
            return virtualDesktopInfo.desktopNames[idx]
        }
        return (idx + 1).toString()
    }

    property real spacing: spacingFactor * dotSize
    property int horizontalMargin: Math.max(0, Math.min(10, (plasmoid.configuration.horizontalMargin !== undefined && !isNaN(plasmoid.configuration.horizontalMargin)) ? plasmoid.configuration.horizontalMargin : 0))
    property bool isHorizontal: plasmoid.formFactor !== PlasmaCore.Types.Vertical
    property int wheelDelta: 0
    
    function updateLayout() {
        root.implicitWidth = Qt.binding(function() { return Layout.minimumWidth })
        root.implicitHeight = Qt.binding(function() { return Layout.minimumHeight })
    }
    
    onDotSizeChanged: updateLayout()
    onSpacingFactorChanged: updateLayout()
    onHorizontalMarginChanged: updateLayout()
    onActiveWidthChanged: updateLayout()
    onActiveHeightChanged: updateLayout()
    onDesktopCountChanged: updateLayout()
    onDotShapeChanged: updateLayout()

    Layout.minimumWidth: (isHorizontal
        ? (dotShape === 1 ? circleRow.implicitWidth
           : dotShape === 3 ? iconRow.implicitWidth
           : dotShape === 4 ? nameRow.implicitWidth
           : dotShape === 5 ? numRow.implicitWidth
           : (desktopCount * dotSize) + ((desktopCount - 1) * spacing) + (activeWidth - dotSize))
        : (dotShape === 1 ? circleColumn.implicitWidth
           : dotShape === 3 ? iconColumn.implicitWidth
           : dotShape === 4 ? nameColumn.implicitWidth
           : dotShape === 5 ? numColumn.implicitWidth
           : activeWidth)) + (2 * horizontalMargin)

    Layout.minimumHeight: !isHorizontal
        ? (dotShape === 1 ? circleColumn.implicitHeight
           : dotShape === 3 ? iconColumn.implicitHeight
           : dotShape === 4 ? nameColumn.implicitHeight
           : dotShape === 5 ? numColumn.implicitHeight
           : (desktopCount * dotSize) + ((desktopCount - 1) * spacing) + (activeHeight - dotSize))
        : (dotShape === 1 ? circleRow.implicitHeight
           : dotShape === 3 ? iconRow.implicitHeight
           : dotShape === 4 ? nameRow.implicitHeight
           : dotShape === 5 ? numRow.implicitHeight
           : activeHeight)
        
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    function switchToDesktop(index) {
        let desktopNumber = index + 1
        let service = "org.kde.KWin"
        let path = "/KWin"
        let kwinIface = "org.kde.KWin" 
        
        let call = 'qdbus6 ' + service + ' ' + path + ' ' + kwinIface + '.setCurrentDesktop ' + desktopNumber + ' 2>/dev/null || ' +
                   'qdbus ' + service + ' ' + path + ' ' + kwinIface + '.setCurrentDesktop ' + desktopNumber + ' 2>/dev/null || ' +
                   'kdotool set_desktop ' + desktopNumber + ' 2>/dev/null'
        
        executable.connectSource(call)
    }
    
    function addDesktop() {
        if (!canAddDesktops) return
        // Plasma 6: use /VirtualDesktopManager; append at end
        let pos = virtualDesktopInfo.numberOfDesktops
        let call = 'qdbus6 org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.createDesktop ' + pos + ' ""'
        executable.connectSource(call)
    }

    function removeDesktop() {
        if (!canAddDesktops || desktopCount <= 1) return
        // Plasma 6: removeDesktop takes a UUID string, remove the last desktop
        let ids = virtualDesktopInfo.desktopIds
        if (!ids || ids.length === 0) return
        let lastId = ids[ids.length - 1]
        let call = 'qdbus6 org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.removeDesktop ' + lastId
        executable.connectSource(call)
    }

    function checkWallpaper() {
        if (!dynamicColors) return
        let scr = (plasmoid.screen !== undefined && plasmoid.screen >= 0) ? plasmoid.screen : 0
        // Append a timestamp comment to avoid DataSource caching identical commands
        let ts = Date.now()
        let cmd = 'sh -c \'SCR=' + scr + '; RAW=$(qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.wallpaper "$SCR" 2>/dev/null | grep -m1 -E "^Image: " | sed "s/^Image: //"); [ -z "$RAW" ] && RAW=$(grep -m1 -E "^Image=" ~/.config/plasma-org.kde.plasma.desktop-appletsrc 2>/dev/null | cut -d= -f2-); RAW=$(echo "$RAW" | sed "s|^file://||"); if [ -d "$RAW" ]; then IMG=$(find "$RAW" -type f \\( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \\) 2>/dev/null | head -n1); else IMG="$RAW"; fi; [ -n "$IMG" ] && echo "WALLPAPER:file://$IMG"; COLOR=$(qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.color 2>/dev/null); [ -n "$COLOR" ] && echo "COLOR:$COLOR"\' #ts=' + ts
        wallpaperExec.connectSource(cmd)
    }

    Timer {
        id: wallpaperTimer
        interval: 5000
        running: dynamicColors
        repeat: true
        onTriggered: checkWallpaper()
    }

    Canvas {
        id: wallpaperCanvas
        width: 20
        height: 20
        visible: false

        property bool hasValidSample: false
        property string pendingImageUrl: ""

        onImageLoaded: {
            if (!pendingImageUrl) return
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.drawImage(pendingImageUrl, 0, 0, width, height)
            var imgData = ctx.getImageData(0, 0, width, height)
            if (!imgData || !imgData.data || imgData.data.length === 0) return

            var data = imgData.data
            var bestColor = null
            var maxVibrancy = -1

            for (var i = 0; i < data.length; i += 4) {
                var r = data[i]
                var g = data[i + 1]
                var b = data[i + 2]

                var max = Math.max(r, g, b), min = Math.min(r, g, b)
                var delta = max - min
                var sat = max === 0 ? 0 : delta / max
                var val = max / 255.0

                var vibrancy = sat * (1.0 - Math.abs(val - 0.6) * 1.4)
                if (vibrancy > maxVibrancy) {
                    maxVibrancy = vibrancy
                    bestColor = { r: r / 255.0, g: g / 255.0, b: b / 255.0 }
                }
            }

            var themeText = Kirigami.Theme.textColor
            var isDarkTheme = (themeText.r * 0.299 + themeText.g * 0.587 + themeText.b * 0.114) > 0.5

            if (!bestColor || maxVibrancy < 0.1) {
                bestColor = isDarkTheme ? { r: 0.85, g: 0.85, b: 0.85 } : { r: 0.2, g: 0.2, b: 0.2 }
            } else {
                var colorLuma = 0.299 * bestColor.r + 0.587 * bestColor.g + 0.114 * bestColor.b
                if (isDarkTheme && colorLuma < 0.45) {
                    var factor = 0.55 / Math.max(0.1, colorLuma)
                    bestColor.r = Math.min(1.0, bestColor.r * factor)
                    bestColor.g = Math.min(1.0, bestColor.g * factor)
                    bestColor.b = Math.min(1.0, bestColor.b * factor)
                } else if (!isDarkTheme && colorLuma > 0.65) {
                    var dimFactor = 0.5 / colorLuma
                    bestColor.r = bestColor.r * dimFactor
                    bestColor.g = bestColor.g * dimFactor
                    bestColor.b = bestColor.b * dimFactor
                }
            }

            root.dynamicActiveColor = Qt.rgba(bestColor.r, bestColor.g, bestColor.b, 1.0)
            root.dynamicInactiveColor = isDarkTheme ? Qt.rgba(0.9, 0.9, 0.9, 0.6) : Qt.rgba(0.2, 0.2, 0.2, 0.6)
            hasValidSample = true
        }
    }

    // Separate DataSource for wallpaper color detection (keeps desktop switching commands clean)
    Plasma5Support.DataSource {
        id: wallpaperExec
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            disconnectSource(source)
            let stdout = data["stdout"] ? data["stdout"].trim() : ""
            if (stdout.length === 0) return

            let lines = stdout.split("\n")
            let wp = ""
            let col = ""
            for (let i = 0; i < lines.length; i++) {
                let line = lines[i].trim()
                if (line.indexOf("WALLPAPER:") === 0) {
                    wp = line.substring(10).trim()
                } else if (line.indexOf("COLOR:") === 0) {
                    col = line.substring(6).trim()
                }
            }

            // Apply wallpaper image sampling
            if (wp && wp !== currentWallpaperPath) {
                currentWallpaperPath = wp
                wallpaperCanvas.pendingImageUrl = wp
                wallpaperCanvas.loadImage(wp)
            }

            // Use DBus accent color as immediate fallback (or primary if no image)
            if (col) {
                let num = parseInt(col)
                if (!isNaN(num) && num > 0) {
                    let r = ((num >> 16) & 0xff) / 255.0
                    let g = ((num >> 8) & 0xff) / 255.0
                    let b = (num & 0xff) / 255.0
                    // Only use color fallback if canvas hasn't produced a result yet
                    if (!wallpaperCanvas.hasValidSample) {
                        root.dynamicActiveColor = Qt.rgba(r, g, b, 1.0)
                    }
                }
            }
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            disconnectSource(source)
        }
    }

    // --- KGlobalAccel: Global keyboard shortcuts ---
    PlasmaCore.Action {
        id: nextDesktopAction
        text: i18n("Switch to Next Desktop")
        icon.name: "go-next"
        shortcut: plasmoid.configuration.nextDesktopShortcut
        onTriggered: {
            let target = wrapOn
                ? ((currentDesktop + 1) % desktopCount)
                : Math.min(currentDesktop + 1, desktopCount - 1)
            if (target !== currentDesktop) switchToDesktop(target)
        }
    }

    PlasmaCore.Action {
        id: prevDesktopAction
        text: i18n("Switch to Previous Desktop")
        icon.name: "go-previous"
        shortcut: plasmoid.configuration.prevDesktopShortcut
        onTriggered: {
            let target = wrapOn
                ? ((currentDesktop - 1 + desktopCount) % desktopCount)
                : Math.max(currentDesktop - 1, 0)
            if (target !== currentDesktop) switchToDesktop(target)
        }
    }

    Component.onCompleted: {
        updateLayout()
        plasmoid.setInternalAction("nextDesktop", nextDesktopAction)
        plasmoid.setInternalAction("prevDesktop", prevDesktopAction)
        if (dynamicColors) checkWallpaper()
    }

    Item {
        id: mainContainer
        anchors.fill: parent
        anchors.leftMargin: root.horizontalMargin
        anchors.rightMargin: root.horizontalMargin
        
        // --- Dot / Square mode ---
        Repeater {
            id: desktopRepeater
            model: (dotShape === 0 || dotShape === 2) ? desktopCount : 0  // only dot / square

            delegate: Item {
                id: delegateItem
                readonly property bool isHovered: mouseHandler.containsMouse

                x: isHorizontal ? (index < currentDesktop ? index * (dotSize + spacing) : (index > currentDesktop ? (index * (dotSize + spacing)) + (activeWidth - dotSize) : index * (dotSize + spacing))) : (parent.width - width) / 2
                y: !isHorizontal ? (index < currentDesktop ? index * (dotSize + spacing) : (index > currentDesktop ? (index * (dotSize + spacing)) + (activeHeight - dotSize) : index * (dotSize + spacing))) : (parent.height - height) / 2

                width: isHorizontal ? (index === currentDesktop ? activeWidth : dotSize) : dotSize
                height: !isHorizontal ? (index === currentDesktop ? activeHeight : dotSize) : dotSize

                Rectangle {
                    id: desktopDot
                    anchors.fill: parent
                    color: index === currentDesktop ? activeColor : inactiveColor
                    opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                    radius: dotShape === 0 ? height * 0.5 : 2

                    Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    MouseArea {
                        id: mouseHandler
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }

                Behavior on x { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
                Behavior on y { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
                Behavior on width { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
                Behavior on height { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
            }
        }

        // --- Desktop Name mode (horizontal) ---
        Row {
            id: nameRow
            visible: isHorizontal && dotShape === 4
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 4 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: nameMouseArea.containsMouse
                    implicitWidth: nameText.implicitWidth
                    implicitHeight: nameText.implicitHeight
                    width: implicitWidth
                    height: implicitHeight

                    Text {
                        id: nameText
                        text: nameForDesktop(index)
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                        font.pixelSize: dotSize + 2
                        font.bold: index === currentDesktop

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: nameMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Desktop Name mode (vertical) ---
        Column {
            id: nameColumn
            visible: !isHorizontal && dotShape === 4
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 4 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: nameMouseAreaV.containsMouse
                    implicitWidth: nameTextV.implicitWidth
                    implicitHeight: nameTextV.implicitHeight
                    width: implicitWidth
                    height: implicitHeight

                    Text {
                        id: nameTextV
                        text: nameForDesktop(index)
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                        font.pixelSize: dotSize + 2
                        font.bold: index === currentDesktop

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: nameMouseAreaV
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Icon mode (horizontal) ---
        Row {
            id: iconRow
            visible: isHorizontal && dotShape === 3
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 3 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: iconMouseH.containsMouse
                    implicitWidth: Math.max(16, dotSize + 8)
                    implicitHeight: Math.max(16, dotSize + 8)
                    width: implicitWidth
                    height: implicitHeight

                    Kirigami.Icon {
                        id: iconImgH
                        anchors.centerIn: parent
                        width: Math.max(14, dotSize + 4)
                        height: width
                        source: iconForDesktop(index)
                        isMask: true
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: iconMouseH
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Icon mode (vertical) ---
        Column {
            id: iconColumn
            visible: !isHorizontal && dotShape === 3
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 3 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: iconMouseV.containsMouse
                    implicitWidth: Math.max(16, dotSize + 8)
                    implicitHeight: Math.max(16, dotSize + 8)
                    width: implicitWidth
                    height: implicitHeight

                    Kirigami.Icon {
                        id: iconImgV
                        anchors.centerIn: parent
                        width: Math.max(14, dotSize + 4)
                        height: width
                        source: iconForDesktop(index)
                        isMask: true
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: iconMouseV
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Desktop Number mode (horizontal) ---
        Row {
            id: numRow
            visible: isHorizontal && dotShape === 5
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 5 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: numMouseH.containsMouse
                    implicitWidth: Math.max(numTextH.implicitWidth + 8, dotSize + 8)
                    implicitHeight: Math.max(numTextH.implicitHeight + 4, dotSize + 4)
                    width: implicitWidth
                    height: implicitHeight

                    Text {
                        id: numTextH
                        anchors.centerIn: parent
                        text: (index + 1)
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                        font.pixelSize: Math.max(11, dotSize + 2)
                        font.bold: index === currentDesktop

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: numMouseH
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Desktop Number mode (vertical) ---
        Column {
            id: numColumn
            visible: !isHorizontal && dotShape === 5
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 5 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: numMouseV.containsMouse
                    implicitWidth: Math.max(numTextV.implicitWidth + 8, dotSize + 8)
                    implicitHeight: Math.max(numTextV.implicitHeight + 4, dotSize + 4)
                    width: implicitWidth
                    height: implicitHeight

                    Text {
                        id: numTextV
                        anchors.centerIn: parent
                        text: (index + 1)
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                        font.pixelSize: Math.max(11, dotSize + 2)
                        font.bold: index === currentDesktop

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: numMouseV
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Circle mode (horizontal) ---
        Row {
            id: circleRow
            visible: isHorizontal && dotShape === 1
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 1 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: circleMouseH.containsMouse
                    implicitWidth: dotSize + 4
                    implicitHeight: dotSize + 4
                    width: implicitWidth
                    height: implicitHeight

                    // Outer ring
                    Rectangle {
                        id: circleRingH
                        anchors.centerIn: parent
                        width: dotSize
                        height: dotSize
                        radius: dotSize / 2
                        color: "transparent"
                        border.width: Math.max(1.5, dotSize * 0.12)
                        border.color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)

                        Behavior on border.color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    // Inner filled dot (active only)
                    Rectangle {
                        anchors.centerIn: parent
                        width: dotSize * 0.45
                        height: width
                        radius: width / 2
                        color: activeColor
                        visible: index === currentDesktop
                        opacity: index === currentDesktop ? 1.0 : 0.0

                        Behavior on opacity { NumberAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                    }

                    MouseArea {
                        id: circleMouseH
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Circle mode (vertical) ---
        Column {
            id: circleColumn
            visible: !isHorizontal && dotShape === 1
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 1 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: circleMouseV.containsMouse
                    implicitWidth: dotSize + 4
                    implicitHeight: dotSize + 4
                    width: implicitWidth
                    height: implicitHeight

                    // Outer ring
                    Rectangle {
                        id: circleRingV
                        anchors.centerIn: parent
                        width: dotSize
                        height: dotSize
                        radius: dotSize / 2
                        color: "transparent"
                        border.width: Math.max(1.5, dotSize * 0.12)
                        border.color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)

                        Behavior on border.color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    // Inner filled dot (active only)
                    Rectangle {
                        anchors.centerIn: parent
                        width: dotSize * 0.45
                        height: width
                        radius: width / 2
                        color: activeColor
                        visible: index === currentDesktop
                        opacity: index === currentDesktop ? 1.0 : 0.0

                        Behavior on opacity { NumberAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                    }

                    MouseArea {
                        id: circleMouseV
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        MouseArea {
            id: wheelArea
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: function(wheel) {
                let delta = wheel.angleDelta.y || wheel.angleDelta.x
                wheelDelta += delta
                let steps = 0
                while (wheelDelta >= 120) { wheelDelta -= 120; steps-- }
                while (wheelDelta <= -120) { wheelDelta += 120; steps++ }

                if (steps !== 0) {
                    let targetDesktop = currentDesktop + steps
                    if (wrapOn) {
                        targetDesktop = ((targetDesktop % desktopCount) + desktopCount) % desktopCount
                    } else {
                        targetDesktop = Math.max(0, Math.min(desktopCount - 1, targetDesktop))
                        if (targetDesktop === 0 && steps < 0) wheelDelta = 0
                        if (targetDesktop === desktopCount - 1 && steps > 0) wheelDelta = 0
                    }
                    if (targetDesktop !== currentDesktop) switchToDesktop(targetDesktop)
                }
                wheel.accepted = true
            }
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Add Virtual Desktop")
            icon.name: "list-add"
            enabled: canAddDesktops
            onTriggered: addDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Remove Virtual Desktop")
            icon.name: "list-remove"
            enabled: canAddDesktops && desktopCount > 1
            onTriggered: removeDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Configure Virtual Desktops…")
            icon.name: "configure"
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}