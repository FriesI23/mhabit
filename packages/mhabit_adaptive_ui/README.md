# Adaptive UI (internal package)

Shared Material and Cupertino components. Configure app defaults through
`ThemeData.extensions`:

```dart
ThemeData(
  extensions: const [
    AppAdaptiveUiThemeData(
      style: AdaptiveStyle.apple,
      listTheme: AdaptiveListThemeData(iconColor: CupertinoColors.systemGrey),
    ),
  ],
)
```

For subtree overrides, read the parent theme inside `build` and use `copyWith`
to preserve unrelated fields:

```dart
final theme = AppAdaptiveUiTheme.of(context);
return AppAdaptiveUiTheme(
  data: theme.copyWith(
    cupertinoFocusTheme: theme.cupertinoFocusTheme.copyWith(haloWidth: 6),
  ),
  child: child,
);
```

For list-only overrides, use `AdaptiveListTheme.merge`.

Internal examples: [theme tests](test/app_adaptive_ui_theme_test.dart) and
[app integration](../../lib/entries/common/app_root_view.dart).
