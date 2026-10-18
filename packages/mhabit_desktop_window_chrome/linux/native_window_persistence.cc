#include "native_window_persistence.h"

#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#include <algorithm>
#include <cmath>
#include <initializer_list>

namespace mhabit_desktop_window_chrome {
NativeWindowPersistence::~NativeWindowPersistence() {
  Dispose();
  if (window_) {
    g_object_remove_weak_pointer(G_OBJECT(window_),
                                 reinterpret_cast<gpointer*>(&window_));
  }
}

void NativeWindowPersistence::Dispose() {
  if (window_ && configure_handler_)
    g_signal_handler_disconnect(window_, configure_handler_);
  configure_handler_ = 0;
  configured_minimum_size_.reset();
}

bool NativeWindowPersistence::CanPosition(GdkDisplay* display) {
#ifdef GDK_WINDOWING_X11
  return display && GDK_IS_X11_DISPLAY(display);
#else
  (void)display;
  return false;
#endif
}

bool NativeWindowPersistence::Initialize(GtkWindow* window,
                                         double minimum_width,
                                         double minimum_height) {
  if (!window || !std::isfinite(minimum_width) ||
      !std::isfinite(minimum_height) || minimum_width < 1 ||
      minimum_height < 1 || minimum_width > G_MAXINT ||
      minimum_height > G_MAXINT) {
    return false;
  }
  const bool was_initialized = configured_minimum_size_.has_value();
  if (!window_) {
    window_ = window;
    g_object_add_weak_pointer(G_OBJECT(window_),
                              reinterpret_cast<gpointer*>(&window_));
  }
  configured_minimum_size_ = WindowMinimumSize{
      static_cast<int>(minimum_width), static_cast<int>(minimum_height)};
  // Keep the minimum on the content widget: GTK replaces window_manager's
  // GDK-only hints on map/layout, and a toplevel request includes CSD shadows.
  auto* content = gtk_bin_get_child(GTK_BIN(window_));
  gtk_widget_set_size_request(content ? content : GTK_WIDGET(window_),
                              configured_minimum_size_->width,
                              configured_minimum_size_->height);
  if (was_initialized) return false;
  configure_handler_ = g_signal_connect_after(
      window_, "configure-event",
      G_CALLBACK(
          +[](GtkWidget*, GdkEventConfigure*, gpointer data) -> gboolean {
            auto* owner = static_cast<NativeWindowPersistence*>(data);
            const auto value = owner->Capture();
            if (value) owner->ordinary_ = value;
            return FALSE;
          }),
      this);
  return !gtk_widget_get_visible(GTK_WIDGET(window_));
}

bool NativeWindowPersistence::Restore(const LinuxWindowState& state) {
  if (!configured_minimum_size_ || !window_ ||
      gtk_widget_get_visible(GTK_WIDGET(window_))) {
    return false;
  }
  for (double value : {state.width, state.height}) {
    if (!std::isfinite(value) || std::abs(value) > 1e7) return false;
  }
  if (state.width <= 0 || state.height <= 0) return false;
  if (state.position &&
      (!std::isfinite(state.position->x) || !std::isfinite(state.position->y) ||
       std::abs(state.position->x) > 1e7 || std::abs(state.position->y) > 1e7))
    return false;
  auto* display = gtk_widget_get_display(GTK_WIDGET(window_));
  const bool position = state.position.has_value() && CanPosition(display);
  GdkMonitor* monitor =
      position ? gdk_display_get_monitor_at_point(display, state.position->x,
                                                  state.position->y)
               : gdk_display_get_monitor_at_window(
                     display, gtk_widget_get_window(GTK_WIDGET(window_)));
  if (!monitor) monitor = gdk_display_get_primary_monitor(display);
  if (!monitor) monitor = gdk_display_get_monitor(display, 0);
  if (!monitor) return false;
  GdkRectangle work{};
  gdk_monitor_get_workarea(monitor, &work);
  const int width = std::min(
      work.width,
      std::max(configured_minimum_size_->width, static_cast<int>(state.width)));
  const int height =
      std::min(work.height, std::max(configured_minimum_size_->height,
                                     static_cast<int>(state.height)));
  gtk_window_set_default_size(window_, width, height);
  // Unlike GTK 4, GTK 3 get_default_size is not updated by user resizing.
  // Only the X11 branch may call the global-coordinate APIs.
  if (position) {
    const int x = std::max(work.x, std::min(static_cast<int>(state.position->x),
                                            work.x + work.width - width));
    const int y = std::max(work.y, std::min(static_cast<int>(state.position->y),
                                            work.y + work.height - height));
    gtk_window_move(window_, x, y);
  }
  return true;
}

std::optional<LinuxWindowState> NativeWindowPersistence::Capture() const {
  if (!window_ || !gtk_widget_get_visible(GTK_WIDGET(window_)))
    return std::nullopt;
  auto* native = gtk_widget_get_window(GTK_WIDGET(window_));
  if (!native) return std::nullopt;
  const auto state = gdk_window_get_state(native);
  if (state & (GDK_WINDOW_STATE_ICONIFIED | GDK_WINDOW_STATE_MAXIMIZED |
               GDK_WINDOW_STATE_FULLSCREEN | GDK_WINDOW_STATE_WITHDRAWN |
               GDK_WINDOW_STATE_TILED))
    return ordinary_;
  int width, height;
  gtk_window_get_size(window_, &width, &height);
  if (width <= 0 || height <= 0) return std::nullopt;
  LinuxWindowState result{static_cast<double>(width),
                          static_cast<double>(height), std::nullopt};
  if (CanPosition(gtk_widget_get_display(GTK_WIDGET(window_)))) {
    int x, y;
    gtk_window_get_position(window_, &x, &y);
    result.position =
        LinuxWindowPosition{static_cast<double>(x), static_cast<double>(y)};
  }
  return result;
}
}  // namespace mhabit_desktop_window_chrome
