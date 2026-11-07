# Mirror

A macOS menu-bar app. Click the icon to see yourself with the front camera.

## Requirements

- macOS 13 or later (macOS 26 for Liquid Glass buttons)
- Xcode 26 (the build needs the macOS 26 SDK)

## Build and install

```sh
./build.sh
cp -R Mirror.app /Applications/
open /Applications/Mirror.app
```

`build.sh` builds a release binary, wraps it in `Mirror.app`, and signs it ad-hoc.

Run the tests with `swift test`.

## Use

- Click the menu-bar icon to open the popup. Click it again, press `Esc`, or click outside to close it.
- Drag an edge or a corner to resize. Width is 240–720 pt. The aspect ratio stays fixed.
- The app remembers the last popup size.
- The camera runs only while the popup is open.
- Right-click the icon for the menu: **Launch at Login** and **Quit Mirror**.

### Buttons

The buttons show when the pointer is over the video.

| Position | Button | Action |
|---|---|---|
| Top left | Enlarge | Grows the view to 90% of the screen, centered. Click again to shrink. |
| Top right | Mirror | Turns mirroring on or off. Default: on. The app remembers it. |
| Top right, left of Mirror | Center Stage | Turns Center Stage on or off. The icon is filled when it is on. Shows only if the camera supports it. Control Center can also change it. |

On macOS 26, the buttons use the Liquid Glass style. On older macOS, they are dark round buttons.

A click outside or `Esc` also closes the enlarged view. If you drag an edge while the view is enlarged, it snaps back to 720 pt or less and is no longer enlarged.

## Camera permission

macOS asks for camera access the first time you open the popup.
If you deny it, the popup shows an **Open Settings** button.

Each rebuild gets a new ad-hoc signature, so macOS can ask again after `./build.sh`.

## Launch at login

Install the app in `/Applications` before you turn on **Launch at Login**.
If you move the app after that, turn the option off and on again.
