import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../adaptive_style.dart';

/// Selection indicator; the containing row owns input and selected semantics.
class AdaptiveCheckmark extends StatelessWidget {
  const AdaptiveCheckmark({super.key}) : style = null;

  const AdaptiveCheckmark.material({super.key})
    : style = AdaptiveStyle.material;

  const AdaptiveCheckmark.apple({super.key}) : style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;

  @override
  Widget build(BuildContext context) =>
      switch (style ?? AdaptiveStyle.of(context)) {
        AdaptiveStyle.material => const Icon(Icons.check),
        AdaptiveStyle.apple => Icon(
          CupertinoIcons.check_mark,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      };
}
