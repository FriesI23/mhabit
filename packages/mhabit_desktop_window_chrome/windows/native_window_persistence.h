#ifndef MHABIT_WINDOWS_NATIVE_WINDOW_PERSISTENCE_H_
#define MHABIT_WINDOWS_NATIVE_WINDOW_PERSISTENCE_H_

#include <windows.h>

#include <optional>

namespace mhabit_desktop_window_chrome {

struct WindowsWindowState {
  double left;
  double top;
  double width;
  double height;
  double dpi;
  double monitor_left;
  double monitor_top;
  double work_width;
  double work_height;
};

// Placement's workspace coordinates and DPI never leave this adapter as
// Flutter screen coordinates. No HWND ownership or message consumption.
class NativeWindowPersistence {
 public:
  bool Initialize(HWND window, double minimum_width, double minimum_height);
  bool Restore(const WindowsWindowState& state);
  std::optional<WindowsWindowState> Capture() const;
  void OnMessage(UINT message);

 private:
  HWND window_ = nullptr;
  bool initialized_ = false;
  double minimum_width_ = 350;
  double minimum_height_ = 520;
  std::optional<WindowsWindowState> ordinary_;
};

}  // namespace mhabit_desktop_window_chrome
#endif
