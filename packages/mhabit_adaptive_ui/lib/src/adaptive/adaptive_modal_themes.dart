import 'package:flutter/widgets.dart';

import '../app_adaptive_ui_theme.dart';
import 'adaptive_list_theme.dart';

/// Captures explicit adaptive configuration below the target Navigator.
///
/// The underlying Flutter route retains ownership of other inherited themes.
/// Capturing every theme here would additionally freeze ambient Cupertino
/// themes derived by Sidebar, which responsive sheets previously inherited live.
class AdaptiveModalThemes {
  const AdaptiveModalThemes._(this.theme, this.listTheme);

  final AppAdaptiveUiThemeData? theme;
  final AdaptiveListThemeData? listTheme;

  static AdaptiveModalThemes capture(BuildContext from, BuildContext to) {
    final sourceList = from.getInheritedWidgetOfExactType<AdaptiveListTheme>();
    final targetList = to.getInheritedWidgetOfExactType<AdaptiveListTheme>();
    return AdaptiveModalThemes._(
      captureAdaptiveUiThemeData(from, to),
      identical(sourceList, targetList) ? null : sourceList?.data,
    );
  }

  Widget wrap(Widget child) {
    if (listTheme case final data?) {
      child = AdaptiveListTheme(data: data, child: child);
    }
    if (theme case final data?) {
      child = AppAdaptiveUiTheme(data: data, child: child);
    }
    return child;
  }
}
