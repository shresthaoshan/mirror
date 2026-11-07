import AppKit

/// Popup under the status item. Resizable within 240–720 pt width; aspect ratio is fixed.
final class Panel: NSPanel, NSWindowDelegate {
    private let camera = CameraView(frame: NSRect(x: 0, y: 0, width: 320, height: 180))

    init() {
        super.init(contentRect: .zero, styleMask: [.titled, .fullSizeContentView, .resizable],
                   backing: .buffered, defer: true)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        [.closeButton, .miniaturizeButton, .zoomButton].forEach { standardWindowButton($0)?.isHidden = true }
        isMovable = false
        isReleasedWhenClosed = false
        level = .popUpMenu
        backgroundColor = .black
        delegate = self
        contentView = camera
        let r = camera.ratio
        contentAspectRatio = NSSize(width: r, height: 1)
        contentMinSize = NSSize(width: 240, height: 240 / r)
        contentMaxSize = NSSize(width: 720, height: 720 / r)
    }

    func toggle(below button: NSStatusBarButton) {
        if isVisible { close(); return }
        guard let anchor = button.window?.frame, let screen = button.window?.screen?.visibleFrame else { return }
        let width = min(max(UserDefaults.standard.double(forKey: "width"), 240), 720)
        setContentSize(NSSize(width: width, height: width / camera.ratio))
        let x = min(max(anchor.midX - width / 2, screen.minX + 8), screen.maxX - width - 8)
        setFrameTopLeftPoint(NSPoint(x: x, y: anchor.minY - 4))
        NSApp.activate(ignoringOtherApps: true)
        makeKeyAndOrderFront(nil)
        camera.start()
    }

    override func close() {
        guard isVisible else { return } // right-click before first open must not save width 0
        camera.stop()
        UserDefaults.standard.set(frame.width, forKey: "width")
        super.close()
    }

    override func cancelOperation(_ sender: Any?) { close() } // Esc
    func windowDidResignKey(_ notification: Notification) { close() } // click outside
}
