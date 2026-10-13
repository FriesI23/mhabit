import Cocoa
import FlutterMacOS

/// Bridges geometry, outer-frame constraints and synchronous decoration changes
/// around standard macOS fullscreen. Package APIs own decoration and placement.
final class DesktopWindowChrome: DesktopChromeHostApi {
  // MARK: - Dependencies and state

  private weak var window: NSWindow?
  private weak var view: NSView?
  private let messenger: FlutterBinaryMessenger
  private let flutter: DesktopChromeFlutterApi
  private let buttonPosition: CGPoint
  private let applyDecoration: (Bool) -> Void
  private let applyButtonOffsets: ([CGPoint]?) -> Void
  private(set) var fusionEnabled = false
  private var fused = false
  private var enteringFullScreen = false
  private var exitingFullScreen = false
  private var disposed = false
  private var refreshPending = false
  private var tokens: [NSObjectProtocol] = []
  private var lastGeometry: ChromeGeometry?

  // MARK: - Lifecycle

  init(
    window: NSWindow, controller: FlutterViewController, buttonPosition: CGPoint,
    applyDecoration: @escaping (Bool) -> Void,
    applyButtonOffsets: @escaping ([CGPoint]?) -> Void
  ) {
    self.window = window
    view = controller.view
    messenger = controller.engine.binaryMessenger
    flutter = DesktopChromeFlutterApi(binaryMessenger: messenger)
    self.buttonPosition = buttonPosition
    self.applyDecoration = applyDecoration
    self.applyButtonOffsets = applyButtonOffsets
    DesktopChromeHostApiSetup.setUp(binaryMessenger: messenger, api: self)
    controller.view.postsFrameChangedNotifications = true
    controller.view.postsBoundsChangedNotifications = true
    for name in [NSWindow.didResizeNotification, NSWindow.didEndLiveResizeNotification,
                 NSWindow.didChangeScreenNotification, NSWindow.didChangeBackingPropertiesNotification,
                 NSWindow.didUpdateNotification] {
      observe(name, object: window) { $0.scheduleRefresh() }
    }
    for name in [NSView.frameDidChangeNotification, NSView.boundsDidChangeNotification] {
      observe(name, object: controller.view) { $0.scheduleRefresh() }
    }
    observe(NSWindow.willEnterFullScreenNotification, object: window) { owner in
      owner.enteringFullScreen = true
      // Temporarily restore system decoration without disabling windowed fusion.
      try? owner.applyConfiguration(fused: false)
      owner.flutter.willEnterFullScreen { _ in }
      owner.scheduleRefresh()
    }
    observe(NSWindow.didEnterFullScreenNotification, object: window) { owner in
      owner.enteringFullScreen = false
      owner.scheduleRefresh()
    }
    observe(NSWindow.willExitFullScreenNotification, object: window) { owner in
      owner.exitingFullScreen = true
      // Prepare the returning window before its exit animation, including the
      // toolbar and button constraints rather than transparency alone.
      try? owner.applyConfiguration(fused: owner.fusionEnabled)
    }
    observe(NSWindow.didExitFullScreenNotification, object: window) { owner in
      // Finish toolbar/button setup natively before the asynchronous Dart event.
      try? owner.restoreWindowedDecoration()
      owner.exitingFullScreen = false
      owner.scheduleRefresh()
      // AppKit restores the pre-fullscreen toolbar visibility after delivering
      // didExit. Finish on the next main-loop turn so the native button parent
      // regains its ordinary height and receives pointer input.
      DispatchQueue.main.async { [weak owner] in
        guard let owner, owner.fusionEnabled, !owner.enteringFullScreen,
              let window = owner.window, !window.styleMask.contains(.fullScreen),
              window.toolbar?.isVisible == false else { return }
        try? owner.restoreWindowedDecoration()
      }
    }
  }

  deinit { stopObserving() }

  func dispose() throws {
    guard !disposed else { return }
    try configure(fused: false)
    disposed = true
    stopObserving()
    DesktopChromeHostApiSetup.setUp(binaryMessenger: messenger, api: nil)
  }

  // MARK: - Window decoration

  func configure(fused requested: Bool) throws {
    guard !disposed else { return }
    fusionEnabled = requested
    try applyConfiguration(fused: requested)
  }

  /// AppKit may rebuild the titlebar while restoring the ordinary style mask.
  /// Reapply package constraints even when the requested decoration is unchanged.
  private func restoreWindowedDecoration() throws {
    guard !disposed, fusionEnabled else { return }
    fused = false
    try applyConfiguration(fused: true)
  }

