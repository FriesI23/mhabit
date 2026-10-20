#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "desktop_title_bar.g.h"
#include "include/mhabit_desktop_window_chrome/desktop_window_chrome_plugin_c_api.h"
#include "native_title_bar.h"
#include "native_window_persistence.h"
#include "window_persistence.g.h"

namespace mhabit_desktop_window_chrome {
/// Connects Flutter's title-bar requests and system notifications to the HWND.
/// The registrar owns this plugin and must outlive its message handlers.
class DesktopWindowChromePlugin
    : public flutter::Plugin,
      public DesktopTitleBarHostApi,
      public mhabit_window_persistence::WindowPersistenceHostApi,
      public mhabit_window_persistence::WindowsWindowPersistenceHostApi {
 public:
  /// Registers Pigeon channels and a non-consuming window-message delegate.
  /// Borrows registrar; the top-level HWND is resolved lazily after attachment.
  explicit DesktopWindowChromePlugin(flutter::PluginRegistrarWindows* registrar)
      : registrar_(registrar), title_bar_(nullptr) {
    DesktopTitleBarHostApi::SetUp(registrar_->messenger(), this);
    mhabit_window_persistence::WindowPersistenceHostApi::SetUp(
        registrar_->messenger(), this);
    mhabit_window_persistence::WindowsWindowPersistenceHostApi::SetUp(
        registrar_->messenger(), this);
    delegate_id_ = registrar_->RegisterTopLevelWindowProcDelegate(
        [this](HWND, UINT message, WPARAM, LPARAM) -> std::optional<LRESULT> {
          persistence_.OnMessage(message);
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
    mhabit_window_persistence::WindowPersistenceHostApi::SetUp(
        registrar_->messenger(), nullptr);
    mhabit_window_persistence::WindowsWindowPersistenceHostApi::SetUp(
        registrar_->messenger(), nullptr);
  }

  /// Applies packed ARGB colors to the current top-level HWND.
  /// Returns exact-color success; unsupported attributes and high contrast
  /// produce false rather than a channel error. NativeTitleBar ignores alpha.
  ErrorOr<bool> SetAppearance(int64_t background_argb, int64_t foreground_argb,
                              bool dark) override {
    // Plugins register before Runner attaches the Flutter view to its window.
    // Resolve the top-level HWND at first use, after attachment.
    title_bar_.Attach(
        GetAncestor(registrar_->GetView()->GetNativeWindow(), GA_ROOT));
    return title_bar_.SetAppearance(background_argb, foreground_argb, dark);
  }

  /// Releases application appearance ownership; repeated calls are safe.
  /// Unsupported reset attributes are ignored and no channel error is returned.
  std::optional<FlutterError> Reset() override {
    title_bar_.Reset();
    return std::nullopt;
  }

  mhabit_window_persistence::ErrorOr<bool> Initialize(
      const std::string&, double minimum_width,
      double minimum_height) override {
    return persistence_.Initialize(
        GetAncestor(registrar_->GetView()->GetNativeWindow(), GA_ROOT),
        minimum_width, minimum_height);
  }

  std::optional<mhabit_window_persistence::FlutterError> Restore(
      const mhabit_window_persistence::WindowsWindowState& state) override {
    persistence_.Restore({state.left(), state.top(), state.width(),
                          state.height(), state.dpi(), state.monitor_left(),
                          state.monitor_top(), state.work_width(),
                          state.work_height()});
    return std::nullopt;
  }

  mhabit_window_persistence::ErrorOr<
      std::optional<mhabit_window_persistence::WindowsWindowState>>
  Capture() override {
    const auto state = persistence_.Capture();
    if (!state)
      return std::optional<mhabit_window_persistence::WindowsWindowState>{};
    return std::optional<mhabit_window_persistence::WindowsWindowState>{
        std::in_place,       state->left,        state->top,
        state->width,        state->height,      state->dpi,
        state->monitor_left, state->monitor_top, state->work_width,
        state->work_height};
  }

  std::optional<mhabit_window_persistence::FlutterError> Flush() override {
    return std::nullopt;
  }
  std::optional<mhabit_window_persistence::FlutterError> Dispose() override {
    return std::nullopt;
  }

 private:
  flutter::PluginRegistrarWindows* registrar_;
  NativeTitleBar title_bar_;
  NativeWindowPersistence persistence_;
  int delegate_id_;
};
}  // namespace mhabit_desktop_window_chrome

void DesktopWindowChromePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auto* windows =
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar);
  windows->AddPlugin(
      std::make_unique<mhabit_desktop_window_chrome::DesktopWindowChromePlugin>(
          windows));
}
