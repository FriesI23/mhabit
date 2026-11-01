import 'dart:math' as math;
import 'dart:ui' show DisplayFeatureType;

import 'package:flutter/widgets.dart';

/// Sheets ignore top/bottom fold partitions; dialogs keep their original data.
///
/// Place this above the route's [DisplayFeatureSubScreen]. For sheets, folds
/// and hinges spanning the window's full width are removed from the inherited
/// display features. Side-by-side partitions and cutouts remain available.
///
/// ```text
/// side-by-side fold       top/bottom fold
/// +--------+--------+     +-----------------+
/// | pane   | pane   |     |                 |
/// |        |        |     +-----------------+ <- ignored for sheets
/// |        |        |     |                 |
/// +--------+--------+     +-----------------+
/// select one pane         use full window
/// ```
class AdaptiveModalMediaQuery extends StatelessWidget {
  /// Creates a route-level display-feature filter.
  const AdaptiveModalMediaQuery({
    super.key,
    required this.isSheet,
    required this.child,
  });

  /// Whether to remove full-width fold and hinge features.
  ///
  /// False passes through the original [MediaQueryData] for a dialog.
  final bool isSheet;

  /// The route subtree that selects its display-feature pane.
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
///
/// Place this after the route has selected and positioned its pane. Each size
/// axis is capped at the corresponding layout constraint. Padding, view insets,
/// and display features are passed through without further projection.
class AdaptiveModalViewport extends StatelessWidget {
  /// Publishes the route's constrained viewport size to [child].
  const AdaptiveModalViewport({super.key, required this.child});

  /// The modal content that reads the local [MediaQueryData.size].
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
