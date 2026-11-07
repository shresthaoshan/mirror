# Mirror

A macOS menu-bar app. Click the icon to see yourself with the front camera.

## Requirements

- macOS 13 or later (macOS 26 for Liquid Glass)
- macOS 26 SDK to build (Xcode 26)
- Swift 5.9 or later (Xcode Command Line Tools)

## Build

```sh
./build.sh
open Mirror.app
```

`build.sh` builds a release binary, wraps it in `Mirror.app`, and signs it ad-hoc.

## Look

The video fills the popup. On macOS 26, the hover buttons use the Liquid Glass style.
On older macOS, they are dark round buttons.

## Install

```sh
./build.sh
cp -R Mirror.app /Applications/
open /Applications/Mirror.app
```

## Use

- Click the menu-bar icon to open the popup. Click it again, press `Esc`, or click outside to close it.
- Drag an edge or a corner to resize. Width is 240–720 pt. The aspect ratio stays fixed.
- The app remembers the last size.
- Right-click the icon for the menu: **Launch at Login** and **Quit Mirror**.
- The camera runs only while the popup is open.
- Hover over the popup and click the arrows button (top right) to turn mirroring on or off. Mirroring is on by default.
- If the camera supports Center Stage, a second button turns it on or off. The icon is filled when Center Stage is on. Control Center can also change it.

## Camera permission

macOS asks for camera access the first time you open the popup.
If you deny it, the popup shows an **Open Settings** button.

Each rebuild gets a new ad-hoc signature, so macOS can ask again after `./build.sh`.

## Launch at login

Install the app in `/Applications` before you turn on **Launch at Login**.
If you move the app after that, turn the option off and on again.
