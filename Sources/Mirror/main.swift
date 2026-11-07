import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "person.crop.square", accessibilityDescription: "Mirror")
        button.target = self
        button.action = #selector(clicked)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        menu.addItem(withTitle: "Quit Mirror", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    @objc func clicked(_ button: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 4), in: button)
        }
    }
}

let app = NSApplication.shared // must exist before AppDelegate creates the status item
let delegate = AppDelegate()
app.delegate = delegate
app.run()
