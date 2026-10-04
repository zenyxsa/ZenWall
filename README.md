# ZenWall

A cross-platform wallpaper switcher built with **Qt 6, QML, C++, CMake, and Ninja**.

ZenWall is designed as a fullscreen transparent wallpaper selector with a compact **Skew-inspired interface**, allowing you to browse, filter, favorite, search, and apply wallpapers without using a traditional dashboard-style window.

## Features

* Fullscreen transparent wallpaper selector
* Skew-style wallpaper cards
* Image previews
* Video previews
* Mouse navigation
* Keyboard navigation
* Favorites
* Search
* Media type filters
* Sort wallpapers
* Random wallpaper selection
* Automatic wallpaper rotation
* Color filtering
* Monitor/output selection
* Wallpaper transitions on Linux
* Automatic wallpaper count
* Cross-platform Qt/QML interface

## Supported Platforms

### Linux

ZenWall uses **awww** as its Linux wallpaper backend.

Currently supported:

* Image wallpapers
* Per-monitor wallpaper selection
* Wallpaper transitions
* Random wallpapers
* Favorites
* Wallpaper rotation
* Wayland environments

### Windows

ZenWall uses the native **Windows Desktop Wallpaper API**.

Currently supported:

* Image wallpapers
* Monitor detection
* Individual monitor selection
* Multiple-monitor wallpaper handling
* Native Windows wallpaper management

## Linux Requirements

* Qt 6
* C++17 compiler
* CMake
* Ninja
* awww
* awww-daemon

### Arch Linux

Install the Qt/build dependencies:

```fish
sudo pacman -S --needed cmake ninja qt6-base qt6-declarative qt6-multimedia
```

Install `awww` separately if it is not already installed.

## Build on Linux

Clone the repository:

```fish
git clone https://github.com/zenyxsa/ZenWall.git
cd ZenWall
```

Configure:

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

Check the awww daemon:

```fish
awww query
```

If the daemon is not running:

```fish
awww-daemon &
```

## Windows Requirements

For building ZenWall from source:

* Windows 10 or Windows 11
* Qt 6
* Visual Studio 2022
* CMake
* Ninja

## Build on Windows

Clone the repository:

```powershell
git clone https://github.com/zenyxsa/ZenWall.git
cd ZenWall
```

Configure:

```powershell
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
```

Build:

```powershell
cmake --build build --config Release
```

The executable will be located at:

```text
build/Release/zenwall.exe
```

## Automated Windows Builds

ZenWall includes a GitHub Actions workflow:

```text
.github/workflows/windows.yml
```

Every push to the `main` branch automatically builds a Windows x64 version.

The workflow:

1. Installs Qt
2. Configures CMake
3. Builds ZenWall
4. Runs `windeployqt`
5. Packages the application
6. Uploads the Windows build as a GitHub Actions artifact

The generated package is:

```text
ZenWall-windows-x64.zip
```

## Controls

| Key         | Action                   |
| ----------- | ------------------------ |
| Left Arrow  | Previous wallpaper       |
| Right Arrow | Next wallpaper           |
| Enter       | Apply selected wallpaper |
| F           | Toggle favorite          |
| R           | Random wallpaper         |
| Escape      | Close ZenWall            |

## Top Bar

The top bar provides quick access to:

* All wallpapers
* Images
* Videos
* GIFs
* Sorting
* Favorites
* Random selection
* Rotation intervals
* Monitor/output selection
* Color filters
* Search
* Settings
* Wallpaper count

## Monitor Selection

ZenWall can target a specific display.

### Linux

The selected monitor is passed to `awww` using its output support.

### Windows

ZenWall detects Windows displays and maps the selected display to the native Windows Desktop Wallpaper API.

## Wallpaper Rotation

ZenWall supports automatic wallpaper rotation.

Available rotation intervals include:

* 5 minutes
* 15 minutes
* 30 minutes
* 1 hour

## Favorites

Favorite wallpapers are stored using Qt settings so that the selection persists between launches.

## Search

The search control allows wallpapers to be filtered by filename.

## Color Filtering

ZenWall can analyze wallpaper colors and provide hue-based filtering.

This allows you to quickly find wallpapers with similar color characteristics.

## Media Support

### Images

Images are the primary supported desktop wallpaper type on both platforms.

### GIF

GIF files can be detected and previewed by ZenWall.

Actual desktop GIF support depends on the wallpaper backend being used.

### Video

Video files can be previewed inside the ZenWall selector using **Qt Multimedia**.

Desktop video wallpaper application is still under development.

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

## Architecture

ZenWall keeps the interface cross-platform while separating wallpaper operations into a platform-aware C++ backend.

```text
             ZenWall UI
                 |
             Qt / QML
                 |
        WallpaperBackend
           /           \
        Linux         Windows
          |              |
        awww       Windows Desktop
                   Wallpaper API
```

This allows the same QML interface to be used on both platforms while each operating system uses its own wallpaper system.

## Technology Stack

* **C++17**
* **Qt 6**
* **QML**
* **Qt Quick**
* **Qt Multimedia**
* **CMake**
* **Ninja**
* **awww** on Linux
* **Windows Desktop Wallpaper API** on Windows
* **GitHub Actions** for automated Windows builds

## Current Status

ZenWall is currently under active development.

### Working

* Linux build
* Windows build
* Cross-platform Qt/QML interface
* Skew wallpaper selector
* Wallpaper filtering
* Favorites
* Search
* Random selection
* Rotation
* Color filtering
* Monitor selection
* Linux awww integration
* Windows native wallpaper integration
* Automated Windows GitHub Actions build

### Planned

* Background/daemon mode
* System tray integration
* Global hotkey
* Automatic startup
* Full desktop video wallpaper support
* Linux packaging
* Windows installer
* Additional customization
* More advanced Skew animations

## Development

Clean Linux build:

```fish
rm -rf build
cmake -S . -B build -G Ninja
cmake --build build
```

Clean Windows build:

```powershell
cmake --fresh -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release
```

## Repository

**GitHub:**
https://github.com/zenyxsa/ZenWall

## License

ZenWall's final license will be added before the first stable release.

## Contributing

Bug reports, feature suggestions, testing, and code contributions are welcome.

Platform-specific functionality should remain inside the wallpaper backend whenever possible so that the main QML interface stays cross-platform.
