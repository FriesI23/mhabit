#include "include/mhabit_desktop_window_chrome/desktop_window_chrome_plugin.h"

#include "desktop_title_bar.g.h"
#include "native_title_bar.h"

struct _DesktopWindowChromePlugin {
  GObject parent_instance;
  GWeakRef view;
  mhabit_desktop_window_chrome::NativeTitleBar* title_bar;
};

G_DEFINE_TYPE(DesktopWindowChromePlugin, desktop_window_chrome_plugin,
              G_TYPE_OBJECT)

static MhabitDesktopTitleBarHostApiSetAppearanceResponse* set_appearance(
    int64_t background, int64_t foreground, gboolean dark, gpointer data) {
  auto* self = DESKTOP_WINDOW_CHROME_PLUGIN(data);
  g_autoptr(FlView) view = FL_VIEW(g_weak_ref_get(&self->view));
  GtkWidget* window = view ? gtk_widget_get_toplevel(GTK_WIDGET(view)) : nullptr;
  self->title_bar->Attach(GTK_IS_WINDOW(window) ? GTK_WINDOW(window) : nullptr);
  return mhabit_desktop_title_bar_host_api_set_appearance_response_new(
      self->title_bar->SetAppearance(background, foreground, dark));
}

static MhabitDesktopTitleBarHostApiResetResponse* reset(gpointer data) {
  DESKTOP_WINDOW_CHROME_PLUGIN(data)->title_bar->Reset();
  return mhabit_desktop_title_bar_host_api_reset_response_new();
}

static void desktop_window_chrome_plugin_dispose(GObject* object) {
  auto* self = DESKTOP_WINDOW_CHROME_PLUGIN(object);
  delete self->title_bar;
  self->title_bar = nullptr;
  g_weak_ref_set(&self->view, nullptr);
  G_OBJECT_CLASS(desktop_window_chrome_plugin_parent_class)->dispose(object);
}

static void desktop_window_chrome_plugin_finalize(GObject* object) {
  g_weak_ref_clear(&DESKTOP_WINDOW_CHROME_PLUGIN(object)->view);
  G_OBJECT_CLASS(desktop_window_chrome_plugin_parent_class)->finalize(object);
}

static void desktop_window_chrome_plugin_class_init(
    DesktopWindowChromePluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = desktop_window_chrome_plugin_dispose;
  G_OBJECT_CLASS(klass)->finalize = desktop_window_chrome_plugin_finalize;
}

static void desktop_window_chrome_plugin_init(DesktopWindowChromePlugin* self) {
  g_weak_ref_init(&self->view, nullptr);
  self->title_bar = new mhabit_desktop_window_chrome::NativeTitleBar();
}

void desktop_window_chrome_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  g_autoptr(DesktopWindowChromePlugin) plugin = DESKTOP_WINDOW_CHROME_PLUGIN(
      g_object_new(desktop_window_chrome_plugin_get_type(), nullptr));
  // Registrars are temporary during registration; keep only a weak view handle.
  g_weak_ref_set(&plugin->view, fl_plugin_registrar_get_view(registrar));
  static const MhabitDesktopTitleBarHostApiVTable vtable = {set_appearance, reset};
  mhabit_desktop_title_bar_host_api_set_method_handlers(
      fl_plugin_registrar_get_messenger(registrar), nullptr, &vtable,
      g_object_ref(plugin), g_object_unref);
}
