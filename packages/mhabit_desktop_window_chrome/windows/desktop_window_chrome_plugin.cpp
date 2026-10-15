#include "include/mhabit_desktop_window_chrome/desktop_window_chrome_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>
#include <memory>

#include "desktop_title_bar.g.h"
#include "native_title_bar.h"

namespace mhabit_desktop_window_chrome {
/// Connects Flutter's title-bar requests and system notifications to the HWND.
/// The registrar owns this plugin and must outlive its message handlers.
class DesktopWindowChromePlugin : public flutter::Plugin,
                                 public DesktopTitleBarHostApi {
 public:
  /// Registers Pigeon channels and a non-consuming window-message delegate.
  /// Borrows registrar; the top-level HWND is resolved lazily after attachment.
  explicit DesktopWindowChromePlugin(flutter::PluginRegistrarWindows* registrar)
      : registrar_(registrar), title_bar_(nullptr) {
    DesktopTitleBarHostApi::SetUp(registrar_->messenger(), this);
    delegate_id_ = registrar_->RegisterTopLevelWindowProcDelegate(
        [this](HWND, UINT message, WPARAM, LPARAM) -> std::optional<LRESULT> {
          if (message == WM_SETTINGCHANGE || message == WM_THEMECHANGED ||
              message == WM_DWMCOLORIZATIONCOLORCHANGED) {
            title_bar_.Refresh();
          }
          // Never consume non-client, activation, sizing or system messages.
          return std::nullopt;
        });
  }

  /// Removes message handlers before the title-bar adapter restores defaults.
  ~DesktopWindowChromePlugin() override {
    registrar_->UnregisterTopLevelWindowProcDelegate(delegate_id_);
    DesktopTitleBarHostApi::SetUp(registrar_->messenger(), nullptr);
  }

  /// Applies packed ARGB colors to the current top-level HWND.
  /// Returns exact-color success; unsupported attributes and high contrast
  /// produce false rather than a channel error. NativeTitleBar ignores alpha.
  ErrorOr<bool> SetAppearance(int64_t background_argb,
                             int64_t foreground_argb, bool dark) override {
    // Plugins register before Runner attaches the Flutter view to its window.
    // Resolve the top-level HWND at first use, after attachment.
    title_bar_.Attach(GetAncestor(registrar_->GetView()->GetNativeWindow(), GA_ROOT));
    return title_bar_.SetAppearance(background_argb, foreground_argb, dark);
  }

  /// Releases application appearance ownership; repeated calls are safe.
  /// Unsupported reset attributes are ignored and no channel error is returned.
  std::optional<FlutterError> Reset() override {
    title_bar_.Reset();
    return std::nullopt;
  }

 private:
  flutter::PluginRegistrarWindows* registrar_;
  NativeTitleBar title_bar_;
  int delegate_id_;
};
}

void DesktopWindowChromePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auto* windows = flutter::PluginRegistrarManager::GetInstance()
      ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar);
  windows->AddPlugin(std::make_unique<
      mhabit_desktop_window_chrome::DesktopWindowChromePlugin>(windows));
}
