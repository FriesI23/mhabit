# Linux native title bar

Linux shares the independent Windows title-bar Dart controller and Pigeon schema,
but GTK owns its complete native appearance. `setAppearance` maps the application's
brightness to `GtkSettings:gtk-application-prefer-dark-theme`. It does not inject
CSS, force a theme name, or apply the requested ARGB colors. GTK manages titlebar
buttons, separators, shadows, inactive/hover/pressed states and accessibility.

The GTK setting affects this application's native GTK widgets, including dialogs,
not desktop-wide settings or other applications. The theme supplies a dark variant
when available; otherwise GTK retains its native fallback. No theme-specific or
high-contrast exceptions are implemented. The runner retains its existing choice
of GTK HeaderBar or system decoration; window-manager decorations may ignore the
application's GTK preference. GTK 3 does not promise GTK 4/libadwaita button shapes.

`setAppearance` returns `false` for exact-color support on Linux, even when the
native brightness preference is applied successfully. This preserves the shared
API's existing meaning. Dart `customColorsSupported` describes the last submitted
request; it is not a general theme-success indicator. Windows keeps its ARGB
implementation, and macOS keeps its separate fused-window implementation.

Window titles reuse the app's localized `L10n.appName` via the shared Dart
controller and `window_manager.setTitle`; GTK's built-in GtkWindow/HeaderBar title synchronization keeps CSD and
window-manager decoration on a single source.
The English startup fallback is `Table Habit`. Application locale changes update
the native title without adding a Pigeon method.

The plugin holds a weak Flutter view reference, not a temporary registrar. Reset,
window destroy and plugin disposal restore the original GTK preference, unless a
newer native component has changed it. Only the single main window is supported.
The `window_manager` minimum uses GDK geometry hints, not a portable outer-frame
measurement (CSD shadows and titlebar sizes vary).

## Validation

From the app root, with a working graphical session:

```sh
cmake -S packages/mhabit_desktop_window_chrome/linux/test -B /tmp/mhabit-gtk-tests
cmake --build /tmp/mhabit-gtk-tests
GDK_BACKEND=wayland ctest --test-dir /tmp/mhabit-gtk-tests --output-on-failure
GDK_BACKEND=x11 ctest --test-dir /tmp/mhabit-gtk-tests --output-on-failure
flutter run -d linux -t packages/mhabit_desktop_window_chrome/tool/linux_title_bar_smoke.dart
```

Set the appropriate `DISPLAY`/`XAUTHORITY` or `WAYLAND_DISPLAY`. Native tests compare
realized GTK HeaderBar trees with unmodified GTK reference windows, in normal,
hover, pressed and backdrop states. Windows are not mapped so window-manager focus
differences cannot contaminate those comparisons. Tests also cover dark/light
requests, high contrast via GTK, no HeaderBar, reset, destroy, original-preference
restoration and a newer preference written by another native component.

The Flutter smoke test exercises real Pigeon channels after registrar disposal,
resize, maximize/restore and close. `SMOKE customColors light=false dark=false`
is expected on Linux. It means GTK native colors are used, not that theming failed.

For a teardown control without title-bar appearance calls, run the smoke test with
`--dart-define=SMOKE_SYSTEM_APPEARANCE=true`. Flutter 3.44.9 on the tested GNOME
session emits implicit-view removal and messenger teardown warnings on close in
both variants. Pointer-driven window interactions, other desktops and a standalone
Xorg session still need manual acceptance testing.
