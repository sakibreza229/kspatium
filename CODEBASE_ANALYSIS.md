# Knome Workspace Switcher — Codebase Architecture & Audit Report

**Widget ID:** `org.kde.plasma.knomeworkspaces`  
**Target Platform:** KDE Plasma 6 (QML / QtQuick / Kirigami)  
**Version:** 2.3  
**Analysis Date:** 2026-10-13  

---

## 1. Project Overview & File Hierarchy

```
org.kde.plasma.knomeworkspaces/
├── metadata.json                 # Plasma 6 applet package metadata
├── preview.png                   # Store / UI preview image
├── README.md, CHANGELOG.md, ...  # Documentation & project info
└── contents/
    ├── config/
    │   ├── config.qml            # Configuration categories registration
    │   └── main.xml              # KConfig XML schema for settings
    └── ui/
        ├── configGeneral.qml     # Widget settings GUI (Kirigami form)
        ├── main.qml              # Main widget item and rendering logic
        └── icons/                # 13 symbolic SVGs used in Icon shape mode
```

---

## 2. Component-by-Component Analysis

### 2.1 Metadata (`metadata.json`)
- **Structure:** Standard Plasma 6 `KPlugin` and `KPackageStructure` format.
- **Root item:** Properly points to `main.qml`.
- **Provides:** `org.kde.plasma.virtualdesktops`
- **Minimum Plasma API:** `6.0`
- **Status:** **Valid & well-formed.**

---

### 2.2 Configuration Schema (`contents/config/main.xml`)
Defines the persistent KConfig entries under `<group name="General">`:

| Entry Key | Type | Default | Notes / Range |
|---|---|---|---|
| `dotSizeCustom` | Int | `8` | Inactive dot/font/icon size |
| `spacingFactor` | Double | `0.1` | Range: `0.1` – `0.9` |
| `horizontalMargin` | Int | `0` | Range: `0` – `10` |
| `activeSizeW` | Int | `24` | Width of active pill/bar |
| `activeSizeH` | Int | `8` | Height of active pill/bar |
| `navigationMode` | Int | `0` | 0 = Cycle, 1 = Fixed |
| `desktopWrapOn` | Bool | `true` | Wrap around on scrolling |
| `dynamicColorsEnabled` | Bool | `false` | Wallpaper color extraction |
| `customColorsEnabled` | Bool | `false` | User hex/custom colors |
| `activeColor` | String | `"white"` | Active dot color |
| `inactiveColor` | String | `"gray"` | Inactive dot color |
| `animationDuration` | Int | `300` | Easing duration in ms |
| `canAddDesktops` | Bool | `true` | Context menu add/remove |
| `dotShape` | Int | `0` | 0=Dot, 1=Ring, 2=Square, 3=Name, 4=Number |
| `desktopNames` | String | `""` | Optional custom names |
| `fixedDotCountEnabled` | Bool | `false` | Fixed number mode |
| `fixedDotCount` | Int | `5` | Dot count when fixed |

---

### 2.3 Configuration GUI (`contents/ui/configGeneral.qml`)
- **Category:** General (`config.qml`)
- **Controls & Bindings:**
  - `cfg_*` property aliases correctly adhere to KDE KConfigXT auto-binding convention.
  - Color dialogs use `root.normalizeToHex()` to sanitize values before storing.
  - `spacingSpin` handles decimal formatting (`0.1` to `0.9`) with custom `textFromValue` and `valueFromText`.
  - Conditional visibility for shape-specific sections (Desktop Names editor visible on index `3`).
  - Active width/height spinboxes disable when non-pill modes are active (Ring, Name, Number).

---

### 2.4 Main Widget Logic (`contents/ui/main.qml`)

#### Shape Modes Supported:
- **`0` - Dot (Pill):** Animated expanding pill/bar with smooth position offset calculation for both horizontal and vertical panels.
- **`1` - Ring:** Clean ring outline with inner centered indicator for active desktop.
- **`2` - Square:** Rectangle indicator matching pill sizing logic with `radius: 2`.
- **`3` - Desktop Name:** Dynamic names fetched from KWin via `virtualDesktopInfo.desktopNames` or custom names from config.
- **`4` - Desktop Number:** 1-indexed desktop number (`1`, `2`, `3`...).

#### Color Handling:
1. **Dynamic Wallpaper Detection:**
   - Queries `PlasmaShell.wallpaper` and `PlasmaShell.color` via DBus with fallback to `plasma-org.kde.plasma.desktop-appletsrc`.
   - Invisible `Canvas` (`wallpaperCanvas`) samples the wallpaper image, analyzes vibrant HSV colors and calculates luminance contrast against the dark/light Plasma theme.
2. **Custom Colors:**
   - User-defined active/inactive hex colors.
3. **Theme Defaults:**
   - Falls back cleanly to `Kirigami.Theme.highlightColor` and `Kirigami.Theme.textColor`.

#### Navigation & Events:
- **Click:** Calls `switchToDesktop(index)` executing DBus `setCurrentDesktop` (fallback to `kdotool`).
- **Scroll Wheel:** Threshold accumulator (`wheelDelta` with `120` step size) with wrapping support or hard stops depending on `navigationMode` / `wrapOn`.
- **Context Actions:** Standard Plasma context actions for adding/removing virtual desktops via Plasma 6 `/VirtualDesktopManager`.

---

## 3. Findings & Potential Issues Audit

### 🟢 Status: What is Working & Well-Implemented
1. **QML Syntax & Imports:** Imports are fully Plasma 6 compatible (`QtQuick`, `QtQuick.Layouts`, `org.kde.plasma.plasmoid`, `org.kde.plasma.plasma5support`, `org.kde.taskmanager`, `org.kde.kirigami`).
2. **KConfigXT Conformity:** All properties defined in `main.xml` match the `cfg_*` aliases in `configGeneral.qml` and `plasmoid.configuration` keys in `main.qml`.
3. **Plasma 6 D-Bus APIs:** `VirtualDesktopManager.createDesktop` and `removeDesktop` match Plasma 6 methods.
4. **Mouse Transparency on Scroll:** `wheelArea` specifies `acceptedButtons: Qt.NoButton`, preventing it from capturing click events meant for individual dot mouse areas.

---

## 4. Verification Checklist for Future Reference

- [x] Package structure matches Plasma 6 requirements
- [x] Configuration XML schema matches QML configuration properties
- [x] Layout calculation handles both horizontal and vertical panels
- [x] Switching logic accounts for Wayland / Plasma 6 D-Bus conventions

