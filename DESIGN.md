# Mirror design

The rules for what Mirror shows and how it behaves: the menu-bar icon, the popup, the buttons and the camera.
When the code and this file disagree, the code is correct. Update this file.

## Principles

- **One glance.** Mirror opens fast, shows you, and goes away. It has no settings window.
- **Camera off when hidden.** The camera runs only while the popup is open. The green camera light is on only then.
- **The video is the UI.** The video fills the popup, edge to edge. Buttons show only when the pointer is over the video.
- **Native first.** Use system controls, SF Symbols and the system Liquid Glass style. Add a custom look only for older macOS.

## Menu-bar icon

- Icon: `person.crop.square`.
- Left-click: opens or closes the popup.
- Right-click: closes the popup and shows the menu.

## Menu

| Item | Action |
|---|---|
| **Launch at Login** | Checkbox. Uses `SMAppService.mainApp`. Shows the state from `SMAppService` each time the menu opens. If macOS needs approval, opens System Settings › Login Items. |
| **Quit Mirror** (⌘Q) | Quits the app. |

## Popup

| Item | Value |
|---|---|
| Window | `NSPanel`, titled with a hidden, transparent title bar, full-size content, resizable, not movable, `.popUpMenu` level |
| Position | Under the menu-bar icon, centered on it, 4 pt below. Moved to stay 8 pt inside the visible frame of the screen |
| Size | Width 240–720 pt (drag resize). Default 320 pt. Height = width / camera ratio |
| Aspect ratio | Ratio of the camera format (16:9 on most Macs). Fixed with `contentAspectRatio` |
| Background | Black. The video uses `.resizeAspectFill` |
| Memory | The app saves the popup width in `UserDefaults` (`width`) on close. It does not save the enlarged size |

The popup closes on:

- A click on the menu-bar icon.
- `Esc`.
- A click outside the popup (the panel stops being the key window).

## Enlarged view

- The top-left button enlarges the popup to the largest frame with the camera ratio that fits in 90% of the visible screen. The frame is centered on the screen.
- The change is animated. A second click animates back to the popup frame.
- The enlarged view closes on the same events as the popup.
- A drag on an edge ends the enlarged state. The 720 pt limit then applies again.

## Buttons

All buttons are 28 × 28 pt, 8 pt from the edges, 36 pt apart. They are hidden until the pointer enters the video, and they hide again when it leaves.

| Position | Symbol | Action |
|---|---|---|
| Top left | `arrow.up.left.and.arrow.down.right` (enlarge), `arrow.down.right.and.arrow.up.left` (shrink) | Enlarges or shrinks the view |
| Top right | `arrow.left.and.right.righttriangle.left.righttriangle.right` | Turns mirroring on or off. Default: on. Saved in `UserDefaults` (`mirrored`) |
| Top right, second from the right | `person.crop.rectangle`, `.fill` when on | Turns Center Stage on or off. Shown only if the camera format supports Center Stage |

Style:

- macOS 26 and later: `NSButton` with the `.glass` bezel style.
- Older macOS: no border, white symbol, black 50% background, corner radius 14 pt.

## Camera

- Device: the built-in wide-angle camera. If there is none, the default video device.
- The app reads the camera ratio from the device format at launch. After the session adds the camera, the app sets the same format again, so the session preset cannot change the ratio.
- Mirroring uses the preview connection (`isVideoMirrored`), not a layer transform.
- Center Stage uses `centerStageControlMode = .cooperative`, so the app and Control Center can both change it.

## Messages

The message shows in the center of the video, in white.

| State | Message |
|---|---|
| No camera | "No camera found." |
| Access denied or restricted | "Camera access is off." with an **Open Settings** button. The button opens System Settings › Privacy & Security › Camera |

When access is not determined, macOS asks. If the popup closes before the answer, the camera does not start.
