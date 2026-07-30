import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Register native collation host API (Parse 3: macOS).
    CollationHostApiSetup.setUp(
      binaryMessenger: flutterViewController.engine.binaryMessenger,
      api: CollationPlugin())

    super.awakeFromNib()
  }
}
