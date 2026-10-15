#ifndef MHABIT_DESKTOP_WINDOW_CHROME_PLUGIN_C_API_H_
#define MHABIT_DESKTOP_WINDOW_CHROME_PLUGIN_C_API_H_

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define MHABIT_CHROME_EXPORT __declspec(dllexport)
#else
#define MHABIT_CHROME_EXPORT __declspec(dllimport)
#endif

#ifdef __cplusplus
extern "C" {
#endif
/// Registers the title-bar message API and system appearance notifications.
/// @param registrar Borrowed registrar supplied by Flutter's generated plugin
/// registration flow. Flutter owns the registered plugin until engine teardown.
MHABIT_CHROME_EXPORT void DesktopWindowChromePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);
#ifdef __cplusplus
}
#endif
#endif
