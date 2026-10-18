#ifndef MHABIT_GTK_NATIVE_WINDOW_PERSISTENCE_H_
#define MHABIT_GTK_NATIVE_WINDOW_PERSISTENCE_H_

#include <gtk/gtk.h>

#include <optional>

namespace mhabit_desktop_window_chrome {

struct LinuxWindowPosition {
  double x;
  double y;
};

struct LinuxWindowState {
  double width;
  double height;
  std::optional<LinuxWindowPosition> position;
};

struct WindowMinimumSize {
  int width;
  int height;
};

// Coordinates native GTK geometry for the persistence adapter; the caller owns
// storage. Initialization establishes constraints independently of saved state.
class NativeWindowPersistence {
 public:
  ~NativeWindowPersistence();
  // Sets the content minimum in GTK logical pixels and observes geometry.
  // Returns true only on first initialization while hidden, allowing Restore.
  bool Initialize(GtkWindow* window, double minimum_width,
                  double minimum_height);
  // Clamps and applies saved geometry while hidden; does not install
  // constraints.
  bool Restore(const LinuxWindowState& state);
  void Dispose();
  // Returns the latest ordinary frame, including during maximize/fullscreen.
  // Null means unavailable. GTK values are logical dimensions.
  std::optional<LinuxWindowState> Capture() const;
  static bool CanPosition(GdkDisplay* display);

 private:
  GtkWindow* window_ = nullptr;  // weak, cleared automatically on destruction
  // Unset until Initialize receives a valid constraint from Dart.
  std::optional<WindowMinimumSize> configured_minimum_size_;
  gulong configure_handler_ = 0;
  std::optional<LinuxWindowState> ordinary_;
};
}  // namespace mhabit_desktop_window_chrome
#endif
