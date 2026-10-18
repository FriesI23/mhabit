import Cocoa
import FlutterMacOS
import macos_window_utils
import XCTest
@testable import mhabit
@testable import mhabit_desktop_window_chrome

private final class FlippedChromeView: NSView {
  override var isFlipped: Bool { true }
}

@MainActor
final class RunnerTests: XCTestCase {
  override func setUpWithError() throws {
    XCTAssertTrue(Thread.isMainThread, "AppKit window checks must run on the main thread")
    let window = try XCTUnwrap(NSApp.windows.compactMap { $0 as? MainFlutterWindow }.first)
    let deadline = Date(timeIntervalSinceNow: 15)
    while !window.isVisible && Date() < deadline {
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
    }
    XCTAssertTrue(window.isVisible, "Dart bootstrap must show the initialized window")
  }

  func testProductMinimumAndOuterFrameSurviveDecorationChanges() throws {
    let window = try XCTUnwrap(NSApp.windows.compactMap { $0 as? MainFlutterWindow }.first)
    let chrome = try XCTUnwrap(window.chrome?.chrome)
    XCTAssertEqual(window.minSize, NSSize(width: 350, height: 520))
    try chrome.configure(fused: false)
    defer {
      try? chrome.configure(fused: false)
      window.minSize = NSSize(width: 350, height: 520)
      try? chrome.configure(fused: true)
    }
    for minimum in [NSSize(width: 350, height: 520), NSSize(width: 410, height: 620)] {
      window.minSize = minimum
      let frame = window.frame
      for fused in [true, false] {
        try chrome.configure(fused: fused)
        XCTAssertEqual(window.frame, frame)
        XCTAssertEqual(window.minSize, minimum)
      }
    }
  }

  func testCoordinateOriginAndFlip() {
    for view in [NSView(frame: CGRect(x: 0, y: 0, width: 350, height: 520)),
                 FlippedChromeView(frame: CGRect(x: 0, y: 0, width: 350, height: 520))] {
      view.bounds = CGRect(x: 10, y: 20, width: 350, height: 520)
      let native = CGRect(x: 17, y: view.isFlipped ? 29 : 517, width: 14, height: 14)
      XCTAssertEqual(DesktopChromeCoordinates.toFlutter(native, in: view),
                     ChromeRect(x: 7, y: 9, width: 14, height: 14))
    }
  }

