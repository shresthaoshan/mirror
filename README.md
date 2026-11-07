# Mirror

A macOS menu-bar app. Click the icon to see yourself with the front camera.

## Requirements

- macOS 13 or later
- Swift 5.9 or later (Xcode Command Line Tools)

## Build

```sh
./build.sh
open Mirror.app
```

`build.sh` builds a release binary, wraps it in `Mirror.app`, and signs it ad-hoc.

## Use

- Click the menu-bar icon to open the popup. Click it again, press `Esc`, or click outside to close it.
- Drag an edge or a corner to resize. Width is 240–720 pt. The aspect ratio stays fixed.
- The app remembers the last size.
- Right-click the icon for the menu.
