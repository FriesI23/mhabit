#ifndef MHABIT_WINDOWS_NATIVE_WINDOW_PERSISTENCE_H_
#define MHABIT_WINDOWS_NATIVE_WINDOW_PERSISTENCE_H_

#include <windows.h>
#include <optional>
#include <vector>

namespace mhabit_desktop_window_chrome {

// Placement's workspace coordinates and DPI never leave this adapter as
// Flutter screen coordinates. No HWND ownership or message consumption.
class NativeWindowPersistence {
 public:
  bool Initialize(HWND window, double minimum_width, double minimum_height);
  bool Restore(const std::vector<double>& values);
  std::optional<std::vector<double>> Capture() const;
  void OnMessage(UINT message);

 private:
  HWND window_ = nullptr;
  bool initialized_ = false;
  double minimum_width_ = 350;
  double minimum_height_ = 520;
  std::optional<std::vector<double>> ordinary_;
};

}  // namespace mhabit_desktop_window_chrome
#endif
