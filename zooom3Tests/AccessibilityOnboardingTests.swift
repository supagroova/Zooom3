import XCTest
import SwiftUI
@testable import Zooom3

@available(macOS 13.0, *)
final class AccessibilityOnboardingTests: XCTestCase {

    // MARK: - View instantiation

    func testOnboardingViewCreation() {
        let view = AccessibilityOnboardingView(onOpenSettings: {})
        XCTAssertNotNil(view)
    }

    // MARK: - Hosting view renders

    func testHostingViewCreation() {
        let view = AccessibilityOnboardingView(onOpenSettings: {})
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: 500, height: 600)
        hosting.layout()
        XCTAssertNotNil(hosting)
        XCTAssertGreaterThan(hosting.subviews.count, 0)
    }

    // MARK: - Open Settings callback fires

    func testOpenSettingsCallback() {
        var called = false
        let view = AccessibilityOnboardingView(onOpenSettings: { called = true })
        view.onOpenSettings()
        XCTAssertTrue(called)
    }

    // MARK: - Bridge instantiation

    func testBridgeCreation() {
        let bridge = AccessibilityOnboardingBridge()
        XCTAssertNotNil(bridge)
    }

    func testBridgeCreatesWindow() {
        let bridge = AccessibilityOnboardingBridge()
        XCTAssertNotNil(bridge.window)
    }

    func testBridgeWindowIsNotVisibleByDefault() {
        let bridge = AccessibilityOnboardingBridge()
        XCTAssertFalse(bridge.window.isVisible)
    }

    // MARK: - Callback wiring

    func testOnPermissionGrantedCallback() {
        var called = false
        let bridge = AccessibilityOnboardingBridge()
        bridge.onPermissionGranted = { called = true }
        bridge.onPermissionGranted?()
        XCTAssertTrue(called)
    }

    // MARK: - Polling lifecycle

    func testStartPollingSetsTimer() {
        let bridge = AccessibilityOnboardingBridge()
        bridge.startPolling()
        XCTAssertTrue(bridge.isPolling)
        bridge.stopPolling()
    }

    func testStopPollingClearsTimer() {
        let bridge = AccessibilityOnboardingBridge()
        bridge.startPolling()
        bridge.stopPolling()
        XCTAssertFalse(bridge.isPolling)
    }

    // MARK: - Settings URL

    func testSettingsURLIsValid() {
        let url = AccessibilityOnboardingBridge.settingsURL
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.scheme, "x-apple.systempreferences")
    }
}
