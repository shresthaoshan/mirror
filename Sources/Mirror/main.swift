import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
