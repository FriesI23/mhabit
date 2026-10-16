# Adaptive UI (internal package)

Material and Cupertino components and layout infrastructure. Use
`AppAdaptiveUiThemeData` for shared configuration and `AppAdaptiveUiTheme` for
local overrides.

## Global configuration

```dart
ThemeData(
  extensions: const [
    AppAdaptiveUiThemeData(
      style: AdaptiveStyle.apple,
      listTheme: AdaptiveListThemeData(iconColor: CupertinoColors.systemGrey),
      appBarTheme: AdaptiveAppBarThemeData(
        materialFixedScrollBackground: true,
      ),
    ),
  ],
)
```

Configuration fields: `style`, `breakpoints`, `listTheme`, `appBarTheme`,
`cupertinoButtonTheme`, and `cupertinoFocusTheme`.

## Local overrides

Read the parent configuration from the context of an existing `build` method;
no additional `Builder` is needed:

```dart
@override
Widget build(BuildContext context) {
  final theme = AppAdaptiveUiTheme.of(context);
  return AppAdaptiveUiTheme(
    data: theme.copyWith(
      cupertinoFocusTheme: theme.cupertinoFocusTheme.copyWith(haloWidth: 6),
    ),
    child: content,
  );
}
```

For list-specific overrides, use
`AdaptiveListTheme.merge(data: const AdaptiveListThemeData(...), child: list)`.

## Configuration rules

- Adaptive UI theme lookup: nearest local theme → Flutter theme extension →
  default configuration.
- Local theme lookups and component selectors share the same data node. Flutter
  resolves the nearest override and propagates updates.
- Local `data` replaces the entire configuration. Use the parent configuration's
  `copyWith` to preserve unrelated fields.
- In `copyWith`, omitting `style` or `breakpoints` retains its current value;
  explicitly passing `null` restores automatic selection.
- Automatic style selection follows `ThemeData.platform`; breakpoints follow the
  resolved design style.
- List fields: explicit component arguments → local list theme → adaptive UI
  theme → renderer defaults.
- Fixed Material scroll backgrounds disable tint while preserving scroll
  shadows, layout, and search focus colors.
- Dialogs and sheets retain the style selected when opened; sheets also retain
  their selected breakpoints. Component selectors keep the remaining
  configuration live.
- Explicit local adaptive UI and list themes are captured; root themes remain
  live.
- Other sheet themes follow the underlying Flutter route's rules, without an
  additional snapshot of the sidebar's `CupertinoTheme`.
- Window geometry, navigation state, controllers, and interaction capabilities
  remain managed by their respective scopes and bindings.
- Component `Style` objects and external package themes retain their existing
  responsibilities.

`AdaptiveCupertinoFocusDecoration` renders the focus appearance:

```dart
AdaptiveCupertinoFocusDecoration(
  visible: hasFocus,
  decoration: decoration,
  child: child,
)
```

It reads the current theme and resolves dynamic colors at build time.
`AdaptiveCupertinoFocusHalo` observes focus changes. Sidebar and action components
combine the same decoration widget with their existing state and shapes.
`AdaptiveCupertinoFocusThemeData` stores configuration only.
