/// Relationship between native window controls and the app's top toolbar.
///
/// Describes a layout, independently of the operating system or adaptive UI
/// style. The diagrams show rows only; native control placement is platform-owned.
enum AppDesktopBarMode {
  /// Native controls share the app toolbar's top row.
  ///
  /// ```text
  /// +---------------------------------------------+
  /// | [controls]       AppBar title / actions     |
  /// +---------------------------------------------+
  /// |                 App content                 |
  /// +---------------------------------------------+
  /// ```
  ///
  /// Material toolbars retain their existing scroll-under color feedback.
  fused,

  /// A native title bar occupies its own row above the app toolbar.
  ///
  /// ```text
  /// +---------------------------------------------+
  /// |           Native title + [controls]         |
  /// +---------------------------------------------+
  /// |              AppBar title / actions         |
  /// +---------------------------------------------+
  /// |                 App content                 |
  /// +---------------------------------------------+
  /// ```
  ///
  /// Material AppBar/search backgrounds stay at their unscrolled colors;
  /// existing scroll shadows and toolbar geometry are preserved.
  separate,
}
