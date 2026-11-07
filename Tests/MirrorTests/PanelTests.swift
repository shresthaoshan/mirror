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

    // Regression: the enlarge animation sends willStartLiveResize, which cleared popupFrame,
    // so the second click enlarged again instead of shrinking.
    func testSecondToggleRestoresPopupFrame() {
        _ = NSApplication.shared
        let panel = Panel()
        panel.setFrame(NSRect(x: 100, y: 100, width: 320, height: 180), display: false)
        panel.orderFront(nil) // live resize notifications need an on-screen window
        let popup = panel.frame
        panel.toggleExpanded()
        XCTAssertEqual(panel.popupFrame, popup)
        panel.toggleExpanded()
        XCTAssertNil(panel.popupFrame)
        XCTAssertEqual(panel.frame, popup)
    }
}
