#include "../flutter_surface_refresh.h"

#include <iostream>
#include <stdexcept>
#include <vector>

namespace {
struct WindowState {
  std::vector<SIZE> sizes;
};

LRESULT CALLBACK WindowProc(HWND window, UINT message, WPARAM wparam,
                            LPARAM lparam) {
  if (message == WM_NCCREATE) {
    const auto* creation = reinterpret_cast<CREATESTRUCTW*>(lparam);
    SetWindowLongPtrW(window, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(creation->lpCreateParams));
  } else if (message == WM_SIZE) {
    auto* state = reinterpret_cast<WindowState*>(
        GetWindowLongPtrW(window, GWLP_USERDATA));
    if (state) state->sizes.push_back({LOWORD(lparam), HIWORD(lparam)});
  }
  return DefWindowProcW(window, message, wparam, lparam);
}

void Check(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}
}  // namespace

int main() {
  WNDCLASSW window_class{};
  window_class.lpfnWndProc = WindowProc;
  window_class.hInstance = GetModuleHandleW(nullptr);
  window_class.lpszClassName = L"MhabitSurfaceRefreshTest";
  if (!RegisterClassW(&window_class)) return 1;

  WindowState host_state;
  WindowState child_state;
  HWND host = CreateWindowExW(0, window_class.lpszClassName, L"Surface test",
      WS_OVERLAPPEDWINDOW, 100, 100, 800, 600, nullptr, nullptr,
      window_class.hInstance, &host_state);
  HWND child = CreateWindowExW(0, window_class.lpszClassName, L"Flutter view",
      WS_CHILD | WS_VISIBLE, 0, 0, 1, 1, host, nullptr,
      window_class.hInstance, &child_state);
  try {
    Check(host && child, "creates hidden host and child windows");
    for (const SIZE size : {SIZE{1264, 711}, SIZE{711, 1264}, SIZE{350, 520}}) {
      // Model restored native placement with an already correctly sized HWND.
      // A same-size MoveWindow must not be relied on to repair its EGL surface.
      Check(MoveWindow(host, 100, 100, size.cx, size.cy, FALSE), "restores host size");
      RECT client{};
      GetClientRect(host, &client);
      Check(MoveWindow(child, 0, 0, client.right, client.bottom, FALSE),
          "sizes the child to the restored client area");
      RECT placement{};
      GetWindowRect(host, &placement);
      host_state.sizes.clear();
      child_state.sizes.clear();

      Check(RefreshFlutterSurface(host, child), "refreshes hidden Flutter surface");
      Check(child_state.sizes.size() >= 2,
          "forces real child resize events even when its HWND already fits");
      Check(child_state.sizes.front().cx != client.right ||
            child_state.sizes.front().cy != client.bottom,
          "starts a fresh surface resize with different dimensions");
      const SIZE final_size = child_state.sizes.back();
      Check(final_size.cx == client.right && final_size.cy == client.bottom,
          "last resize restores the correct width and height");
      RECT child_bounds{};
      GetClientRect(child, &child_bounds);
      Check(EqualRect(&child_bounds, &client), "child exactly fills restored client area");
      POINT origin{};
      MapWindowPoints(child, host, &origin, 1);
      Check(origin.x == 0 && origin.y == 0, "child stays at the client origin");
      RECT final_placement{};
      GetWindowRect(host, &final_placement);
      Check(EqualRect(&placement, &final_placement) && host_state.sizes.empty(),
          "does not resize or move the top-level window");
      Check(!(GetWindowLongPtrW(host, GWL_STYLE) & WS_VISIBLE),
          "does not reveal the startup window");
    }
    Check(!RefreshFlutterSurface(nullptr, child), "invalid host is ignored");
    Check(!RefreshFlutterSurface(host, nullptr), "invalid child is ignored");
    DestroyWindow(host);
    std::cout << "Hidden Flutter surface refresh passed\n";
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    DestroyWindow(host);
    return 1;
  }
  return 0;
}
