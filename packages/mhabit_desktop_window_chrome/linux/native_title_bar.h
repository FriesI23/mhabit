#ifndef MHABIT_LINUX_NATIVE_TITLE_BAR_H_
#define MHABIT_LINUX_NATIVE_TITLE_BAR_H_

#include <gtk/gtk.h>

#include <cstdint>

namespace mhabit_desktop_window_chrome {

// Uses GTK's application theme preference, leaving all decoration to the theme.
class NativeTitleBar {
 public:
  NativeTitleBar() = default;
  ~NativeTitleBar() { Reset(); }
  void Attach(GtkWindow* window);
  bool SetAppearance(int64_t background, int64_t foreground, bool dark);
  void Reset();

 private:
  GtkWindow* window_ = nullptr;
  GtkSettings* settings_ = nullptr;
  gulong destroy_handler_ = 0;
  bool owned_ = false;
  gboolean original_dark_ = FALSE;
  gboolean requested_dark_ = FALSE;
  NativeTitleBar(const NativeTitleBar&) = delete;
  NativeTitleBar& operator=(const NativeTitleBar&) = delete;
};

}  // namespace mhabit_desktop_window_chrome

#endif  // MHABIT_LINUX_NATIVE_TITLE_BAR_H_
