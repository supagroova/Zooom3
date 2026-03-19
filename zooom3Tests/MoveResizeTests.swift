import XCTest
@testable import Zooom3

final class MoveResizeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let mr = MoveResize.instance()
        mr.tracking = 0
        mr.isResizing = false
        mr.window = nil
        mr.isHoverActive = false
    }

    // MARK: - Singleton

    func testInstanceReturnsSameObject() {
        let a = MoveResize.instance()
        let b = MoveResize.instance()
        XCTAssertTrue(a === b, "instance should return the same singleton object")
    }

    func testInstanceIsNotNil() {
        XCTAssertNotNil(MoveResize.instance())
    }

    // MARK: - isResizing

    func testIsResizingDefaultsToFalse() {
        XCTAssertFalse(MoveResize.instance().isResizing)
    }

    func testSetIsResizingToTrue() {
        let mr = MoveResize.instance()
        mr.isResizing = true
        XCTAssertTrue(mr.isResizing)
    }

    func testSetIsResizingBackToFalse() {
        let mr = MoveResize.instance()
        mr.isResizing = true
        mr.isResizing = false
        XCTAssertFalse(mr.isResizing)
    }

    // MARK: - tracking

    func testTrackingDefaultsToZero() {
        XCTAssertEqual(MoveResize.instance().tracking, 0)
    }

    func testSetTracking() {
        let mr = MoveResize.instance()
        let now = CACurrentMediaTime()
        mr.tracking = now
        XCTAssertEqual(mr.tracking, now)
    }

    func testClearTracking() {
        let mr = MoveResize.instance()
        mr.tracking = CACurrentMediaTime()
        mr.tracking = 0
        XCTAssertEqual(mr.tracking, 0)
    }

    // MARK: - resizeSection

    func testResizeSectionStorage() {
        let mr = MoveResize.instance()
        var section = ResizeSection()
        section.xResizeDirection = left
        section.yResizeDirection = top
        mr.resizeSection = section

        let retrieved = mr.resizeSection
        XCTAssertEqual(retrieved.xResizeDirection, left)
        XCTAssertEqual(retrieved.yResizeDirection, top)
    }

    func testResizeSectionAllDirections() {
        let mr = MoveResize.instance()

        var section1 = ResizeSection(xResizeDirection: right, yResizeDirection: bottom)
        mr.resizeSection = section1
        let r1 = mr.resizeSection
        XCTAssertEqual(r1.xResizeDirection, right)
        XCTAssertEqual(r1.yResizeDirection, bottom)

        var section2 = ResizeSection(xResizeDirection: noX, yResizeDirection: noY)
        mr.resizeSection = section2
        let r2 = mr.resizeSection
        XCTAssertEqual(r2.xResizeDirection, noX)
        XCTAssertEqual(r2.yResizeDirection, noY)
    }

    // MARK: - wndPosition and wndSize

    func testWndPositionStorage() {
        let mr = MoveResize.instance()
        mr.wndPosition = NSPoint(x: 100.0, y: 200.0)
        XCTAssertEqual(mr.wndPosition.x, 100.0)
        XCTAssertEqual(mr.wndPosition.y, 200.0)
    }

    func testWndSizeStorage() {
        let mr = MoveResize.instance()
        mr.wndSize = NSSize(width: 800.0, height: 600.0)
        XCTAssertEqual(mr.wndSize.width, 800.0)
        XCTAssertEqual(mr.wndSize.height, 600.0)
    }

    // MARK: - State lifecycle

    func testStateLifecycleMoveOperation() {
        let mr = MoveResize.instance()

        mr.tracking = CACurrentMediaTime()
        mr.isResizing = false
        XCTAssertTrue(mr.tracking > 0)
        XCTAssertFalse(mr.isResizing)

        mr.tracking = 0
        mr.isResizing = false
        XCTAssertEqual(mr.tracking, 0)
        XCTAssertFalse(mr.isResizing)
    }

    func testStateLifecycleResizeOperation() {
        let mr = MoveResize.instance()

        mr.tracking = CACurrentMediaTime()
        mr.isResizing = true
        mr.resizeSection = ResizeSection(xResizeDirection: right, yResizeDirection: bottom)
        mr.wndPosition = NSPoint(x: 50, y: 50)
        mr.wndSize = NSSize(width: 400, height: 300)

        XCTAssertTrue(mr.tracking > 0)
        XCTAssertTrue(mr.isResizing)
        XCTAssertEqual(mr.resizeSection.xResizeDirection, right)
        XCTAssertEqual(mr.wndSize.width, 400.0)

        mr.tracking = 0
        mr.isResizing = false
        XCTAssertEqual(mr.tracking, 0)
        XCTAssertFalse(mr.isResizing)
    }

    // MARK: - isHoverActive

    func testIsHoverActiveDefaultsToFalse() {
        XCTAssertFalse(MoveResize.instance().isHoverActive)
    }

    func testSetIsHoverActiveToTrue() {
        let mr = MoveResize.instance()
        mr.isHoverActive = true
        XCTAssertTrue(mr.isHoverActive)
        mr.isHoverActive = false
    }

    func testSetIsHoverActiveBackToFalse() {
        let mr = MoveResize.instance()
        mr.isHoverActive = true
        mr.isHoverActive = false
        XCTAssertFalse(mr.isHoverActive)
    }

    // MARK: - Hover lifecycle

    func testHoverMoveLifecycle() {
        let mr = MoveResize.instance()

        mr.tracking = CACurrentMediaTime()
        mr.isResizing = false
        mr.isHoverActive = true
        XCTAssertTrue(mr.tracking > 0)
        XCTAssertFalse(mr.isResizing)
        XCTAssertTrue(mr.isHoverActive)

        mr.isHoverActive = false
        mr.tracking = 0
        XCTAssertEqual(mr.tracking, 0)
        XCTAssertFalse(mr.isHoverActive)
    }

    func testHoverResizeLifecycle() {
        let mr = MoveResize.instance()

        mr.tracking = CACurrentMediaTime()
        mr.isResizing = true
        mr.isHoverActive = true
        mr.resizeSection = ResizeSection(xResizeDirection: right, yResizeDirection: bottom)
        mr.wndPosition = NSPoint(x: 50, y: 50)
        mr.wndSize = NSSize(width: 400, height: 300)

        XCTAssertTrue(mr.isHoverActive)
        XCTAssertTrue(mr.isResizing)

        mr.isHoverActive = false
        mr.tracking = 0
        mr.isResizing = false
        XCTAssertFalse(mr.isHoverActive)
        XCTAssertEqual(mr.tracking, 0)
        XCTAssertFalse(mr.isResizing)
    }

    // MARK: - Window (AXUIElementRef)

    func testWindowDefaultsToNil() {
        XCTAssertTrue(MoveResize.instance().window == nil)
    }

    func testSetAndClearWindow() {
        let mr = MoveResize.instance()
        let systemWide = AXUIElementCreateSystemWide()
        mr.window = systemWide
        XCTAssertNotNil(mr.window)
        mr.window = nil
        XCTAssertTrue(mr.window == nil)
    }
}
