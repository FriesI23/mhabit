#ifndef FLUTTER_PLUGIN_DESKTOP_WINDOW_CHROME_PLUGIN_H_
#define FLUTTER_PLUGIN_DESKTOP_WINDOW_CHROME_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

G_DECLARE_FINAL_TYPE(DesktopWindowChromePlugin, desktop_window_chrome_plugin,
                    DESKTOP, WINDOW_CHROME_PLUGIN, GObject)

__attribute__((visibility("default"))) void
    desktop_window_chrome_plugin_register_with_registrar(
        FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_DESKTOP_WINDOW_CHROME_PLUGIN_H_
