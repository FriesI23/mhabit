#ifndef MHABIT_GTK_NATIVE_WINDOW_PERSISTENCE_H_
#define MHABIT_GTK_NATIVE_WINDOW_PERSISTENCE_H_

#include <gtk/gtk.h>
#include <vector>

namespace mhabit_desktop_window_chrome {

class NativeWindowPersistence {
 public:
  ~NativeWindowPersistence();
  bool Initialize(GtkWindow* window, double minimum_width, double minimum_height);
  bool Restore(const std::vector<double>& values);
  void Dispose();
  // Returns the latest ordinary frame, including during maximize/fullscreen.
  // Empty means unavailable. GTK values are logical dimensions.
  std::vector<double> Capture() const;
  static bool CanPosition(GdkDisplay* display);

 private:
  GtkWindow* window_ = nullptr;  // weak, cleared automatically on destruction
  bool initialized_ = false;
  int minimum_width_ = 350;
  int minimum_height_ = 520;
  gulong configure_handler_ = 0;
  std::vector<double> ordinary_;
};
}  // namespace mhabit_desktop_window_chrome
#endif
