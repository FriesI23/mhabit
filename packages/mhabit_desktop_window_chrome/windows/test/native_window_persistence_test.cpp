#include "../native_window_persistence.h"

#include <cmath>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <tuple>

using mhabit_desktop_window_chrome::NativeWindowPersistence;
void Check(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}

bool SameState(
    const std::optional<mhabit_desktop_window_chrome::WindowsWindowState>& a,
    const std::optional<mhabit_desktop_window_chrome::WindowsWindowState>& b) {
  if (!a || !b) return !a && !b;
  return std::tie(a->left, a->top, a->width, a->height, a->dpi, a->monitor_left,
                  a->monitor_top, a->work_width, a->work_height) ==
         std::tie(b->left, b->top, b->width, b->height, b->dpi, b->monitor_left,
                  b->monitor_top, b->work_width, b->work_height);
}

int main() {
  HWND window = CreateWindowExW(
      0, L"STATIC", L"Placement test", WS_OVERLAPPEDWINDOW, 100, 100, 800, 600,
      nullptr, nullptr, GetModuleHandle(nullptr), nullptr);
  if (!window) return 1;
  try {
    NativeWindowPersistence owner;
    Check(owner.Initialize(window, 350, 520), "hidden window initializes once");
    Check(!owner.Initialize(window, 350, 520), "initialization is idempotent");
    Check(!owner.Capture(), "hidden window never overwrites saved geometry");
    ShowWindow(window, SW_SHOWNORMAL);
    const auto original = owner.Capture();
    Check(original && original->dpi > 0 && original->work_width > 0 &&
              original->work_height > 0,
          "captures native placement and monitor metadata");
    owner.OnMessage(WM_SYSCOMMAND);
    ShowWindow(window, SW_MAXIMIZE);
    Check(SameState(owner.Capture(), original),
          "maximize retains ordinary frame before debounce");
    ShowWindow(window, SW_MINIMIZE);
    Check(SameState(owner.Capture(), original),
          "minimize retains ordinary frame");
    ShowWindow(window, SW_HIDE);
    Check(owner.Restore(*original), "restores native placement");
    Check(!IsWindowVisible(window),
          "restore must not show window before Flutter frame");
    ShowWindow(window, SW_SHOWNORMAL);
    Check(!IsZoomed(window) && !IsIconic(window), "reopens as ordinary window");
    const auto restored = owner.Capture();
    Check(restored && std::abs(restored->width - original->width) <= 2 &&
              std::abs(restored->height - original->height) <= 2,
          "ordinary dimensions round trip");
    Check(!owner.Restore(*original), "visible/hot restart must not reposition");
    ShowWindow(window, SW_HIDE);
    auto empty = *original;
    empty.width = 0;
    Check(!owner.Restore(empty), "reject invalid dimensions");
    auto invalid = *original;
    invalid.left = std::numeric_limits<double>::infinity();
    Check(!owner.Restore(invalid), "reject nonfinite coordinates");
    auto oversized = *original;
    oversized.left = 900000;
    oversized.top = 900000;
    oversized.width = 900000;
    oversized.height = 900000;
    Check(owner.Restore(oversized), "offscreen and oversized record corrected");
    ShowWindow(window, SW_SHOWNORMAL);
    RECT bounds{};
    GetWindowRect(window, &bounds);
    MONITORINFO monitor{};
    monitor.cbSize = sizeof(monitor);
    GetMonitorInfoW(MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST),
                    &monitor);
    Check(bounds.right > monitor.rcWork.left &&
              bounds.left < monitor.rcWork.right &&
              bounds.bottom > monitor.rcWork.top &&
              bounds.top < monitor.rcWork.bottom,
          "restored frame remains visible");
    DestroyWindow(window);
    Check(!owner.Capture(), "destroyed HWND is safe");
    std::cout << "Native placement: hidden restore, normal state, validation "
                 "and visibility passed\n";
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    DestroyWindow(window);
    return 1;
  }
  return 0;
}
