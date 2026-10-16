# Linux native title bar

GTK owns native decorations. Appearance requests set the application's
`gtk-application-prefer-dark-theme`; exact ARGB colors are not applied, so
`lastCustomColorsApplied` is `false`. Titles use `window_manager.setTitle`.

Internal example: [Linux smoke test](../tool/linux_title_bar_smoke.dart).
Native tests live in [test/](test/).

Run from the app root on Linux with a graphical session:

```sh
make test-linux
flutter run -d linux -t packages/mhabit_desktop_window_chrome/tool/linux_title_bar_smoke.dart
```

Native tests require CMake/CTest >= 3.21, a C++ compiler, pkg-config, and GTK 3
development files. For headless runs, also install Xvfb and xauth, then use:

```sh
NO_AT_BRIDGE=1 GDK_BACKEND=x11 xvfb-run -a make test-linux
```
