# Knome Workspace Switcher — GNOME-style Virtual Desktop Switcher for Plasma 6

[![KDE Plasma](https://img.shields.io/badge/KDE_Plasma-6.0+-1d99f3?style=for-the-badge&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![Platform](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://www.linux.org/)
[![License: GPL-3.0+](https://img.shields.io/badge/License-GPL--3.0+-blue.svg?style=for-the-badge)](LICENSE)
[![Support on Ko-fi](https://img.shields.io/badge/Ko--fi-sakibreza279-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/sakibreza279)

**Knome Workspace Switcher** is part of the **Knome Project** — born from a deep appreciation for the strengths of both desktop worlds.

Many Linux users love the sheer power, flexibility, and customizability of **KDE Plasma**, while also admiring the clean, distraction-free aesthetic and fluid workspace workflow of **GNOME**. For KDE users who miss certain distinctive GNOME features that aren't natively available in Plasma, **Knome** bridges that gap.

This widget delivers GNOME's signature pill-dot workspace switcher directly to **KDE Plasma 6**: minimal indicators, fluid active transitions, dynamic wallpaper colors, and intuitive scrolling — combining GNOME's refined elegance with Plasma's unmatched freedom.

## Screenshots

![Knome Workspace Switcher Preview](preview.png)

## Features

* **Minimalist UI**: Clean indicators with smooth animations for the active desktop.
* **Five Appearance Modes**:
  * **Circle**: Classic GNOME-style pill dots that expand for the active desktop.
  * **Square**: Modern square indicators.
  * **Desktop Name**: Displays actual desktop names from KWin (e.g., `Home`, `Work`), falling back to index numbers.
  * **Icon**: Per-desktop Material Design icons (Home, Code, Gaming, Work, Media, Chat, Music, Browser, Design, Files) — each workspace gets its own customizable icon.
  * **Desktop Number**: Compact labels (`D1`, `D2`, `D3`, …) bolded on the active desktop.
* **Highly Customizable**: Adjust dot/icon/font sizes (8–24px), spacing factor (0.1–0.9), and active bar dimensions.
* **Dynamic Wallpaper Colors**: Automatically adapt active indicator and background tones based on your current desktop wallpaper.
* **Fixed Dot Count**: Option to display a fixed number of indicators regardless of virtual desktop count.
* **Custom Color Picker**: Pick any color via the native system color dialog or hex code (`#RRGGBB`).
* **Desktop Management**: Add or remove virtual desktops directly via the right-click context menu.
* **Mouse Wheel Navigation**: Switch desktops by scrolling over the widget with optional wrap-around.
* **Global Keyboard Shortcuts**: Configurable global shortcuts to switch to next/previous desktops.
* **Plasma 6 Native**: Built using modern Kirigami and Plasma 6 APIs.

## Configuration
Right-click the widget and select **"Configure Knome Workspace Switcher..."** to access all options:

| Section | Option | Description |
|---|---|---|
| Appearance | Shape | Circle, Square, Desktop Name, Icon, or Desktop Number |
| Appearance | Dot / Icon / Font Size | Indicator size in px (8 to 24px) |
| Appearance | Spacing Factor | Gap between indicators as a fraction of size (0.1 to 0.9) |
| Appearance | Side Margin | Left and right margin in px (0 to 10px) |
| Appearance | Active Width / Height | Size of the active dot bar (Circle and Square modes only) |
| Colors | Dynamic Colors | Adapt indicator colors automatically from current desktop wallpaper |
| Colors | Custom Colors | Enable custom active and inactive color overrides |
| Colors | Active / Inactive Color | Pick via color dialog or enter a hex code (`#RRGGBB`) |
| Behavior | Switching Mode | Cycle (continuous loop) or Fixed (stop at first and last workspace) |
| Behavior | Animation | Transition duration in milliseconds |
| Behavior | Desktop Management | Allow adding/removing desktops via context menu |
| Behavior | Fixed Dot Count | Display a fixed number of indicators (1 to 20) |
| Shortcuts | Next Desktop | Global shortcut to switch to the next desktop |
| Shortcuts | Previous Desktop | Global shortcut to switch to the previous desktop |

## Installation

### From .plasmoid Package
Install using `kpackagetool6`:
```bash
kpackagetool6 -t Plasma/Applet -i org.kde.plasma.knomeworkspaces-v2.3.plasmoid
```
To upgrade an existing installation:
```bash
kpackagetool6 -t Plasma/Applet -u org.kde.plasma.knomeworkspaces-v2.3.plasmoid
```
Or install via **Add Widgets > Get New Plugins > Install from File...** in Plasma.

### From Source
1. Clone the repository:
   ```bash
   git clone https://github.com/sakibreza229/org.kde.plasma.knomeworkspaces.git
   cd org.kde.plasma.knomeworkspaces
   ```

2. Copy the plasmoid files to your Plasma plasmoids directory:
   ```bash
   mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.knomeworkspaces
   cp -r contents metadata.json ~/.local/share/plasma/plasmoids/org.kde.plasma.knomeworkspaces/
   ```

3. Refresh the Plasma shell cache:
   ```bash
   kbuildsycoca6
   ```

> [!WARNING]
> Running `kbuildsycoca6` can occasionally freeze or temporarily stop the entire Plasma shell session. If your desktop becomes unresponsive after running this command, try pressing `Ctrl+Alt+F2` to switch to a TTY and run `loginctl terminate-session self`, or simply **restart your machine**. This is a known quirk of the Plasma cache rebuild and not specific to this widget.

## Requirements
- KDE Plasma 6.0+
- `plasma5support` package (provides the DataSource executable engine)

## Bug reporting / Feature requests / Contributing

Please read the [Contributing guidelines in this repository](CONTRIBUTING.md)

## Join our Discord

Help/Support/Discussion about my projects

[![Discord](https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/bBSby3HgmS)

## Support & Sponsoring

If you find **Knome Workspace Switcher** helpful and would like to support its development:

[![ko-fi](https://storage.ko-fi.com/cdn/brandasset/v2/kofi_logo.png)](https://ko-fi.com/sakibreza279)

- ☕ **Support on Ko-fi**: [ko-fi.com/sakibreza279](https://ko-fi.com/sakibreza279)
- ⭐ **Star the project** on [GitHub](https://github.com/sakibreza229/org.kde.plasma.knomeworkspaces) to show your support

## License
This project is licensed under the GPL-3.0+ License.
