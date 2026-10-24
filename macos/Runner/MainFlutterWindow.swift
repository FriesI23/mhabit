import Cocoa
import FlutterMacOS
import macos_window_utils
import mhabit_desktop_window_chrome
import window_manager

class MainFlutterWindow: NSWindow {
  private(set) var chrome: DesktopWindowChromePlugin?

  override func zoom(_ sender: Any?) {
    chrome?.persistence?.suspend()
    super.zoom(sender)
    chrome?.persistence?.didZoom()
  }

  override var styleMask: NSWindow.StyleMask {
    get { super.styleMask }
    set {
      var returningStyle = newValue
      let restoringFusion =
        super.styleMask.contains(.fullScreen) && !newValue.contains(.fullScreen)
        && chrome?.fusionEnabled == true
      if restoringFusion {
        // AppKit restores the windowed mask during its animation. Prepare the
        // appearance here so that restoration cannot introduce an opaque bar.
        MainFlutterWindowManipulator.hideTitle()
        MainFlutterWindowManipulator.makeTitlebarTransparent()
        // The package's enable method calls this setter; merge the flag instead.
        returningStyle.insert(.fullSizeContentView)
      }
      super.styleMask = returningStyle
    }
  }

  override func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    hiddenWindowAtLaunch()
  }

  override func awakeFromNib() {
    let controller = MacOSWindowUtilsViewController()
    let windowFrame = frame
    contentViewController = controller
    setFrame(windowFrame, display: false)
    MainFlutterWindowManipulator.start(mainFlutterWindow: self)
    let flutter = controller.flutterViewController
    RegisterGeneratedPlugins(registry: flutter)
    titlebarSeparatorStyle = .none
    chrome =
      flutter.valuePublished(byPlugin: "DesktopWindowChromePlugin") as? DesktopWindowChromePlugin
    chrome?
      .attach(
        window: self,
        controller: flutter,
        buttonPosition: CGPoint(x: 20, y: 32),
        applyDecoration: { [weak self] fused in
          if fused {
            MainFlutterWindowManipulator.hideTitle()
            MainFlutterWindowManipulator.makeTitlebarTransparent()
            MainFlutterWindowManipulator.enableFullSizeContentView()
            MainFlutterWindowManipulator.addToolbar(
              toolbarName: "DefaultToolbar",
              toolbarArguments: [:],
            )
            MainFlutterWindowManipulator.setToolbarStyle(toolbarStyle: .unified)
            self?.toolbar?.isVisible = true
          } else {
            MainFlutterWindowManipulator.removeToolbar()
            MainFlutterWindowManipulator.showTitle()
            MainFlutterWindowManipulator.makeTitlebarOpaque()
            MainFlutterWindowManipulator.disableFullSizeContentView()
            MainFlutterWindowManipulator.setToolbarStyle(toolbarStyle: .automatic)
          }
        },
        applyButtonOffsets: { offsets in
          for (index, button) in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton]
            .enumerated()
          {
            MainFlutterWindowManipulator.overrideStandardWindowButtonPosition(
              buttonType: button,
              offset: offsets?[index],
            )
          }
        },
      )
    // Dart supplies the minimum size and fusion before displaying the first frame.
    super.awakeFromNib()
  }
}
