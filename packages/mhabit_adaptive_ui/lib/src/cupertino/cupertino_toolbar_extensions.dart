import 'package:flutter/foundation.dart' show TargetPlatform;

const double _desktopToolbarTopInset = 10;

/// Local Cupertino toolbar defaults; these do not modify viewport safe areas.
extension CupertinoToolbarPlatform on TargetPlatform {
  double get defaultCupertinoToolbarTopInset => switch (this) {
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => _desktopToolbarTopInset,
    _ => 0,
  };
}
