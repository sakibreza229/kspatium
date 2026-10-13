# Kspatium — Minimalist Virtual Desktop Switcher for Plasma 6

[![KDE Plasma](https://img.shields.io/badge/KDE_Plasma-6.0+-1d99f3?style=for-the-badge&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![Platform](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://www.linux.org/)
[![License: GPL-3.0+](https://img.shields.io/badge/License-GPL--3.0+-blue.svg?style=for-the-badge)](LICENSE)
[![Support on Ko-fi](https://img.shields.io/badge/Ko--fi-sakibreza279-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/sakibreza279)

**Kspatium** is a sleek, ultra-minimalist virtual desktop indicator and switcher crafted natively for **KDE Plasma 6**.

Designed for users who appreciate distraction-free elegance, fluid navigation, and deep desktop customization. Kspatium provides minimal indicators, fluid active transitions, dynamic wallpaper colors, and intuitive scrolling — delivering a clean, modern aesthetic with Plasma's unmatched freedom.

## Screenshots

![Kspatium Preview](preview.png)

## Features

* **Minimalist UI**: Clean indicators with smooth animations for the active desktop.
* **Five Appearance Modes**:
  * **Dot**: Sleek pill indicators that expand for the active desktop.
  * **Ring**: Clean outlined rings with centered indicators.
  * **Square**: Modern square indicators.
  * **Desktop Name**: Displays actual desktop names from KWin (e.g., `Home`, `Work`), falling back to index numbers.
  * **Desktop Number**: Compact numeric indicators (`1`, `2`, `3`, …) bolded on the active desktop.
* **Highly Customizable**: Adjust dot/font sizes (8–24px), spacing factor (0.1–0.9), and active bar dimensions.
* **Dynamic Wallpaper Colors**: Automatically adapt active indicator and background tones based on your current desktop wallpaper.
* **Fixed Dot Count**: Option to display a fixed number of indicators regardless of virtual desktop count.
* **Custom Color Picker**: Pick any color via the native system color dialog or hex code (`#RRGGBB`).
* **Desktop Management**: Add or remove virtual desktops directly via the right-click context menu.
* **Mouse Wheel Navigation**: Switch desktops by scrolling over the widget with optional wrap-around.
* **Plasma 6 Native**: Built using modern Kirigami and Plasma 6 APIs. Shortcuts can be customized anytime in Plasma System Settings (`Shortcuts > KWin`).

## Configuration
Right-click the widget and select **"Configure Kspatium..."** to access all options:

| Section | Option | Description |
|---|---|---|
| Appearance | Shape | Dot, Ring, Square, Desktop Name, or Desktop Number |
| Appearance | Dot / Font Size | Indicator size in px (8 to 24px) |
| Appearance | Spacing Factor | Gap between indicators as a fraction of size (0.1 to 0.9) |
| Appearance | Side Margin | Left and right margin in px (0 to 10px) |
| Appearance | Active Width / Height | Size of the active dot bar (Dot and Square modes only) |
| Colors | Dynamic Colors | Adapt indicator colors automatically from current desktop wallpaper |
| Colors | Custom Colors | Enable custom active and inactive color overrides |
| Colors | Active / Inactive Color | Pick via color dialog or enter a hex code (`#RRGGBB`) |
| Behavior | Switching Mode | Cycle (continuous loop) or Fixed (stop at first and last workspace) |
| Behavior | Animation | Transition duration in milliseconds |
| Behavior | Desktop Management | Allow adding/removing desktops via context menu |
| Behavior | Fixed Dot Count | Display a fixed number of indicators (1 to 20) |

## Installation

### From .plasmoid Package
Install using `kpackagetool6`:
```bash
kpackagetool6 -t Plasma/Applet -i org.sakibreza279.kspatium-v3.0.plasmoid
```
To upgrade an existing installation:
```bash
kpackagetool6 -t Plasma/Applet -u org.sakibreza279.kspatium-v3.0.plasmoid
```
Or install via **Add Widgets > Get New Plugins > Install from File...** in Plasma.

### From Source
1. Clone the repository:
   ```bash
   git clone https://github.com/sakibreza229/org.sakibreza279.kspatium.git
   cd org.sakibreza279.kspatium
   ```

2. Copy the plasmoid files to your Plasma plasmoids directory:
   ```bash
   mkdir -p ~/.local/share/plasma/plasmoids/org.sakibreza279.kspatium
   cp -r contents metadata.json ~/.local/share/plasma/plasmoids/org.sakibreza279.kspatium/
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

If you find **Kspatium** helpful and would like to support its development:

[![ko-fi](https://storage.ko-fi.com/cdn/brandasset/v2/kofi_logo.png)](https://ko-fi.com/sakibreza279)

- ☕ **Support on Ko-fi**: [ko-fi.com/sakibreza279](https://ko-fi.com/sakibreza279)
- ⭐ **Star the project** on [GitHub](https://github.com/sakibreza229/org.sakibreza279.kspatium) to show your support

## License
This project is licensed under the GPL-3.0+ License.
