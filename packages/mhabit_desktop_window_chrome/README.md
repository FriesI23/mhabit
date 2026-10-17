# Desktop window chrome (internal package)

Native desktop window appearance and ordinary-window size/position persistence.

- `DesktopWindowChrome`: macOS fused title bar and window-control geometry.
- `DesktopWindowTitleBar`: Windows/Linux native title bar appearance.
- `DesktopWindowPersistenceController`: restore, debounced saves, and close flushing.
  `DesktopWindowStateStore` provides typed storage with an app-supplied backend.
  Adapters implement native AppKit or store-backed initialization and saving.

macOS uses AppKit autosave. Windows stores Win32 placement in local preferences.
Linux saves GTK size and best-effort X11 position; Wayland chooses the position.
Restarts restore ordinary-window geometry only.

Initialize the app's [persistence service](../../lib/storage/desktop_window_persistence.dart)
before configuring the title bar:

```dart
await DesktopWindowPersistence().init();
```

Restore while the window is hidden, then show it after the first Flutter frame.

Internal examples: [app startup](../../lib/main.dart) and [package tests](test/).
Linux setup: [native title bar](linux/README.md).

Run `make test` and `make test-native` from the app root.