  private func applyConfiguration(fused requested: Bool) throws {
    guard !disposed, let window else { return }
    let desired = requested && !enteringFullScreen
      && (exitingFullScreen || !window.styleMask.contains(.fullScreen))
    guard desired != fused else { return }
    // Set first so a partially applied configuration can still be restored.
    fused = desired
    let frame = window.frame
    let minimum = window.minSize
    defer {
      window.contentView?.superview?.layoutSubtreeIfNeeded()
      window.minSize = minimum
      let actual = window.minSize
      if actual != minimum {
        window.minSize = NSSize(width: minimum.width - (actual.width - minimum.width),
                               height: minimum.height - (actual.height - minimum.height))
      }
      if !enteringFullScreen, !exitingFullScreen,
         !window.styleMask.contains(.fullScreen), window.frame != frame {
        window.setFrame(frame, display: false)
      }
      window.layoutIfNeeded()
      scheduleRefresh()
    }
    if !desired { applyButtonOffsets(nil) }
    applyDecoration(desired)
    if desired {
      window.contentView?.superview?.layoutSubtreeIfNeeded()
      applyButtonOffsets(try buttonOffsets(in: window))
    }
  }

  // MARK: - Native button placement

  /// Package offsets use the button parent's left/top anchors, not window or
  /// Flutter coordinates. Preserve system sizes and relative horizontal spacing.
  private func buttonOffsets(in window: NSWindow) throws -> [CGPoint] {
    let buttons = window.chromeButtons
    guard buttons.count == 3 else {
      throw PigeonError(code: "window-buttons", message: "Native buttons unavailable", details: nil)
    }
    let rectangles = buttons.map { $0.convert($0.bounds, to: nil) }
    let leading = rectangles.map(\.minX).min()!
    return try zip(buttons, rectangles).map { button, rectangle in
      guard let parent = button.superview else {
        throw PigeonError(code: "window-buttons", message: "Button parent unavailable", details: nil)
      }
      let target = parent.convert(CGRect(
        x: buttonPosition.x + rectangle.minX - leading,
        y: window.frame.height - buttonPosition.y - rectangle.height / 2,
        width: rectangle.width, height: rectangle.height), from: nil)
      return CGPoint(x: target.minX - parent.bounds.minX,
                     y: parent.isFlipped ? target.minY - parent.bounds.minY : parent.bounds.maxY - target.maxY)
    }
  }

  // MARK: - Geometry snapshots

  func geometry() throws -> ChromeGeometry {
    guard let window, let view else {
      return ChromeGeometry(ready: false, valid: false, fullScreen: false,
                            width: 0, height: 0, buttons: [])
    }
    let fullScreen = enteringFullScreen || exitingFullScreen || window.styleMask.contains(.fullScreen)
    let ready = view.window === window && !view.bounds.isEmpty
    let buttons = fullScreen ? [] : window.chromeButtons.filter { !$0.isHidden }.map {
      DesktopChromeCoordinates.toFlutter(view.convert($0.bounds, from: $0), in: view)
    }
    return ChromeGeometry(
      ready: ready, valid: ready && (fullScreen || buttons.count == 3), fullScreen: fullScreen,
      width: Double(view.bounds.width), height: Double(view.bounds.height),
      buttons: buttons)
  }

  // MARK: - Observation and geometry notifications

  private func observe(_ name: Notification.Name, object: AnyObject,
                       action: @escaping (DesktopWindowChrome) -> Void) {
    tokens.append(NotificationCenter.default.addObserver(forName: name, object: object, queue: .main) {
      [weak self] _ in
      guard let self, !self.disposed else { return }
      action(self)
    })
  }

  private func stopObserving() {
    tokens.forEach { NotificationCenter.default.removeObserver($0) }
    tokens.removeAll()
  }

  private func scheduleRefresh() {
    guard !disposed, !refreshPending else { return }
    refreshPending = true
    DispatchQueue.main.async { [weak self] in
      guard let self, !self.disposed else { return }
      self.refreshPending = false
      guard let geometry = try? self.geometry(), geometry != self.lastGeometry else { return }
      self.lastGeometry = geometry
      self.flutter.geometryChanged { _ in }
    }
  }
}

// MARK: - Native-to-Flutter coordinates

/// Converts logical points from a native view to Flutter's top-left origin.
/// Flipped and offset view bounds are supported; do not apply backing scale.
enum DesktopChromeCoordinates {
  static func toFlutter(_ rect: CGRect, in view: NSView) -> ChromeRect {
    ChromeRect(x: Double(rect.minX - view.bounds.minX),
               y: Double(view.isFlipped ? rect.minY - view.bounds.minY : view.bounds.maxY - rect.maxY),
               width: Double(rect.width), height: Double(rect.height))
  }
}

// MARK: - Native window buttons

extension NSWindow {
  fileprivate var chromeButtons: [NSButton] {
    [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton]
      .compactMap { standardWindowButton($0) }
  }
}
