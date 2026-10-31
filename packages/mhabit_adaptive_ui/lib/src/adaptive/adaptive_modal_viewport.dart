import 'dart:math' as math;
import 'dart:ui' show DisplayFeatureType;

import 'package:flutter/widgets.dart';

/// Sheets ignore top/bottom fold partitions; dialogs keep their original data.
class AdaptiveModalMediaQuery extends StatelessWidget {
  const AdaptiveModalMediaQuery({
    super.key,
    required this.isSheet,
    required this.child,
  });

  final bool isSheet;
  final Widget child;

  MediaQueryData _resolve(MediaQueryData media) {
    if (!isSheet) return media;
    final features = media.displayFeatures.where((feature) {
      final isFold =
          feature.type == DisplayFeatureType.fold ||
          feature.type == DisplayFeatureType.hinge;
      return !isFold ||
          feature.bounds.left > 0 ||
          feature.bounds.right < media.size.width;
    }).toList();
    return features.length == media.displayFeatures.length
        ? media
        : media.copyWith(displayFeatures: features);
  }

  @override
  Widget build(BuildContext context) =>
      MediaQuery(data: _resolve(MediaQuery.of(context)), child: child);
}

/// Publishes the space available to content inside an existing modal route.
///
/// Display-feature selection and insets remain owned by that route. Only the
/// local size changes, so content does not mistake a pane for the full window.
/// This boundary stays installed during resizing to preserve content state.
class AdaptiveModalViewport extends StatelessWidget {
  const AdaptiveModalViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final media = MediaQuery.of(context);
      return MediaQuery(
        data: media.copyWith(
          size: Size(
            math.min(media.size.width, constraints.maxWidth),
            math.min(media.size.height, constraints.maxHeight),
          ),
        ),
        child: child,
      );
    },
  );
}
