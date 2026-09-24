import '../platform/ios_system_version.dart';

/// Visual treatment for the Apple medium-and-larger Sidebar.
enum AppleSidebarStyle {
  /// An inset liquid-glass surface.
  inset,

  /// A liquid-glass column flush with the window edge.
  edge;

  /// Selects the app-owned presentation for an iOS or iPadOS release.
  static AppleSidebarStyle from(IosSystemVersion? version) =>
      version != null &&
          version >= const IosSystemVersion(_edgeMinimumMajorVersion)
      ? edge
      : inset;

  static const int _edgeMinimumMajorVersion = 27;
}
