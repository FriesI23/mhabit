#include "native_window_persistence.h"

#include <algorithm>
#include <cmath>

namespace mhabit_desktop_window_chrome {
namespace {
UINT WindowDpi(HWND window) {
  using GetDpi = UINT(WINAPI*)(HWND);
  auto get_dpi = reinterpret_cast<GetDpi>(
      GetProcAddress(GetModuleHandleW(L"user32.dll"), "GetDpiForWindow"));
  return get_dpi ? get_dpi(window) : 96;
}

UINT MonitorDpi(HMONITOR monitor) {
  using GetDpi = HRESULT(WINAPI*)(HMONITOR, int, UINT*, UINT*);
  HMODULE shcore = LoadLibraryW(L"shcore.dll");
  if (!shcore) return 96;
  auto get_dpi = reinterpret_cast<GetDpi>(GetProcAddress(shcore, "GetDpiForMonitor"));
  UINT x = 96, y = 96;
  if (!get_dpi || FAILED(get_dpi(monitor, 0, &x, &y))) x = 96;
  FreeLibrary(shcore);
  return x;
}
}  // namespace

bool NativeWindowPersistence::Initialize(HWND window, double minimum_width,
                                         double minimum_height) {
  window_ = window;
  minimum_width_ = minimum_width;
  minimum_height_ = minimum_height;
  if (initialized_ || !IsWindow(window_)) return false;
  initialized_ = true;
  return !IsWindowVisible(window_);
}

bool NativeWindowPersistence::Restore(const std::vector<double>& v) {
  if (!IsWindow(window_) || IsWindowVisible(window_) || v.size() != 9) return false;
  for (double value : v) {
    if (!std::isfinite(value) || std::abs(value) > 1e7) return false;
  }
  if (v[2] <= 0 || v[3] <= 0 || v[4] < 48 || v[4] > 960 ||
      v[7] <= 0 || v[8] <= 0) return false;

  // Select by the saved monitor origin and available size (screen coordinates), not by
  // rcNormalPosition, whose coordinates are relative to the workspace.
  RECT saved_monitor{static_cast<LONG>(v[5]), static_cast<LONG>(v[6]),
                     static_cast<LONG>(v[5] + v[7]),
                     static_cast<LONG>(v[6] + v[8])};
  HMONITOR monitor = MonitorFromRect(&saved_monitor, MONITOR_DEFAULTTONEAREST);
  MONITORINFO info{};
  info.cbSize = sizeof(info);
  if (!GetMonitorInfoW(monitor, &info)) return false;
  const RECT& work = info.rcWork;
  const double dpi = MonitorDpi(monitor);
  const double ratio = dpi / v[4];
  const LONG width = static_cast<LONG>(std::min<double>(work.right - work.left,
      std::max(v[2] * ratio, minimum_width_ * dpi / 96.0)));
  const LONG height = static_cast<LONG>(std::min<double>(work.bottom - work.top,
      std::max(v[3] * ratio, minimum_height_ * dpi / 96.0)));
  // Workspace origin differs from screen origin when a taskbar is at top/left.
  const LONG left = info.rcMonitor.left;
  const LONG top = info.rcMonitor.top;
  const LONG x = std::clamp(static_cast<LONG>(left + (v[0] - v[5]) * ratio),
      left, left + work.right - work.left - width);
  const LONG y = std::clamp(static_cast<LONG>(top + (v[1] - v[6]) * ratio),
      top, top + work.bottom - work.top - height);
  WINDOWPLACEMENT placement{};
  placement.length = sizeof(placement);
  // SetWindowPlacement must not display the window before Flutter's first frame.
  placement.showCmd = SW_HIDE;
  placement.rcNormalPosition = {x, y, x + width, y + height};
  return SetWindowPlacement(window_, &placement) != FALSE;
}

std::optional<std::vector<double>> NativeWindowPersistence::Capture() const {
  if (!IsWindow(window_) || !IsWindowVisible(window_)) return std::nullopt;
  if (IsIconic(window_) || IsZoomed(window_) ||
      !(GetWindowLongPtrW(window_, GWL_STYLE) & WS_OVERLAPPEDWINDOW)) {
    return ordinary_;
  }
  WINDOWPLACEMENT placement{};
  placement.length = sizeof(placement);
  if (!GetWindowPlacement(window_, &placement)) return std::nullopt;
  MONITORINFO info{};
  info.cbSize = sizeof(info);
  if (!GetMonitorInfoW(MonitorFromWindow(window_, MONITOR_DEFAULTTONEAREST), &info)) {
    return std::nullopt;
  }
  const auto& r = placement.rcNormalPosition;
  if (r.right <= r.left || r.bottom <= r.top) return std::nullopt;
  // Save the workspace origin in the same coordinate system as normal rect.
  return std::vector<double>{static_cast<double>(r.left), static_cast<double>(r.top),
      static_cast<double>(r.right - r.left), static_cast<double>(r.bottom - r.top),
      static_cast<double>(WindowDpi(window_)), static_cast<double>(info.rcMonitor.left),
      static_cast<double>(info.rcMonitor.top),
      static_cast<double>(info.rcWork.right - info.rcWork.left),
      static_cast<double>(info.rcWork.bottom - info.rcWork.top)};
}

void NativeWindowPersistence::OnMessage(UINT message) {
  // Capture before style/fullscreen or system maximize changes, and after an
  // ordinary move/resize. This keeps the final ordinary frame even when the
  // user maximizes before Dart's debounced write has run.
  if (message == WM_SYSCOMMAND || message == WM_STYLECHANGING ||
      message == WM_WINDOWPOSCHANGED || message == WM_EXITSIZEMOVE) {
    if (const auto value = Capture()) ordinary_ = value;
  }
}
}  // namespace mhabit_desktop_window_chrome
