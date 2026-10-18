#include "../native_window_persistence.h"

#include <cmath>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <tuple>

using mhabit_desktop_window_chrome::NativeWindowPersistence;
constexpr double kConfiguredMinimumWidth = 410;
constexpr double kConfiguredMinimumHeight = 540;

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
    const mhabit_desktop_window_chrome::WindowsWindowState saved{
        100, 100, 800, 600, 96, 0, 0, 1920, 1080};
    Check(!owner.Restore(saved), "unconfigured window cannot restore");
    Check(!owner.Initialize(window, 0, kConfiguredMinimumHeight),
          "rejects an empty minimum without configuring the window");
    Check(!owner.Initialize(window, std::numeric_limits<double>::quiet_NaN(),
                            kConfiguredMinimumHeight),
          "rejects a nonfinite minimum without configuring the window");
    Check(!owner.Restore(saved),
          "invalid initialization does not enable restore");
    Check(owner.Initialize(window, kConfiguredMinimumWidth,
                           kConfiguredMinimumHeight),
          "hidden window initializes once");
    Check(!owner.Initialize(window, kConfiguredMinimumWidth,
                            kConfiguredMinimumHeight),
          "initialization is idempotent");
    Check(!owner.Initialize(window, std::numeric_limits<double>::infinity(),
                            kConfiguredMinimumHeight),
          "invalid reinitialization preserves the configured minimum");
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
    auto undersized = *original;
    undersized.width = 1;
    undersized.height = 1;
    Check(owner.Restore(undersized), "restores an undersized record");
    ShowWindow(window, SW_SHOWNORMAL);
    const auto clamped = owner.Capture();
    Check(
        clamped &&
            clamped->width >=
                kConfiguredMinimumWidth * clamped->dpi / 96.0 - 2 &&
            clamped->height >=
                kConfiguredMinimumHeight * clamped->dpi / 96.0 - 2,
        "restored frame uses the supplied minimum rather than an app default");
    ShowWindow(window, SW_HIDE);
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
