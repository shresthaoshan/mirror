# Mirror

A minimal camera mirror for macOS. It lives in the menu bar. Click the icon to check yourself with the front camera.

**Website:** [mirror.shresthaoshan.com](https://mirror.shresthaoshan.com/)

- No dependencies. Swift and AppKit only.
- The camera runs only while the popup is open.
- No video is saved or sent anywhere.

## Why Mirror

Before a call, you want to check your hair, your light, or what is behind you.
Photo Booth and FaceTime open a full app window for this, and they take time to start.

Mirror does one job: one click shows you, and one more click hides you again.

## Features

- **Menu-bar popup.** Shows the live camera under the menu-bar icon.
- **Global shortcut (⌃⌘M).** Opens and closes the popup from any app.
- **Resize.** Drag an edge or a corner. The aspect ratio stays fixed.
- **Enlarged view.** One button grows the view to 90% of the screen.
- **Mirror toggle.** See yourself as in a mirror, or as others see you.
- **Center Stage.** Turn it on or off, if your camera supports it.
- **Liquid Glass.** The buttons use the Liquid Glass style on macOS 26.
- **Launch at login.**

## Requirements

- macOS 13 (Ventura) or later. macOS 26 (Tahoe) for the Liquid Glass buttons
- Xcode 26 or later, to build (the build needs the macOS 26 SDK)

## Install

Mirror has no prebuilt release yet. Build it from source:

```bash
git clone https://github.com/shresthaoshan/mirror.git
cd mirror
make app
mv Mirror.app /Applications/
open /Applications/Mirror.app
```

The person icon appears in the menu bar. Mirror has no Dock icon.

## Build from source

```bash
make run
```

`make run` builds a release binary, puts it in `Mirror.app`, signs it ad hoc and opens it. Other targets:

| Command      | What it does                              |
|--------------|-------------------------------------------|
| `make app`   | Builds `Mirror.app` and does not open it. |
| `make test`  | Runs the tests (`swift test`).            |
| `make clean` | Removes `.build` and `Mirror.app`.        |

### Signing

`make app` signs the app ad hoc (`codesign --sign -`). This is enough to run Mirror on your own Mac.

An ad hoc signature changes with each build. macOS uses the signature to identify the app, so after a rebuild macOS can ask for camera access again, and you may need to turn **Launch at Login** off and on again.
For a stable signature, sign with an Apple Development certificate. It is free with an Apple ID: in Xcode, open Settings › Accounts and add a certificate. Then change the `codesign` line in the `Makefile`:

```make
codesign --force --sign "Apple Development" $(APP)
```

### Permissions

Mirror needs only camera access. macOS asks the first time you open the popup.
The ⌃⌘M shortcut uses `RegisterEventHotKey`, which does not need Accessibility access.
If you deny it, the popup shows an **Open Settings** button.

**Launch at Login** can need your approval in System Settings › General › Login Items. Mirror opens that page when macOS asks for approval.

## Usage

### Popup

- Click the menu-bar icon or press **⌃⌘M** to open the popup. Click the icon or press ⌃⌘M again, press `Esc`, or click outside to close it.
- Drag an edge or a corner to resize. Width is 240–720 pt. The aspect ratio stays fixed.
- Mirror remembers the last popup size.
- The camera runs only while the popup is open.

### Buttons

The buttons show when the pointer is over the video.

| Position | Button | Action |
|---|---|---|
| Top left | Enlarge | Grows the view to 90% of the screen, centered. Click again to shrink. |
| Top right | Mirror | Turns mirroring on or off. Default: on. Mirror remembers it. |
| Top right, left of Mirror | Center Stage | Turns Center Stage on or off. The icon is filled when it is on. Shows only if the camera supports it. Control Center can also change it. |

A click outside or `Esc` also closes the enlarged view. If you drag an edge while the view is enlarged, it snaps back to 720 pt or less and is no longer enlarged.

On older macOS, the buttons are dark and round in place of Liquid Glass.

### Menu

Right-click the menu-bar icon:

- **Launch at Login.** Install Mirror in `/Applications` before you turn it on.
- **Quit Mirror** (⌘Q).

## Privacy

- Mirror shows the camera only on your screen. It does not record, save or send video.
- The camera stops when the popup closes. The green camera light shows when it runs.
- Mirror saves two settings in `UserDefaults`: the popup width and the mirror state.

## Known limitations

- Mirror uses the built-in camera. You cannot choose another camera.
- If no camera is connected when Mirror starts, connect one and then quit and open Mirror.
- The Liquid Glass buttons are not tested on macOS 26 yet.
- Mirror does not remember the enlarged view. It always opens as the popup.

## Troubleshooting

**⌃⌘M does nothing.**
Right-click the menu-bar icon. If the menu says "⌃⌘M is in use by another app", another app holds the shortcut. Quit that app or change its shortcut, then quit and open Mirror.

**The popup says "Camera access is off."**
Click **Open Settings** and turn on Mirror in Privacy & Security › Camera. Then close and open the popup.

**macOS asks for camera access again after a rebuild.**
The ad hoc signature changed. Allow access again, or sign with a stable certificate (see [Signing](#signing)).

**The popup says "No camera found."**
Connect a camera, then quit and open Mirror.

**Launch at Login does not work.**
Move `Mirror.app` to `/Applications`, then turn the option off and on. If macOS opens Login Items, approve Mirror there. After a rebuild with ad hoc signing, turn the option off and on again.

## Uninstall

1. Right-click the menu-bar icon and turn off **Launch at Login**.
2. Quit Mirror (right-click › **Quit Mirror**).
3. Delete `Mirror.app`.
4. Delete the settings:

```bash
defaults delete com.shresthaoshan.mirror
```

5. Optional: remove camera access:

```bash
tccutil reset Camera com.shresthaoshan.mirror
```

## Project structure

```
Sources/Mirror/
  main.swift          App entry, menu-bar icon, menu, launch at login
  HotKey.swift        Global ⌃⌘M shortcut
  Panel.swift         Popup window: position, resize, enlarge, close
  CameraView.swift    Camera session, preview, hover buttons, permission message
Tests/MirrorTests/    XCTest tests for the popup window
Info.plist            App bundle settings (menu bar only, camera usage text)
Makefile              Build, run and test commands
```

## Contributing

Bug reports, ideas and pull requests are welcome. Read [CONTRIBUTING.md](https://github.com/shresthaoshan/mirror/blob/main/CONTRIBUTING.md) for the setup, how the code works, and how to send a change. [DESIGN.md](https://github.com/shresthaoshan/mirror/blob/main/DESIGN.md) has the UI rules.

## License

Mirror is released under the [MIT License](https://github.com/shresthaoshan/mirror/blob/main/LICENSE).
