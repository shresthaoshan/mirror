import AppKit
import XCTest
@testable import Mirror

final class PanelTests: XCTestCase {
    // Regression: a drag after enlarge left popupFrame set, so close saved the old width.
    func testManualResizeClearsExpandedState() {
        _ = NSApplication.shared
        let panel = Panel()
        panel.toggleExpanded()
        XCTAssertNotNil(panel.popupFrame)
        panel.windowWillStartLiveResize(Notification(name: NSWindow.willStartLiveResizeNotification))
        XCTAssertNil(panel.popupFrame)
    }
}
