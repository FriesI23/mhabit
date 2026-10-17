#include "include/mhabit_desktop_window_chrome/desktop_window_chrome_plugin.h"

#include "desktop_title_bar.g.h"
#include "native_title_bar.h"
#include "native_window_persistence.h"
#include "window_persistence.g.h"

struct _DesktopWindowChromePlugin {
  GObject parent_instance;
  GWeakRef view;
  mhabit_desktop_window_chrome::NativeTitleBar* title_bar;
  mhabit_desktop_window_chrome::NativeWindowPersistence* persistence;
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

static MhabitPersistenceWindowPersistenceHostApiInitializeResponse* initialize_placement(
    const gchar*, double minimum_width, double minimum_height, gpointer data) {
  auto* self = DESKTOP_WINDOW_CHROME_PLUGIN(data);
  g_autoptr(FlView) view = FL_VIEW(g_weak_ref_get(&self->view));
  auto* window = view ? gtk_widget_get_toplevel(GTK_WIDGET(view)) : nullptr;
  return mhabit_persistence_window_persistence_host_api_initialize_response_new(
      self->persistence->Initialize(GTK_IS_WINDOW(window) ? GTK_WINDOW(window) : nullptr,
          minimum_width, minimum_height));
}

static MhabitPersistenceWindowPersistenceHostApiRestoreResponse* restore_placement(
    FlValue* values, gpointer data) {
  std::vector<double> placement;
  for (size_t i = 0; i < fl_value_get_length(values); ++i) {
    auto* value = fl_value_get_list_value(values, i);
    if (fl_value_get_type(value) != FL_VALUE_TYPE_FLOAT) {
      return mhabit_persistence_window_persistence_host_api_restore_response_new();
    }
    placement.push_back(fl_value_get_float(value));
  }
  DESKTOP_WINDOW_CHROME_PLUGIN(data)->persistence->Restore(placement);
  return mhabit_persistence_window_persistence_host_api_restore_response_new();
}

static MhabitPersistenceWindowPersistenceHostApiCaptureResponse* capture_placement(gpointer data) {
  const auto values = DESKTOP_WINDOW_CHROME_PLUGIN(data)->persistence->Capture();
  g_autoptr(FlValue) result = fl_value_new_list();
  for (double value : values) fl_value_append_take(result, fl_value_new_float(value));
  return mhabit_persistence_window_persistence_host_api_capture_response_new(
      values.empty() ? nullptr : result);
}

static MhabitPersistenceWindowPersistenceHostApiFlushResponse* flush_placement(gpointer) {
  return mhabit_persistence_window_persistence_host_api_flush_response_new();
}

static MhabitPersistenceWindowPersistenceHostApiDisposeResponse* dispose_placement(gpointer data) {
  DESKTOP_WINDOW_CHROME_PLUGIN(data)->persistence->Dispose();
  return mhabit_persistence_window_persistence_host_api_dispose_response_new();
}

static void desktop_window_chrome_plugin_dispose(GObject* object) {
  auto* self = DESKTOP_WINDOW_CHROME_PLUGIN(object);
  delete self->title_bar;
  self->title_bar = nullptr;
  delete self->persistence;
  self->persistence = nullptr;
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
  self->persistence = new mhabit_desktop_window_chrome::NativeWindowPersistence();
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
  static const MhabitPersistenceWindowPersistenceHostApiVTable persistence_vtable = {
      initialize_placement, restore_placement, capture_placement, flush_placement,
      dispose_placement};
  mhabit_persistence_window_persistence_host_api_set_method_handlers(
      fl_plugin_registrar_get_messenger(registrar), nullptr, &persistence_vtable,
      g_object_ref(plugin), g_object_unref);
}
