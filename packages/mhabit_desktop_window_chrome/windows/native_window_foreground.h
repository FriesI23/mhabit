#ifndef MHABIT_NATIVE_WINDOW_FOREGROUND_H_
#define MHABIT_NATIVE_WINDOW_FOREGROUND_H_

#include <windows.h>

#include <optional>

namespace mhabit_desktop_window_chrome {
/// Observes committed window state without consuming its system messages.
class NativeWindowForeground {
 public:
  explicit NativeWindowForeground(
      bool (*read_foreground)(HWND) = ReadForeground)
      : read_foreground_(read_foreground) {}

  static bool ReadForeground(HWND window) {
    return IsWindowVisible(window) && !IsIconic(window) &&
           GetForegroundWindow() == window;
  }

  /// Returns a value only when a relevant message changes native foreground.
  std::optional<bool> OnMessage(HWND window, UINT message, WPARAM wparam) {
    bool foreground;
    switch (message) {
      case WM_ACTIVATE:
        foreground = LOWORD(wparam) != WA_INACTIVE && read_foreground_(window);
        break;
      case WM_SIZE:
        foreground = wparam != SIZE_MINIMIZED && read_foreground_(window);
        break;
      case WM_WINDOWPOSCHANGED:
        foreground = read_foreground_(window);
        break;
      case WM_SHOWWINDOW:
        // Show is announced before visibility changes. Wait for WINDOWPOSCHANGED.
        if (wparam) return std::nullopt;
        foreground = false;
        break;
      case WM_DESTROY:
        foreground = false;
        break;
      default:
        return std::nullopt;
    }
    if (foreground_ == foreground) return std::nullopt;
    foreground_ = foreground;
    return foreground;
  }

 private:
  bool (*read_foreground_)(HWND);
  std::optional<bool> foreground_;
};
}  // namespace mhabit_desktop_window_chrome
#endif
