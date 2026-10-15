# Adaptive UI（内部包）

Material / Cupertino 组件与布局基础设施。统一配置入口是
`AppAdaptiveUiThemeData`，局部覆盖使用 `AppAdaptiveUiTheme`。

## 全局配置

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

配置字段：`style`、`breakpoints`、`listTheme`、`appBarTheme`、
`cupertinoButtonTheme`、`cupertinoFocusTheme`。

## 局部覆盖

在已有 `build` 方法的 context 中读取父配置，无需额外的 Builder：

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

列表单独覆盖可以使用
`AdaptiveListTheme.merge(data: const AdaptiveListThemeData(...), child: list)`。

## 规则

- 总主题读取：最近局部主题 → Flutter Theme 扩展 → 默认配置。
- 局部主题与组件内部选择共用一个数据节点，由 Flutter 处理最近覆盖和更新。
- 局部 `data` 替换整套配置；保留其他字段时使用父配置的 `copyWith`。
- `copyWith` 省略 `style` / `breakpoints` 保留原值，显式 null 恢复自动选择。
- style 自动选择跟随 `ThemeData.platform`；断点跟随解析后的设计体系。
- 列表字段：显式组件参数 → 局部列表主题 → 总主题 → renderer 默认值。
- 固定 Material 滚动背景会关闭 tint，保留滚动阴影、布局和搜索焦点配色。
- Dialog / Sheet 保留打开时的 style 和 Sheet 断点；内部选择不冻结整套配置。
- 显式局部总主题、列表主题会被捕获；根主题继续更新。
- Sheet 其他主题沿用底层 Flutter 路由的规则，不额外冻结 Sidebar 的 CupertinoTheme。
- 窗口几何、导航状态、控制器和交互能力继续由各自的 Scope / Binding 管理。
- 普通 Style 对象与外部包主题维持各自职责。

焦点外观由 `AdaptiveCupertinoFocusDecoration` 渲染：

```dart
AdaptiveCupertinoFocusDecoration(
  visible: hasFocus,
  decoration: decoration,
  child: child,
)
```

它在构建时读取当前主题并解析动态颜色；`AdaptiveCupertinoFocusHalo` 负责观察焦点，
Sidebar / Actions 使用各自已有的状态与形状组合同一个装饰 widget。
`AdaptiveCupertinoFocusThemeData` 仅保存配置。
