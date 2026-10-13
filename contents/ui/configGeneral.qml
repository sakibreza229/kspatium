/**
 * Kspatium - Minimalist virtual desktops switcher for Plasma 6
 * SPDX-FileCopyrightText: 2024-2026 Sakib Reza
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager

Kirigami.ScrollablePage {
    id: root

    property alias cfg_dotSizeCustom: dotSizeSpin.value
    property alias cfg_activeSizeW: activeWidthSpin.value
    property alias cfg_activeSizeH: activeHeightSpin.value
    property alias cfg_navigationMode: navigationModeCombo.currentIndex
    property bool cfg_desktopWrapOn: plasmoid.configuration.desktopWrapOn
    property alias cfg_dynamicColorsEnabled: dynamicColorsCheck.checked
    property alias cfg_customColorsEnabled: customColorsCheck.checked
    property string cfg_activeColor
    property string cfg_inactiveColor
    property alias cfg_animationDuration: animationSpin.value
    property alias cfg_canAddDesktops: addDesktopsCheck.checked
    property real cfg_spacingFactor: 0.1
    property alias cfg_horizontalMargin: horizontalMarginSpin.value
    property alias cfg_dotShape: dotShapeCombo.currentIndex
    property string cfg_desktopNames: ""
    property alias cfg_fixedDotCountEnabled: fixedDotCountCheck.checked
    property alias cfg_fixedDotCount: fixedDotCountSpin.value

    readonly property QtObject virtualDesktopInfo: TaskManager.VirtualDesktopInfo {}

    function getDesktopNamesList() {
        if (!cfg_desktopNames || cfg_desktopNames.trim().length === 0) return []
        return cfg_desktopNames.split(",")
    }

    function setDesktopName(desktopIndex, name) {
        var list = getDesktopNamesList()
        // Extend list with system names if needed
        while (list.length <= desktopIndex) {
            var sysName = (virtualDesktopInfo.desktopNames && virtualDesktopInfo.desktopNames[list.length])
                ? virtualDesktopInfo.desktopNames[list.length]
                : i18n("Desktop %1", list.length + 1)
            list.push(sysName)
        }
        list[desktopIndex] = name
        cfg_desktopNames = list.join(",")
    }

    function getDesktopName(desktopIndex) {
        var list = getDesktopNamesList()
        if (desktopIndex < list.length && list[desktopIndex].trim().length > 0) {
            return list[desktopIndex].trim()
        }
        // Fall back to system desktop name
        if (virtualDesktopInfo.desktopNames && virtualDesktopInfo.desktopNames[desktopIndex]) {
            return virtualDesktopInfo.desktopNames[desktopIndex]
        }
        return i18n("Desktop %1", desktopIndex + 1)
    }

    function normalizeToHex(colorString) {
        if (!colorString) return '#ffffff'
        var c = Qt.color(colorString)
        if (c.valid) {
            var r = Math.round(c.r * 255).toString(16).padStart(2, '0')
            var g = Math.round(c.g * 255).toString(16).padStart(2, '0')
            var b = Math.round(c.b * 255).toString(16).padStart(2, '0')
            return '#' + r + g + b
        }
        return '#ffffff'
    }

    // --- Color dialogs (non-visual, kept outside the FormLayout) ---
    ColorDialog {
        id: activeColorDialog
        onAccepted: {
            var hex = root.normalizeToHex(selectedColor.toString())
            cfg_activeColor = hex
            activeColorField.text = hex
        }
    }

    ColorDialog {
        id: inactiveColorDialog
        onAccepted: {
            var hex = root.normalizeToHex(selectedColor.toString())
            cfg_inactiveColor = hex
            inactiveColorField.text = hex
        }
    }

    Kirigami.FormLayout {

        Kirigami.Heading {
            Kirigami.FormData.isSection: true
            text: i18n("Appearance")
        }

        QQC2.ComboBox {
            id: dotShapeCombo
            Kirigami.FormData.label: i18n("Shape:")
            model: [i18n("Dot"), i18n("Ring"), i18n("Square"), i18n("Desktop Name"), i18n("Desktop Number")]
        }

        // --- Per-desktop name editor (visible only in Desktop Name mode) ---
        Kirigami.Heading {
            Kirigami.FormData.isSection: true
            visible: dotShapeCombo.currentIndex === 3
            level: 3
            text: i18n("Desktop Names")
        }

        ColumnLayout {
            visible: dotShapeCombo.currentIndex === 3
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: virtualDesktopInfo.numberOfDesktops || 1

                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing
                    readonly property int desktopIdx: index

                    QQC2.Label {
                        text: i18n("Desktop %1:", desktopIdx + 1)
                        Layout.minimumWidth: Kirigami.Units.gridUnit * 4
                    }

                    QQC2.TextField {
                        id: nameField
                        Layout.fillWidth: true
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 10
                        placeholderText: (virtualDesktopInfo.desktopNames && virtualDesktopInfo.desktopNames[desktopIdx])
                            ? virtualDesktopInfo.desktopNames[desktopIdx]
                            : i18n("Desktop %1", desktopIdx + 1)
                        text: root.getDesktopName(desktopIdx)
                        onTextEdited: {
                            root.setDesktopName(desktopIdx, text)
                        }
                    }
                }
            }

            QQC2.Label {
                text: i18n("Set a custom name for each virtual desktop.")
                font.italic: true
                opacity: 0.7
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.preferredWidth: Kirigami.Units.gridUnit * 16
            }
        }

        QQC2.SpinBox {
            id: dotSizeSpin
            Kirigami.FormData.label: dotShapeCombo.currentIndex <= 2 ? i18n("Dot Size (px):") : i18n("Font Size (px):")
            from: 8; to: 24
        }

        QQC2.SpinBox {
            id: spacingSpin
            Kirigami.FormData.label: i18n("Spacing Factor:")
            from: 1; to: 9; stepSize: 1
            value: Math.round((root.cfg_spacingFactor || 0.1) * 10)
            onValueModified: root.cfg_spacingFactor = value / 10.0
            textFromValue: (value, locale) => Number(value / 10.0).toLocaleString(locale, 'f', 1)
            valueFromText: (text, locale) => Math.round(Number.fromLocaleString(locale, text) * 10)
        }

        QQC2.SpinBox {
            id: horizontalMarginSpin
            Kirigami.FormData.label: i18n("Side Margin (px):")
            from: 0; to: 10; stepSize: 1
        }

        QQC2.SpinBox {
            id: activeWidthSpin
            Kirigami.FormData.label: i18n("Active Width (px):")
            from: 8; to: 64
            enabled: dotShapeCombo.currentIndex === 0 || dotShapeCombo.currentIndex === 2
        }

        QQC2.SpinBox {
            id: activeHeightSpin
            Kirigami.FormData.label: i18n("Active Height (px):")
            from: 8; to: 16
            enabled: dotShapeCombo.currentIndex === 0 || dotShapeCombo.currentIndex === 2
        }

        Kirigami.Heading {
            Kirigami.FormData.isSection: true
            text: i18n("Colors")
        }

        QQC2.CheckBox {
            id: dynamicColorsCheck
            Kirigami.FormData.label: i18n("Dynamic Colors:")
            text: i18n("Adapt colors automatically from desktop wallpaper")
        }

        QQC2.Label {
            visible: dynamicColorsCheck.checked
            text: i18n("Colors adapt dynamically to your active wallpaper tone and accent.")
            font.italic: true
            opacity: 0.7
            wrapMode: Text.WordWrap
            Layout.preferredWidth: Kirigami.Units.gridUnit * 20
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

        QQC2.CheckBox {
            id: customColorsCheck
            Kirigami.FormData.label: i18n("Custom Colors:")
            text: i18n("Use custom colors")
            enabled: !dynamicColorsCheck.checked
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Active Color:")
            visible: customColorsCheck.checked && !dynamicColorsCheck.checked
            spacing: Kirigami.Units.smallSpacing

            Rectangle {
                width: 24; height: 24; radius: 4
                color: (cfg_activeColor && Qt.color(cfg_activeColor).valid) ? cfg_activeColor : "#3daee9"
                border.color: Kirigami.Theme.separatorColor || "#55808080"
                border.width: 1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        activeColorDialog.selectedColor = Qt.color(cfg_activeColor || "#3daee9")
                        activeColorDialog.open()
                    }
                }
            }

            QQC2.TextField {
                id: activeColorField
                Layout.preferredWidth: 90
                placeholderText: "#RRGGBB"
                Component.onCompleted: text = root.normalizeToHex(cfg_activeColor)
                onEditingFinished: {
                    var c = Qt.color(text)
                    if (c.valid) cfg_activeColor = root.normalizeToHex(text)
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Inactive Color:")
            visible: customColorsCheck.checked && !dynamicColorsCheck.checked
            spacing: Kirigami.Units.smallSpacing

            Rectangle {
                width: 24; height: 24; radius: 4
                color: (cfg_inactiveColor && Qt.color(cfg_inactiveColor).valid) ? cfg_inactiveColor : "#808080"
                border.color: Kirigami.Theme.separatorColor || "#55808080"
                border.width: 1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        inactiveColorDialog.selectedColor = Qt.color(cfg_inactiveColor || "#808080")
                        inactiveColorDialog.open()
                    }
                }
            }

            QQC2.TextField {
                id: inactiveColorField
                Layout.preferredWidth: 90
                placeholderText: "#RRGGBB"
                Component.onCompleted: text = root.normalizeToHex(cfg_inactiveColor)
                onEditingFinished: {
                    var c = Qt.color(text)
                    if (c.valid) cfg_inactiveColor = root.normalizeToHex(text)
                }
            }
        }

        Kirigami.Heading {
            Kirigami.FormData.isSection: true
            text: i18n("Behavior")
        }

        QQC2.ComboBox {
            id: navigationModeCombo
            Kirigami.FormData.label: i18n("Switching Mode:")
            model: [
                i18n("Cycle (continuous loop)"),
                i18n("Fixed (stop at first and last workspace)")
            ]
            Component.onCompleted: {
                // The cfg_navigationMode alias already loaded the saved index into currentIndex.
                // Just sync the derived cfg_desktopWrapOn property on load.
                root.cfg_desktopWrapOn = (currentIndex === 0)
            }
            onCurrentIndexChanged: {
                root.cfg_desktopWrapOn = (currentIndex === 0)
            }
        }

        QQC2.Label {
            text: navigationModeCombo.currentIndex === 0
                ? i18n("Scrolling continuously cycles across workspaces (1 → 2 → 3 → 1).")
                : i18n("Scrolling stops at boundaries without looping back to the beginning.")
            font.italic: true
            opacity: 0.7
            wrapMode: Text.WordWrap
            Layout.preferredWidth: Kirigami.Units.gridUnit * 20
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

        QQC2.SpinBox {
            id: animationSpin
            Kirigami.FormData.label: i18n("Animation (ms):")
            from: 0; to: 1000; stepSize: 50
        }

        QQC2.CheckBox {
            id: addDesktopsCheck
            Kirigami.FormData.label: i18n("Desktop Management:")
            text: i18n("Allow adding/removing via context menu")
        }

        QQC2.CheckBox {
            id: fixedDotCountCheck
            Kirigami.FormData.label: i18n("Fixed Dot Count:")
            text: i18n("Show a fixed number of dots")
        }

        QQC2.SpinBox {
            id: fixedDotCountSpin
            Kirigami.FormData.label: i18n("Number of dots:")
            from: 1; to: 20
            enabled: fixedDotCountCheck.checked
        }
    }
}