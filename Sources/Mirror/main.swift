import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()
    let panel = Panel()
    let login = NSMenuItem(title: "Launch at Login", action: #selector(toggleLogin), keyEquivalent: "")

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "person.crop.square", accessibilityDescription: "Mirror")
        button.target = self
        button.action = #selector(clicked)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        HotKey.register { [unowned self] in panel.toggle(below: button) }
        if !HotKey.isRegistered {
            menu.addItem(withTitle: "⌃⌘M is in use by another app", action: nil, keyEquivalent: "")
            menu.addItem(.separator())
        }

        login.target = self
        menu.addItem(login)
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Mirror", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    @objc func clicked(_ button: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            panel.close()
            login.state = SMAppService.mainApp.status == .enabled ? .on : .off
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 4), in: button)
        } else {
            panel.toggle(below: button)
        }
    }

    @objc func toggleLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled { try service.unregister() } else { try service.register() }
            if service.status == .requiresApproval { SMAppService.openSystemSettingsLoginItems() }
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}

let app = NSApplication.shared // must exist before AppDelegate creates the status item
UserDefaults.standard.register(defaults: ["width": 320, "mirrored": true])
let delegate = AppDelegate()
app.delegate = delegate
app.run()
