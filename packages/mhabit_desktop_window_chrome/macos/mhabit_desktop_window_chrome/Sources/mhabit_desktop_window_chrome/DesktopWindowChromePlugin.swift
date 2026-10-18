import Cocoa
import FlutterMacOS

/// Runner supplies the package's public Swift operations without coupling this
/// internal geometry plugin's SPM manifest to a pub-cache path.
public final class DesktopWindowChromePlugin: NSObject, FlutterPlugin {
  private(set) var chrome: DesktopWindowChrome?
  public private(set) var persistence: WindowPersistence?

  /// Ordinary-window preference, retained while fullscreen uses system decoration.
  public var fusionEnabled: Bool { chrome?.fusionEnabled ?? false }

  public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.publish(DesktopWindowChromePlugin())
  }

  public func attach(
    window: NSWindow, controller: FlutterViewController, buttonPosition: CGPoint,
    applyDecoration: @escaping (Bool) -> Void,
    applyButtonOffsets: @escaping ([CGPoint]?) -> Void
  ) {
    guard chrome == nil else { return }
    let persistence = WindowPersistence(window: window)
    self.persistence = persistence
    WindowPersistenceHostApiSetup.setUp(binaryMessenger: controller.engine.binaryMessenger, api: persistence)
    chrome = DesktopWindowChrome(
      window: window, controller: controller, buttonPosition: buttonPosition,
      applyDecoration: applyDecoration, applyButtonOffsets: applyButtonOffsets)
  }

  deinit { try? chrome?.dispose() }
}
