#include "native_title_bar.h"

namespace mhabit_desktop_window_chrome {

void NativeTitleBar::Attach(GtkWindow* window) {
  if (window == window_) return;
  Reset();
  if (!window || gtk_widget_in_destruction(GTK_WIDGET(window))) return;
  window_ = window;
  destroy_handler_ = g_signal_connect(
      window_, "destroy", G_CALLBACK(+[](GtkWidget*, gpointer data) {
        static_cast<NativeTitleBar*>(data)->Reset();
      }), this);
  settings_ = GTK_SETTINGS(
      g_object_ref(gtk_widget_get_settings(GTK_WIDGET(window_))));
}

bool NativeTitleBar::SetAppearance(int64_t /*background*/,
                                   int64_t /*foreground*/, bool dark) {
  if (!settings_) return false;
  if (!owned_) {
    g_object_get(settings_, "gtk-application-prefer-dark-theme",
                 &original_dark_, nullptr);
    owned_ = true;
  }
  requested_dark_ = dark;
  gboolean current_dark = FALSE;
  g_object_get(settings_, "gtk-application-prefer-dark-theme",
               &current_dark, nullptr);
  if (current_dark != requested_dark_) {
    g_object_set(settings_, "gtk-application-prefer-dark-theme",
                 requested_dark_, nullptr);
  }
  // GTK owns colors, button states, separators and accessibility styling.
  // False means exact application colors are unsupported, not a theme failure.
  return false;
}

void NativeTitleBar::Reset() {
  if (settings_) {
    gboolean current_dark = FALSE;
    g_object_get(settings_, "gtk-application-prefer-dark-theme",
                 &current_dark, nullptr);
    // Do not overwrite a newer preference set by another native app component.
    if (owned_ && current_dark == requested_dark_) {
      g_object_set(settings_, "gtk-application-prefer-dark-theme",
                   original_dark_, nullptr);
    }
    g_clear_object(&settings_);
  }
  owned_ = false;
  if (window_ && destroy_handler_) {
    g_signal_handler_disconnect(window_, destroy_handler_);
  }
  destroy_handler_ = 0;
  window_ = nullptr;
}

}  // namespace mhabit_desktop_window_chrome
