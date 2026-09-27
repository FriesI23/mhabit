import '../platform/apple_system_version.dart';

/// Visual treatment for the Apple medium-and-larger Sidebar.
enum AppleSidebarStyle {
  /// An inset liquid-glass surface.
  inset,

  /// A liquid-glass column flush with the window edge.
  edge;

  /// Selects the app-owned presentation for an Apple OS release.
  static AppleSidebarStyle from(AppleSystemVersion? version) =>
      version != null &&
          version >= const AppleSystemVersion(_edgeMinimumMajorVersion)
      ? edge
      : inset;

  static const int _edgeMinimumMajorVersion = 27;
}
