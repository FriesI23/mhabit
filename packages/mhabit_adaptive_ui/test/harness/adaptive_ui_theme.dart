import 'package:flutter/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

/// Applies a partial theme update below the host's Flutter Theme.
class TestAdaptiveUiTheme extends StatelessWidget {
  const TestAdaptiveUiTheme({
    super.key,
    required this.update,
    required this.child,
  });

  final AppAdaptiveUiThemeData Function(AppAdaptiveUiThemeData) update;
  final Widget child;

  @override
  Widget build(BuildContext context) => AppAdaptiveUiTheme(
    data: update(AppAdaptiveUiTheme.of(context)),
    child: child,
  );
}
