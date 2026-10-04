# ZenWall

**ZenWall** is a cross-platform wallpaper switcher built with **Qt 6, QML, C++17, CMake, and Ninja**.

It uses a fullscreen transparent overlay with a compact **Skew-inspired wallpaper selector** instead of a traditional dashboard-style application window.

[![Windows Build](https://github.com/zenyxsa/ZenWall/actions/workflows/windows.yml/badge.svg)](https://github.com/zenyxsa/ZenWall/actions/workflows/windows.yml)

## Features

- Fullscreen transparent wallpaper selector
- Skew-style wallpaper cards
- Image previews
- Video previews
- Mouse and keyboard navigation
- Favorites
- Search
- Media type filters
- Sorting
- Random wallpaper selection
- Automatic wallpaper rotation
- Color filtering
- Monitor/output selection
- Wallpaper transitions on Linux
- Wallpaper count
- Cross-platform Qt/QML interface

## Platform Support

| Platform | Wallpaper Backend | Status |
| --- | --- | --- |
| Linux / Wayland | [awww](https://github.com/amenra/awww) | Working |
| Windows 10 / 11 | Windows Desktop Wallpaper API | Working |

> ZenWall is still under active development. Some advanced media and desktop-wallpaper features are not finished yet.

---

## Linux

ZenWall uses **awww** for applying wallpapers on Linux.

### Requirements

- Linux with a Wayland session
- Qt 6
- C++17 compiler
- CMake
- Ninja
- awww
- awww-daemon

### Arch Linux dependencies

Install the Qt and build dependencies:

```fish
sudo pacman -S --needed cmake ninja qt6-base qt6-declarative qt6-multimedia
```

Install **awww** separately if it is not already installed.

### Build

Clone the repository:

```fish
git clone https://github.com/zenyxsa/ZenWall.git
cd ZenWall
```

Configure the project:

```fish
cmake -S . -B build -G Ninja
```

Build:

```fish
cmake --build build
```

Run:

```fish
./build/zenwall
```

### Check awww

Check the current outputs:

```fish
awww query
```

Start the daemon when needed:

```fish
awww-daemon &
```

ZenWall can pass the selected display/output to awww for monitor-specific wallpaper changes.

---

## Windows

ZenWall uses the native **Windows Desktop Wallpaper API** through `IDesktopWallpaper`.

### Requirements

- Windows 10 or Windows 11
- Qt 6
- Visual Studio 2022 with C++ desktop development tools
- CMake
- Ninja

### Build

Clone the repository:

```powershell
git clone https://github.com/zenyxsa/ZenWall.git
cd ZenWall
```

Configure with Visual Studio 2022:

```powershell
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
```

Build the Release version:

```powershell
cmake --build build --config Release
```

The executable will be:

```text
build/Release/zenwall.exe
```

### Windows features

- Native Windows wallpaper handling
- Monitor detection
- Per-monitor wallpaper selection
- Image wallpapers
- Fill/crop positioning

---

## GitHub Actions

ZenWall includes an automated Windows build workflow:

```text
.github/workflows/windows.yml
```

The workflow runs on pushes to `main` and can also be started manually.

It:

1. Checks out the repository
2. Installs Qt 6
3. Configures CMake with Visual Studio 2022
4. Builds the Release executable
5. Runs `windeployqt`
6. Creates a Windows x64 ZIP package
7. Uploads the package as a GitHub Actions artifact

Generated package:

```text
ZenWall-windows-x64.zip
```

---

## Controls

| Key | Action |
| --- | --- |
| **Left Arrow** | Previous wallpaper |
| **Right Arrow** | Next wallpaper |
| **Enter** | Apply selected wallpaper |
| **F** | Toggle favorite |
| **R** | Random wallpaper |
| **Escape** | Close ZenWall |

Mouse interaction is also supported through the selector and top bar.

---

## Top Bar

The compact top bar provides quick access to:

- All wallpapers
- Images
- Videos
- GIFs
- Sorting
- Favorites
- Random selection
- Rotation
- Monitor/output selection
- Color filters
- Search
- Settings
- Wallpaper count

---

## Wallpaper Management

### Favorites

Favorite wallpapers are stored using Qt settings so they can persist between launches.

### Search

Search filters wallpapers by filename.

### Sorting

Wallpapers can be sorted using the selector's sorting control.

### Random

The random action selects another wallpaper from the currently available collection.

### Rotation

ZenWall supports automatic wallpaper rotation using configurable intervals.

### Color Filtering

ZenWall can use wallpaper color information to provide hue-based filtering.

---

## Monitor Selection

ZenWall supports selecting the display where a wallpaper should be applied.

### Linux

The selected output is passed to **awww**.

### Windows

ZenWall detects Windows displays and uses the Windows Desktop Wallpaper API for the selected monitor.

---

## Media Support

### Images

Images are the main desktop wallpaper format supported by ZenWall.

### GIF

GIF files can be detected and previewed by the application.

Desktop GIF handling depends on the capabilities of the selected wallpaper backend.

### Video

Video files can be previewed inside ZenWall using **Qt Multimedia**.

Full desktop video wallpaper support is still under development.

---

## Architecture

ZenWall keeps the user interface cross-platform and isolates platform-specific wallpaper operations inside the C++ backend.

```text
                    ZenWall
                       |
                 Qt / QML UI
                       |
              WallpaperBackend
                 /          \
                /            \
             Linux         Windows
               |               |
             awww      IDesktopWallpaper
```

The QML interface is shared between platforms while the backend uses the native wallpaper mechanism for each operating system.

---

## Technology Stack

- **C++17**
- **Qt 6**
- **Qt Quick**
- **QML**
- **Qt Multimedia**
- **CMake**
- **Ninja**
- **awww** on Linux
- **Windows Desktop Wallpaper API** on Windows
- **GitHub Actions** for Windows builds

---

## Project Structure

```text
ZenWall/
├── .github/
│   └── workflows/
│       └── windows.yml
├── src/
│   ├── Main.qml
│   ├── SkewView.qml
│   ├── SkewCard.qml
│   ├── TopBar.qml
│   ├── SkewBarButton.qml
│   ├── WallpaperBackend.h
│   ├── WallpaperBackend.cpp
│   └── main.cpp
├── CMakeLists.txt
└── README.md
```

---

## Development

### Clean Linux build

```fish
rm -rf build
cmake -S . -B build -G Ninja
cmake --build build
```

### Clean Windows build

```powershell
cmake --fresh -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release
```

---

## Current Status

### Working

- Cross-platform Qt/QML interface
- Linux image wallpaper application
- Windows image wallpaper application
- Monitor/output selection
- Wallpaper filtering
- Favorites
- Search
- Random selection
- Rotation
- Color filtering
- Skew-style selector
- Video previews
- Linux awww integration
- Windows native wallpaper integration
- Automated Windows build and packaging

### Planned

- Background/daemon mode
- System tray integration
- Global hotkey
- Automatic startup
- Full desktop video wallpaper support
- Linux packaging
- Windows installer
- More customization
- More advanced animations

---

## Repository

**GitHub:** [github.com/zenyxsa/ZenWall](https://github.com/zenyxsa/ZenWall)

## License

The final project license will be added before the first stable release.

## Contributing

Bug reports, feature requests, testing, and code contributions are welcome.

Platform-specific wallpaper logic should stay inside the backend whenever possible so that the main QML interface remains cross-platform.
