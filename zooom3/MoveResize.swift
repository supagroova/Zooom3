import Foundation
import AppKit

@objc class MoveResize: NSObject {

    private static let shared = MoveResize()

    @objc static func instance() -> MoveResize {
        return shared
    }

    @objc var eventTap: CFMachPort? {
        willSet {
            // CFMachPort is managed by CF; release old if set
        }
    }

    @objc var runLoopSource: CFRunLoopSource?

    @objc var resizeSection = ResizeSection(xResizeDirection: noX, yResizeDirection: noY)

    @objc var tracking: CFTimeInterval = 0

    @objc var wndPosition: NSPoint = .zero

    @objc var wndSize: NSSize = .zero

    @objc var isResizing: Bool = false

    @objc var isHoverActive: Bool = false

    private var _window: AXUIElement?

    @objc var window: AXUIElement? {
        get { return _window }
        set { _window = newValue }
    }

    private override init() {
        super.init()
    }
}
