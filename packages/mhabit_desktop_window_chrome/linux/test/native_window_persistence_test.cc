#include "../native_window_persistence.h"

#include <limits>

using mhabit_desktop_window_chrome::NativeWindowPersistence;

static void settle_window() {
  for (int attempt = 0; attempt < 50; ++attempt) {
    while (gtk_events_pending()) gtk_main_iteration();
    g_usleep(10000);
  }
}

static void minimum_size(gconstpointer data) {
  auto* widget = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  auto* window = GTK_WINDOW(widget);
  if (GPOINTER_TO_INT(data)) {
    auto* header = gtk_header_bar_new();
    gtk_widget_show(header);
    gtk_window_set_titlebar(window, header);
  }
  auto* content = gtk_drawing_area_new();
  gtk_container_add(GTK_CONTAINER(window), content);
  gtk_widget_show(content);
  gtk_window_set_default_size(window, 800, 650);
  gtk_widget_realize(widget);
  NativeWindowPersistence owner;
  g_assert_true(owner.Initialize(window, 350, 520));

  // Match window_manager's later setMinimumSize call. GTK must retain the
  // constraint when mapping and recalculating the window's geometry hints.
  GdkGeometry geometry{};
  geometry.min_width = 350;
  geometry.min_height = 520;
  gdk_window_set_geometry_hints(gtk_widget_get_window(widget), &geometry,
                                GDK_HINT_MIN_SIZE);
  gtk_widget_show(widget);
  settle_window();
  gtk_window_resize(window, 100, 100);
  settle_window();
  int width, height;
  gtk_window_get_size(window, &width, &height);
  g_assert_cmpint(width, >=, 350);
  g_assert_cmpint(height, >=, 520);
  g_assert_cmpint(gtk_widget_get_allocated_width(content), >=, 350);
  g_assert_cmpint(gtk_widget_get_allocated_height(content), >=, 520);

  // A subsequent layout must not discard the constraint either.
  gtk_container_set_border_width(GTK_CONTAINER(window), 1);
  gtk_window_resize(window, 120, 120);
  settle_window();
  gtk_window_get_size(window, &width, &height);
  g_assert_cmpint(width, >=, 350);
  g_assert_cmpint(height, >=, 520);
  g_assert_cmpint(gtk_widget_get_allocated_width(content), >=, 350);
  g_assert_cmpint(gtk_widget_get_allocated_height(content), >=, 520);

  gtk_window_resize(window, 800, 650);
  settle_window();
  gtk_window_get_size(window, &width, &height);
  g_assert_cmpint(width, >=, 800);
  g_assert_cmpint(height, >=, 650);
  gtk_widget_destroy(widget);
}

static void round_trip() {
  auto* widget = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_widget_realize(widget);
  auto* window = GTK_WINDOW(widget);
  NativeWindowPersistence owner;
  g_assert_true(owner.Initialize(window, 350, 520));
  g_assert_false(owner.Initialize(window, 350, 520));
  g_assert_true(owner.Capture().empty());
  g_assert_false(owner.Restore({0, 600}));
  g_assert_false(owner.Restore({800, std::numeric_limits<double>::quiet_NaN()}));
  g_assert_true(owner.Restore({800, 600, 100, 100}));
  g_assert_false(gtk_widget_get_visible(widget));
  int width, height;
  gtk_window_get_default_size(window, &width, &height);
  g_assert_cmpint(width, >=, 350);
  g_assert_cmpint(height, >=, 520);
  gtk_widget_show(widget);
  // Native Wayland mapping waits for the compositor's first configure.
  for (int attempt = 0; attempt < 100 && owner.Capture().empty(); ++attempt) {
    while (gtk_events_pending()) gtk_main_iteration();
    g_usleep(10000);
  }
  const auto placement = owner.Capture();
  g_assert_cmpuint(placement.size(), ==,
      NativeWindowPersistence::CanPosition(gtk_widget_get_display(widget)) ? 4 : 2);
  g_assert_false(owner.Restore({900, 700}));
  gtk_widget_hide(widget);
  g_assert_true(owner.Restore({900000, 900000, 900000, 900000}));
  GdkRectangle work{};
  auto* display = gtk_widget_get_display(widget);
  auto* monitor = gdk_display_get_monitor_at_window(display, gtk_widget_get_window(widget));
  gdk_monitor_get_workarea(monitor, &work);
  gtk_window_get_default_size(window, &width, &height);
  g_assert_cmpint(width, <=, work.width);
  g_assert_cmpint(height, <=, work.height);
  gtk_widget_destroy(widget);
  g_assert_true(owner.Capture().empty());
  g_assert_false(owner.Restore({800, 600}));
}

int main(int argc, char** argv) {
  gtk_test_init(&argc, &argv, nullptr);
  g_test_add_func("/persistence/round-trip-and-backend-capability", round_trip);
  g_test_add_data_func("/persistence/minimum-size/server-decorations",
      GINT_TO_POINTER(0), minimum_size);
  g_test_add_data_func("/persistence/minimum-size/header-bar",
      GINT_TO_POINTER(1), minimum_size);
  return g_test_run();
}
