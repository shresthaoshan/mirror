import AppKit

/// Popup under the status item: camera inside a glass border.
/// Video width is 240–720 pt; its aspect ratio is fixed.
final class Panel: NSPanel, NSWindowDelegate {
    private let camera = CameraView(frame: NSRect(x: 0, y: 0, width: 320, height: 180))
    private let border: CGFloat = 6

    init() {
        // Non-zero start size: the inset constraints cannot go negative. toggle() sets the real size.
        super.init(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300), styleMask: [.titled, .fullSizeContentView, .resizable],
                   backing: .buffered, defer: true)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        [.closeButton, .miniaturizeButton, .zoomButton].forEach { standardWindowButton($0)?.isHidden = true }
        isMovable = false
        isReleasedWhenClosed = false
        level = .popUpMenu
        backgroundColor = .clear
        isOpaque = false
        delegate = self

        let inner = NSView(frame: NSRect(origin: .zero, size: size(videoWidth: camera.frame.width)))
        inner.autoresizingMask = [.width, .height]
        camera.layer?.cornerRadius = 10
        camera.layer?.masksToBounds = true
        inner.addSubview(camera)
        // Constraints, not autoresizing: autoresizing loses the inset if the view ever shrinks below it.
        camera.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            camera.leadingAnchor.constraint(equalTo: inner.leadingAnchor, constant: border),
            camera.trailingAnchor.constraint(equalTo: inner.trailingAnchor, constant: -border),
            camera.topAnchor.constraint(equalTo: inner.topAnchor, constant: border),
            camera.bottomAnchor.constraint(equalTo: inner.bottomAnchor, constant: -border),
        ])
        if #available(macOS 26, *) {
            let glass = NSGlassEffectView()
            glass.cornerRadius = 16
            glass.contentView = inner
            contentView = glass
        } else {
            let blur = NSVisualEffectView()
            blur.material = .hudWindow
            blur.state = .active
            blur.frame = inner.frame
            blur.addSubview(inner)
            contentView = blur
        }
    }

    /// Video size for a video width, plus the border.
    private func size(videoWidth: CGFloat) -> NSSize {
        let w = min(max(videoWidth, 240), 720)
        return NSSize(width: w + 2 * border, height: w / camera.ratio + 2 * border)
    }

    // contentAspectRatio cannot add a fixed border, so fix the ratio here.
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        let dragsHeight = abs(frameSize.height - frame.height) > abs(frameSize.width - frame.width)
        return size(videoWidth: dragsHeight ? (frameSize.height - 2 * border) * camera.ratio
                                            : frameSize.width - 2 * border)
    }

    func toggle(below button: NSStatusBarButton) {
        if isVisible { close(); return }
        guard let anchor = button.window?.frame, let screen = button.window?.screen?.visibleFrame else { return }
        let size = size(videoWidth: UserDefaults.standard.double(forKey: "width"))
        setContentSize(size)
        let x = min(max(anchor.midX - size.width / 2, screen.minX + 8), screen.maxX - size.width - 8)
        setFrameTopLeftPoint(NSPoint(x: x, y: anchor.minY - 4))
        NSApp.activate(ignoringOtherApps: true)
        makeKeyAndOrderFront(nil)
        camera.start()
    }

    override func close() {
        guard isVisible else { return } // right-click before first open must not save width 0
        camera.stop()
        UserDefaults.standard.set(frame.width - 2 * border, forKey: "width")
        super.close()
    }

    override func cancelOperation(_ sender: Any?) { close() } // Esc
    func windowDidResignKey(_ notification: Notification) { close() } // click outside
}
