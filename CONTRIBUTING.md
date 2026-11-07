# Contributing to Mirror

Thank you for your help. This guide explains how to set up the project, how the code is organized, and how to send a change.

## Before you start

- For a bug fix or a small change, you can open a pull request directly.
- For a new feature or a larger change, open an issue first. Then we can agree on the design before you write code.
- Do not add a new dependency without discussion in an issue. Mirror has no dependencies, and we want to keep it that way.
- Mirror is minimal on purpose. A feature that most users do not need is likely to be declined.

## Set up

You need macOS 13 or later and Xcode 26 or later. The build needs the macOS 26 SDK for the Liquid Glass APIs.

```bash
git clone https://github.com/shresthaoshan/mirror.git
cd mirror
swift build
swift test
make run
```

`make run` builds `Mirror.app`, signs it ad hoc and opens it. If Mirror is already running, quit it first (right-click the menu-bar icon › Quit Mirror).

Use `make run`, not `swift run`. Without the `.app` bundle, the app has no `Info.plist`. Then camera access and launch at login do not work correctly, and the app shows a Dock icon.

## How the code works

```
NSStatusItem ──left-click──▶ Panel.toggle ──▶ CameraView.start ──▶ AVCaptureSession ──▶ preview layer
     │                          │  ▲
 right-click                    │  └── onExpand (top-left button) ──▶ Panel.toggleExpanded
     ▼                          ▼
   NSMenu              close: Esc, click outside, icon ──▶ CameraView.stop
```

1. `main.swift` creates `NSApplication` first, then `AppDelegate`. The status item needs the app object to exist.
   - `AppDelegate` owns the status item, the menu and the `Panel`.
   - Left-click toggles the panel. Right-click closes the panel and shows the menu.
   - **Launch at Login** uses `SMAppService.mainApp`.
2. `Panel` is the popup window.
   - It sets `contentAspectRatio`, `contentMinSize` and `contentMaxSize` from the camera ratio.
   - It closes on `Esc` (`cancelOperation`) and when it stops being the key window (`windowDidResignKey`).
   - `close` stops the camera and saves the width. It does nothing when the panel is hidden.
   - `toggleExpanded` animates to 90% of the screen and back. `popupFrame` is the frame to go back to, and it is set only while the view is enlarged.
3. `CameraView` is the content view.
   - It owns the `AVCaptureSession` and the preview layer.
   - `start` checks camera permission. The session starts and stops on a private serial queue, because `startRunning` blocks.
   - It owns the hover buttons: enlarge, mirror and Center Stage.

### Rules

- The camera must run only while the popup is open. Each path that hides the popup must go through `Panel.close`.
- Do not start the camera after the popup closes. For example, if the permission answer comes after a close, do nothing.
- An animated `setFrame` sends `windowWillStartLiveResize`. Code in that delegate method must not undo the state of `toggleExpanded`.
- `setFrame` ignores `contentMaxSize`. The 720 pt limit applies only to drag resize.
- Mirror must ask only for camera access. A change that needs another permission must be optional and off by default.

## Tests

- `swift test` must pass before you send a pull request. CI runs it on each push and pull request.
- For a bug fix, add a test that fails before the fix.
- Tests must not change real system state: no camera session, no real login item.
- Window tests can use a real `Panel`. It does not start the camera until `toggle` opens it. On CI there is no camera, so the ratio is 16:9.

### Test in the running app

Unit tests cannot check the camera, the menu bar or the pointer. Before you send a UI change:

1. Quit Mirror, then run `make run`.
2. Open the popup from the menu-bar icon. Check the video and the camera light.
3. Resize from an edge and from a corner. The ratio must stay fixed.
4. Hover over the video. Click each button: enlarge and shrink, mirror, Center Stage.
5. Close the popup with `Esc`, with a click outside, and with the icon. The camera light must go off each time.

In the pull request, write which Mac and which macOS version you used.

## Code style

- For the popup, the buttons and the menu, follow [DESIGN.md](DESIGN.md).
- Match the code around your change: names, comment density, and idioms.
- Keep changes small. Prefer the standard library and system frameworks to new code.
- Write comments that explain **why**, not what.
- No compiler warnings.

## AI-assisted contributions

You can use AI tools, such as coding assistants, to write code, tests, or documentation. Mirror itself was built with AI assistance.

- **Disclose it.** In the pull request, say which parts an AI tool wrote or changed.
- **You are responsible for the change.** Read, understand, and test every line before you send it. You must be able to explain the change in review.
- **Test in the running app.** An AI tool cannot see the camera or the popup. UI changes must be tested as described in [Test in the running app](#test-in-the-running-app).
- **No unreviewed output.** Pull requests and bug reports that look like unreviewed AI output are closed without review.

## Commits and pull requests

- One change for each pull request.
- Commit subject: [Conventional Commits](https://www.conventionalcommits.org/) in the imperative mood, for example `feat: add zoom button` or `fix: keep ratio after resize`. Use the body for details.
- For a commit that changes only documentation, add `[skip ci]` to the subject.
- In the pull request, describe what changed, why, and how you tested it.

## Report a bug

Open an issue with:

- Your macOS version, Mac model and camera.
- The Mirror version or commit.
- Where it happens: the menu, the popup, the enlarged view, a button, camera permission, or launch at login.
- The steps to reproduce, what you expected, and what happened.

Do not attach screenshots that show you or your room unless you want them public.

## License

Mirror uses the [MIT License](LICENSE). When you send a pull request, you agree that your contribution is released under the same license.
