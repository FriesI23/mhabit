import Cocoa

/// AppKit owns frame serialization and restoration. This helper restricts
/// autosaving to ordinary frames without replacing NSWindow's delegate.
public final class WindowPersistence: WindowPersistenceHostApi {
  private weak var window: NSWindow?
  private var name = ""
  private var initialized = false
  private var transitioning = false
  private var observers: [NSObjectProtocol] = []

  init(window: NSWindow) { self.window = window }

  func initialize(name: String, minimumWidth: Double, minimumHeight: Double) throws -> Bool {
    guard let window, !initialized else { return false }
    initialized = true
    // Reattachment may resume tracking, but never reload a visible window.
    let shouldRestore = !window.isVisible
    self.name = "mhabit.\(name).ordinary.v1"
    // The existing chrome owner sets minSize before installing its toolbar.
    // Reassigning it after fusion changes AppKit's content minimum and can add
    // the toolbar height again on subsequent decoration changes.
    if shouldRestore { window.setFrameAutosaveName(self.name) }
    let screen =
      NSScreen.screens.max {
        intersectionArea($0.visibleFrame, window.frame)
          < intersectionArea($1.visibleFrame, window.frame)
      } ?? NSScreen.main
    if shouldRestore, let screen {
      let work = screen.visibleFrame
      var frame = window.frame
      frame.size.width = min(work.width, max(minimumWidth, frame.width))
      frame.size.height = min(work.height, max(minimumHeight, frame.height))
      frame.origin.x = min(max(frame.minX, work.minX), work.maxX - frame.width)
      frame.origin.y = min(max(frame.minY, work.minY), work.maxY - frame.height)
      window.setFrame(frame, display: false)
    }
    observe(NSWindow.willEnterFullScreenNotification) { $0.suspend() }
    observe(NSWindow.willExitFullScreenNotification) { $0.transitioning = true }
    observe(NSWindow.didExitFullScreenNotification) { owner in
      DispatchQueue.main.async { [weak owner] in
        owner?.transitioning = false
        try? owner?.flush()
      }
    }
    for notification in [NSWindow.didMoveNotification, NSWindow.didResizeNotification] {
      observe(notification) { owner in
        // AppKit already autosaves ordinary frames. Only resume when a manual
        // resize returns a zoomed window to ordinary mode. Wait until AppKit
        // finishes updating isZoomed and the titlebar layout.
        guard owner.window?.frameAutosaveName.isEmpty == true else { return }
        DispatchQueue.main.async { [weak owner] in try? owner?.flush() }
      }
    }
    observe(NSWindow.willCloseNotification) { try? $0.flush() }
    if !shouldRestore { try flush() }
    return shouldRestore
  }

  private func intersectionArea(_ a: CGRect, _ b: CGRect) -> CGFloat {
    let rect = a.intersection(b)
    return rect.isNull ? 0 : rect.width * rect.height
  }

  private func observe(_ name: NSNotification.Name, action: @escaping (WindowPersistence) -> Void) {
    observers.append(
      NotificationCenter.default.addObserver(forName: name, object: window, queue: .main) {
        [weak self] _ in
        if let self { action(self) }
      })
  }

  /// Runner calls this immediately before AppKit's zoom action changes frame.
  public func suspend() {
    try? flush()
    transitioning = true
    window?.setFrameAutosaveName("")
  }

  public func didZoom() {
    transitioning = false
    try? flush()
  }

  func restore(placement: [Double]) throws {}
  func capture() throws -> [Double]? { nil }

  func flush() throws {
    guard !name.isEmpty, !transitioning, let window, !window.isMiniaturized,
      !window.isZoomed, !window.styleMask.contains(.fullScreen)
    else { return }
    // Save before enabling autosave: assigning the name reloads the frame.
    window.saveFrame(usingName: name)
    if window.frameAutosaveName != name { window.setFrameAutosaveName(name) }
  }

  func dispose() throws {
    try flush()
    for observer in observers { NotificationCenter.default.removeObserver(observer) }
    observers.removeAll()
    window?.setFrameAutosaveName("")
    initialized = false
    name = ""
  }

  deinit {
    for observer in observers { NotificationCenter.default.removeObserver(observer) }
  }
}
