#include "../native_title_bar.h"

#include <initializer_list>
using mhabit_desktop_window_chrome::NativeTitleBar;

static void drain() {
  while (gtk_events_pending()) gtk_main_iteration();
}

static GtkWidget* window_with_header() {
  auto* window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  auto* header = gtk_header_bar_new();
  gtk_header_bar_set_title(GTK_HEADER_BAR(header), "Title");
  gtk_header_bar_set_show_close_button(GTK_HEADER_BAR(header), TRUE);
  gtk_window_set_titlebar(GTK_WINDOW(window), header);
  // Realize without mapping so focus/backdrop from the window manager cannot
  // make the two otherwise identical control trees use different states.
  gtk_widget_show_all(header);
  gtk_widget_realize(window);
  drain();
  return window;
}

static gboolean prefers_dark(GtkSettings* settings) {
  gboolean dark = FALSE;
  g_object_get(settings, "gtk-application-prefer-dark-theme", &dark, nullptr);
  return dark;
}

static void assert_same_theme(GtkWidget* actual, GtkWidget* expected) {
  drain();
  auto* actual_style = gtk_widget_get_style_context(actual);
  auto* expected_style = gtk_widget_get_style_context(expected);
  // All states must remain exactly GTK-themed, including inactive and hover.
  for (auto state : {GTK_STATE_FLAG_NORMAL, GTK_STATE_FLAG_BACKDROP,
                     GTK_STATE_FLAG_PRELIGHT, GTK_STATE_FLAG_ACTIVE}) {
    GdkRGBA a, b;
    gtk_style_context_get_color(actual_style, state, &a);
    gtk_style_context_get_color(expected_style, state, &b);
    g_assert_true(gdk_rgba_equal(&a, &b));
    GdkRGBA* a_background = nullptr;
    GdkRGBA* b_background = nullptr;
    gtk_style_context_get(actual_style, state,
                          "background-color", &a_background, nullptr);
    gtk_style_context_get(expected_style, state,
                          "background-color", &b_background, nullptr);
    g_assert_true(gdk_rgba_equal(a_background, b_background));
    gdk_rgba_free(a_background);
    gdk_rgba_free(b_background);
  }
  if (GTK_IS_CONTAINER(actual)) {
    auto* actual_children = gtk_container_get_children(GTK_CONTAINER(actual));
    auto* expected_children = gtk_container_get_children(GTK_CONTAINER(expected));
    g_assert_cmpuint(g_list_length(actual_children), ==,
                     g_list_length(expected_children));
    for (auto* a = actual_children, *b = expected_children; a; a = a->next, b = b->next) {
      assert_same_theme(GTK_WIDGET(a->data), GTK_WIDGET(b->data));
    }
    g_list_free(actual_children);
    g_list_free(expected_children);
  }
}

static void native_theme_and_reset() {
  auto* window = window_with_header();
  auto* reference = window_with_header();
  auto* settings = gtk_widget_get_settings(window);
  auto* header = gtk_window_get_titlebar(GTK_WINDOW(window));
  auto* reference_header = gtk_window_get_titlebar(GTK_WINDOW(reference));
  g_object_set(settings, "gtk-application-prefer-dark-theme", FALSE, nullptr);
  NativeTitleBar bar;
  bar.Attach(GTK_WINDOW(window));
  g_assert_false(bar.SetAppearance(0xff123456, 0xffabcdef, true));
  g_assert_true(prefers_dark(settings));
  assert_same_theme(header, reference_header);
  g_assert_false(bar.SetAppearance(0xff654321, 0xfffedcba, false));
  g_assert_false(prefers_dark(settings));
  assert_same_theme(header, reference_header);
  g_assert_false(bar.SetAppearance(0, 0xffffff, true));
  bar.Reset();
  g_assert_false(prefers_dark(settings));
  bar.Reset();
  assert_same_theme(header, reference_header);
  gtk_widget_destroy(window);
  gtk_widget_destroy(reference);
}

static void fallback_and_lifetime() {
  NativeTitleBar bar;
  g_assert_false(bar.SetAppearance(0, 0xffffff, true));
  auto* plain = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  auto* settings = gtk_widget_get_settings(plain);
  g_object_set(settings, "gtk-application-prefer-dark-theme", FALSE, nullptr);
  bar.Attach(GTK_WINDOW(plain));
  g_assert_false(bar.SetAppearance(0, 0xffffff, true));
  g_assert_null(gtk_window_get_titlebar(GTK_WINDOW(plain)));
  gtk_widget_destroy(plain);
  g_assert_false(prefers_dark(settings));
  g_assert_false(bar.SetAppearance(0, 0xffffff, true));
  bar.Reset();
  auto* window = window_with_header();
  {
    NativeTitleBar scoped;
    scoped.Attach(GTK_WINDOW(window));
    scoped.SetAppearance(0, 0xffffff, true);
    g_assert_true(prefers_dark(settings));
  }
  g_assert_false(prefers_dark(settings));
  gtk_widget_destroy(window);
}

static void system_theme_and_newer_preference() {
  auto* window = window_with_header();
  auto* reference = window_with_header();
  auto* settings = gtk_widget_get_settings(window);
  g_object_set(settings, "gtk-application-prefer-dark-theme", TRUE, nullptr);
  NativeTitleBar bar;
  bar.Attach(GTK_WINDOW(window));
  bar.SetAppearance(0, 0xffffff, false);
  g_autofree gchar* original_theme = nullptr;
  g_object_get(settings, "gtk-theme-name", &original_theme, nullptr);
  g_object_set(settings, "gtk-theme-name", "HighContrast", nullptr);
  assert_same_theme(gtk_window_get_titlebar(GTK_WINDOW(window)),
                    gtk_window_get_titlebar(GTK_WINDOW(reference)));
  g_object_set(settings, "gtk-theme-name", original_theme, nullptr);
  bar.Reset();
  g_assert_true(prefers_dark(settings)); // Restore original true preference.
  bar.Attach(GTK_WINDOW(window));
  bar.SetAppearance(0, 0xffffff, false);
  // A later native component owns a different preference; reset leaves it alone.
  g_object_set(settings, "gtk-application-prefer-dark-theme", TRUE, nullptr);
  bar.Reset();
  g_assert_true(prefers_dark(settings));
  g_object_set(settings, "gtk-application-prefer-dark-theme", FALSE, nullptr);
  gtk_widget_destroy(window);
  gtk_widget_destroy(reference);
}

int main(int argc, char** argv) {
  gtk_test_init(&argc, &argv, nullptr);
  auto* settings = gtk_settings_get_default();
  g_object_set(settings, "gtk-theme-name", "Adwaita", "gtk-enable-animations",
               FALSE, nullptr);
  g_test_add_func("/titlebar/native-theme-reset", native_theme_and_reset);
  g_test_add_func("/titlebar/fallback-lifetime", fallback_and_lifetime);
  g_test_add_func("/titlebar/system-theme-newer-preference", system_theme_and_newer_preference);
  return g_test_run();
}
