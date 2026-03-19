import XCTest
import SwiftUI
@testable import Zooom3

@available(macOS 13.0, *)
final class SettingsViewTests: XCTestCase {

    private var defaults: UserDefaults!
    private var suiteName: String!
    private var preferences: Preferences!

    override func setUp() {
        super.setUp()
        suiteName = "com.supagroova.zooom3.test.settings.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        preferences = Preferences(userDefaults: defaults)
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    // MARK: - SettingsView can be instantiated

    func testSettingsViewCreation() {
        let view = SettingsView(preferences: preferences)
        XCTAssertNotNil(view)
    }

    func testSettingsViewWithCallbacks() {
        let cbs = SettingsCallbacks(
            onModifierChanged: {},
            onMouseButtonChanged: {},
            onHoverModeToggled: {},
            onReset: {},
            onQuit: {}
        )
        let view = SettingsView(preferences: preferences, callbacks: cbs)
        XCTAssertNotNil(view)
    }

    // MARK: - SettingsView hosts in NSHostingView

    func testHostingViewCreation() {
        let view = SettingsView(preferences: preferences)
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: 320, height: 500)
        hosting.layout()
        XCTAssertNotNil(hosting)
        XCTAssertGreaterThan(hosting.subviews.count, 0)
    }

    // MARK: - Callbacks fire correctly

    func testResetCallback() {
        var called = false
        let cbs = SettingsCallbacks(onReset: { called = true })
        cbs.onReset()
        XCTAssertTrue(called)
    }

    func testQuitCallback() {
        var called = false
        let cbs = SettingsCallbacks(onQuit: { called = true })
        cbs.onQuit()
        XCTAssertTrue(called)
    }

    func testHoverModeCallback() {
        var called = false
        let cbs = SettingsCallbacks(onHoverModeToggled: { called = true })
        cbs.onHoverModeToggled()
        XCTAssertTrue(called)
    }

    func testModifierChangedCallback() {
        var called = false
        let cbs = SettingsCallbacks(onModifierChanged: { called = true })
        cbs.onModifierChanged()
        XCTAssertTrue(called)
    }

    func testMouseButtonChangedCallback() {
        var called = false
        let cbs = SettingsCallbacks(onMouseButtonChanged: { called = true })
        cbs.onMouseButtonChanged()
        XCTAssertTrue(called)
    }

    // MARK: - Default callbacks are no-ops

    func testDefaultCallbacksDoNotCrash() {
        let cbs = SettingsCallbacks()
        cbs.onModifierChanged()
        cbs.onMouseButtonChanged()
        cbs.onHoverModeToggled()
        cbs.onReset()
        cbs.onQuit()
    }

    // MARK: - Preferences sync (default values)

    func testDefaultPreferencesState() {
        preferences.resetToDefaults()
        XCTAssertTrue(preferences.moveFlagStringSet.contains("CMD"))
        XCTAssertTrue(preferences.moveFlagStringSet.contains("CTRL"))
        XCTAssertFalse(preferences.moveFlagStringSet.contains("ALT"))
        XCTAssertEqual(preferences.moveMouseButton, .left)
        XCTAssertEqual(preferences.resizeMouseButton, .right)
        XCTAssertFalse(preferences.hoverModeEnabled)
        XCTAssertFalse(preferences.shouldBringWindowToFront)
        XCTAssertFalse(preferences.resizeOnly)
        XCTAssertFalse(preferences.hasConflictingConfig)
    }

    // MARK: - Preferences sync (custom values)

    func testCustomPreferencesState() {
        preferences.resetToDefaults()
        preferences.setMoveModifier("CMD", enabled: false)
        preferences.setMoveModifier("ALT", enabled: true)
        preferences.setMoveModifier("SHIFT", enabled: true)
        preferences.hoverModeEnabled = true
        preferences.shouldBringWindowToFront = true
        preferences.resizeOnly = true
        preferences.setMoveMouseButton(MouseButton.middle.rawValue)

        XCTAssertFalse(preferences.moveFlagStringSet.contains("CMD"))
        XCTAssertTrue(preferences.moveFlagStringSet.contains("ALT"))
        XCTAssertTrue(preferences.moveFlagStringSet.contains("SHIFT"))
        XCTAssertTrue(preferences.moveFlagStringSet.contains("CTRL"))
        XCTAssertEqual(preferences.moveMouseButton, .middle)
        XCTAssertTrue(preferences.hoverModeEnabled)
        XCTAssertTrue(preferences.shouldBringWindowToFront)
        XCTAssertTrue(preferences.resizeOnly)
    }

    // MARK: - Conflict detection for SettingsView

    func testNoConflictWithDefaults() {
        preferences.resetToDefaults()
        // Same modifiers but different mouse buttons → no conflict
        XCTAssertFalse(preferences.hasConflictingConfig)
    }

    func testConflictWhenSameButtonAndModifiers() {
        preferences.resetToDefaults()
        preferences.setMoveMouseButton(0)
        preferences.setResizeMouseButton(0)
        XCTAssertTrue(preferences.hasConflictingConfig)
    }

    func testConflictInHoverModeWithSameModifiers() {
        preferences.resetToDefaults()
        preferences.hoverModeEnabled = true
        // Defaults have same modifiers — in hover mode, buttons are irrelevant
        XCTAssertTrue(preferences.hasConflictingConfig)
    }

    func testNoConflictInHoverModeWithDifferentModifiers() {
        preferences.resetToDefaults()
        preferences.hoverModeEnabled = true
        preferences.setResizeModifier("CMD", enabled: false)
        preferences.setResizeModifier("ALT", enabled: true)
        XCTAssertFalse(preferences.hasConflictingConfig)
    }

    // MARK: - Static data

    func testModifierKeysContainsAllExpected() {
        let keys = SettingsView.modifierKeys.map(\.key)
        XCTAssertEqual(keys, ["FN", "CTRL", "ALT", "SHIFT", "CMD"])
    }

    func testMouseButtonsContainsAllExpected() {
        let tags = SettingsView.mouseButtons.map(\.tag)
        XCTAssertEqual(tags, [0, 1, 2])
    }

    func testModifierKeysLabelsAreSymbols() {
        let labels = SettingsView.modifierKeys.map(\.label)
        XCTAssertEqual(labels[0], "fn")
        XCTAssertEqual(labels[1], "\u{2303}") // Control
        XCTAssertEqual(labels[2], "\u{2325}") // Option
        XCTAssertEqual(labels[3], "\u{21E7}") // Shift
        XCTAssertEqual(labels[4], "\u{2318}") // Command
    }
}