  private func assertButtonHitTesting(in window: NSWindow,
                                    file: StaticString = #filePath, line: UInt = #line) {
    guard let root = window.contentView?.superview else {
      return XCTFail("Window frame view unavailable", file: file, line: line)
    }
    for buttonType in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
      guard let button = window.standardWindowButton(buttonType) else {
        XCTFail("Native button unavailable", file: file, line: line)
        continue
      }
      let point = button.convert(NSPoint(x: button.bounds.midX, y: button.bounds.midY),
                                 to: root.superview)
      let hit = root.hitTest(point)
      XCTAssertTrue(hit === button || hit?.isDescendant(of: button) == true,
                    "Native button must receive physical pointer input; hit=\(String(describing: hit))",
                    file: file, line: line)
    }
  }

  func testRestoresToolbarHiddenAfterExitNotificationAndButtonHitTesting() async throws {
    let window = try XCTUnwrap(NSApp.windows.compactMap { $0 as? MainFlutterWindow }.first)
    let chrome = try XCTUnwrap(window.chrome?.chrome)
    defer { try? chrome.configure(fused: true) }
    try chrome.configure(fused: true)
    NotificationCenter.default.post(name: NSWindow.didExitFullScreenNotification, object: window)
    // AppKit restores the pre-fullscreen visibility after delivering didExit.
    try XCTUnwrap(window.toolbar).isVisible = false
    let frame = window.frame
    let minimum = window.minSize
    let restored = expectation(description: "Queued windowed decoration restoration")
    DispatchQueue.main.async { restored.fulfill() }
    await fulfillment(of: [restored], timeout: 1)
    XCTAssertEqual(window.toolbar?.isVisible, true)
    XCTAssertEqual(window.frame, frame)
    XCTAssertEqual(window.minSize, minimum)
    assertButtonHitTesting(in: window)

    // A queued recovery must not override an explicit fallback request.
    NotificationCenter.default.post(name: NSWindow.didExitFullScreenNotification, object: window)
    try XCTUnwrap(window.toolbar).isVisible = false
    try chrome.configure(fused: false)
    let fallback = expectation(description: "Queued recovery respects explicit fallback")
    DispatchQueue.main.async { fallback.fulfill() }
    await fulfillment(of: [fallback], timeout: 1)
    XCTAssertNil(window.toolbar)
  }

  func testReinstallsWindowedDecorationWithoutReenablingFallback() throws {
    let window = try XCTUnwrap(NSApp.windows.compactMap { $0 as? MainFlutterWindow }.first)
    let chrome = try XCTUnwrap(window.chrome?.chrome)
    defer { try? chrome.configure(fused: true) }
    try chrome.configure(fused: true)
    // AppKit can replace windowed decoration even though the owner is fused.
    MainFlutterWindowManipulator.removeToolbar()
    MainFlutterWindowManipulator.showTitle()
    MainFlutterWindowManipulator.makeTitlebarOpaque()
    MainFlutterWindowManipulator.disableFullSizeContentView()
    let frame = window.frame
    let minimum = window.minSize
    NotificationCenter.default.post(name: NSWindow.didExitFullScreenNotification, object: window)
    XCTAssertEqual(window.frame, frame)
    XCTAssertEqual(window.minSize, minimum)
    XCTAssertNotNil(window.toolbar)
    XCTAssertEqual(window.titleVisibility, .hidden)
    XCTAssertTrue(window.titlebarAppearsTransparent)
    XCTAssertTrue(window.styleMask.contains(.fullSizeContentView))
    for type in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
      let button = try XCTUnwrap(window.standardWindowButton(type))
      let rect = button.convert(button.bounds, to: nil)
      XCTAssertEqual(window.frame.height - rect.midY, 32, accuracy: 0.001)
    }
    assertButtonHitTesting(in: window)
    try chrome.configure(fused: false)
    NotificationCenter.default.post(name: NSWindow.didExitFullScreenNotification, object: window)
    XCTAssertNil(window.toolbar)
    XCTAssertFalse(window.titlebarAppearsTransparent)
    XCTAssertFalse(window.styleMask.contains(.fullSizeContentView))
  }

  func testPackageButtonsSurviveResizeAndAppearanceAndRestoreStandardDecoration() throws {
    let window = try XCTUnwrap(NSApp.windows.compactMap { $0 as? MainFlutterWindow }.first)
    let chrome = try XCTUnwrap(window.chrome?.chrome)
    let controller = try XCTUnwrap(window.contentViewController as? MacOSWindowUtilsViewController)
    let oldFrame = window.frame
    let oldAppearance = window.appearance
    defer {
      window.appearance = oldAppearance
      window.setFrame(oldFrame, display: false)
      try? chrome.configure(fused: true)
    }
    try chrome.configure(fused: true)
    let toolbar = try XCTUnwrap(window.toolbar)
    for size in [NSSize(width: 350, height: 520), NSSize(width: 800, height: 600)] {
      window.setFrame(NSRect(origin: window.frame.origin, size: size), display: false)
      for name in [NSAppearance.Name.aqua, .darkAqua] {
        window.appearance = NSAppearance(named: name)
        window.contentView?.superview?.layoutSubtreeIfNeeded()
        let snapshot = try chrome.geometry()
        XCTAssertTrue(snapshot.valid)
        XCTAssertEqual(snapshot.width, controller.flutterViewController.view.bounds.width)
        XCTAssertEqual(snapshot.height, controller.flutterViewController.view.bounds.height)
        let buttons = [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton]
          .compactMap { window.standardWindowButton($0) }
        XCTAssertEqual(buttons.count, 3)
        XCTAssertEqual(buttons.first!.convert(buttons.first!.bounds, to: nil).minX, 20, accuracy: 0.001)
        for button in buttons {
          let rect = button.convert(button.bounds, to: nil)
          XCTAssertEqual(window.frame.height - rect.midY, 32, accuracy: 0.001)
        }
        assertButtonHitTesting(in: window)
        try chrome.configure(fused: true)
        XCTAssertTrue(window.toolbar === toolbar)
      }
    }
    try chrome.configure(fused: false)
    XCTAssertNil(window.toolbar)
    XCTAssertEqual(window.titleVisibility, .visible)
    XCTAssertFalse(window.titlebarAppearsTransparent)
    XCTAssertFalse(window.styleMask.contains(.fullSizeContentView))
  }
}

// Keep helper-only NSWindows separate from the live Flutter chrome tests.
@MainActor
final class WindowPersistenceTests: XCTestCase {
  func testOrdinaryFrameAutosaveRestoresAndIgnoresTransientFrames() throws {
    let name = "persistence-test-\(UUID().uuidString)"
    let autosave = "mhabit.\(name).ordinary.v1"
    defer { NSWindow.removeFrame(usingName: autosave) }
    let first = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 800, height: 600),
                         styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    first.isReleasedWhenClosed = false
    defer { first.close() }
    let owner = WindowPersistence(window: first)
    XCTAssertTrue(try owner.initialize(name: name, minimumWidth: 350, minimumHeight: 520))
    first.setFrame(NSRect(x: 120, y: 120, width: 750, height: 580), display: false)
    try owner.flush()
    let ordinary = first.frame
    XCTAssertFalse(try owner.initialize(name: name, minimumWidth: 350, minimumHeight: 520))
    try owner.dispose()

    let second = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 530),
                          styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    second.isReleasedWhenClosed = false
    defer { second.close() }
    let restored = WindowPersistence(window: second)
    XCTAssertTrue(try restored.initialize(name: name, minimumWidth: 350, minimumHeight: 520))
    XCTAssertEqual(second.frame, ordinary)
    XCTAssertFalse(second.isVisible)
    // Simulate a fullscreen/zoom transition: transient geometry must not save.
    restored.suspend()
    second.setFrame(NSRect(x: 0, y: 0, width: 1100, height: 900), display: false)
    try restored.flush()
    let third = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 530),
                         styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    third.isReleasedWhenClosed = false
    defer { third.close() }
    let verification = WindowPersistence(window: third)
    XCTAssertTrue(try verification.initialize(name: name, minimumWidth: 350, minimumHeight: 520))
    XCTAssertEqual(third.frame, ordinary)
    try verification.dispose()
    try restored.dispose()
  }

}
