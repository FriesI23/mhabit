#ifndef RUNNER_FLUTTER_SURFACE_REFRESH_H_
#define RUNNER_FLUTTER_SURFACE_REFRESH_H_

#include <windows.h>

// Hidden startup resizing can leave Flutter's EGL surface with transposed
// dimensions (https://github.com/flutter/flutter/issues/187922). A redraw or a
// MoveWindow to the same size does not start a new surface resize. Briefly resize
// only the Flutter child before revealing the window, then restore its exact
// client bounds. The top-level placement and saved geometry are unaffected.
inline bool RefreshFlutterSurface(HWND window, HWND content) {
  RECT frame{};
  if (!IsWindow(content) || !GetClientRect(window, &frame)) return false;
  const LONG width = frame.right - frame.left;
  const LONG height = frame.bottom - frame.top;
  if (width <= 0 || height <= 0) return false;

  const BOOL resized = MoveWindow(content, frame.left, frame.top, width + 1,
                                  height, FALSE);
  const BOOL restored = MoveWindow(content, frame.left, frame.top, width,
                                   height, TRUE);
  return resized && restored;
}

#endif  // RUNNER_FLUTTER_SURFACE_REFRESH_H_
