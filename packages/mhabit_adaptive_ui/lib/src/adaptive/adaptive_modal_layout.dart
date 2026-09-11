import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The route presentation used to display adaptive modal content.
enum AdaptiveModalPresentation { sheet, dialog }

/// Regular modal layout with fixed semantic regions around one scroll view.
class AdaptiveModalLayout extends StatelessWidget {
  const AdaptiveModalLayout({
    super.key,
    required this.scrollController,
    this.header,
    required this.pinnedBody,
    required this.body,
    required this.bottomActions,
    required this.padding,
    required this.presentation,
    required this.constraints,
    this.defaultMaxHeight,
    this.footer,
  });

  final ScrollController scrollController;
  final Widget? header;
  final Widget? pinnedBody;
  final Widget body;
  final List<Widget> bottomActions;
  final EdgeInsetsGeometry padding;
  final AdaptiveModalPresentation presentation;
  final BoxConstraints? constraints;
  final double? defaultMaxHeight;
  final Widget? footer;

  static bool _usesCompactHeightLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) =>
      constraints.maxHeight < 320 ||
      MediaQuery.textScalerOf(context).scale(1) > 2;

  @override
  Widget build(BuildContext context) {
    final pinned = pinnedBody == null
        ? null
        : Padding(
            key: const ValueKey('adaptive-modal-pinned-body'),
            padding: padding,
            child: pinnedBody,
          );
    final bottom = bottomActions.isEmpty
        ? null
        : _AdaptiveModalBottomActions(actions: bottomActions, padding: padding);

    return _AdaptiveModalFrame(
      presentation: presentation,
      constraints: constraints,
      defaultMaxHeight: defaultMaxHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactHeight = _usesCompactHeightLayout(context, constraints);
          final constrainedFooter = footer == null
              ? null
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                  child: SingleChildScrollView(child: footer),
                );
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!compactHeight) ...[?header, ?pinned],
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('adaptive-modal-scroll-body'),
                  controller: scrollController,
                  padding: compactHeight ? EdgeInsets.zero : padding,
                  child: compactHeight
                      ? Column(
                          children: [
                            ?header,
                            ?pinned,
                            Padding(padding: padding, child: body),
                            ?bottom,
                          ],
                        )
                      : body,
                ),
              ),
              if (!compactHeight) ?bottom,
              ?constrainedFooter,
            ],
          );
        },
      ),
    );
  }
}

class _AdaptiveModalFrame extends StatelessWidget {
  const _AdaptiveModalFrame({
    required this.presentation,
    required this.constraints,
    this.defaultMaxHeight,
    required this.child,
  });

  final AdaptiveModalPresentation presentation;
  final BoxConstraints? constraints;
  final double? defaultMaxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    key: const ValueKey('adaptive-modal-constraints'),
    constraints: AdaptiveModalConstraints._resolve(
      context,
      presentation: presentation,
      requested: constraints,
      defaultMaxHeight: defaultMaxHeight,
    ),
    child: SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: switch (presentation) {
          AdaptiveModalPresentation.sheet => SafeArea(top: false, child: child),
          AdaptiveModalPresentation.dialog => child,
        },
      ),
    ),
  );
}

class _AdaptiveModalBottomActions extends StatelessWidget {
  const _AdaptiveModalBottomActions({
    required this.actions,
    required this.padding,
  });

  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
    key: const ValueKey('adaptive-modal-bottom-actions'),
    padding: padding,
    child: OverflowBar(
      alignment: MainAxisAlignment.end,
      overflowAlignment: OverflowBarAlignment.end,
      spacing: 8,
      overflowSpacing: 8,
      children: actions,
    ),
  );
}

/// Shared sizing policy for regular and sliver modal layouts and route shells.
abstract final class AdaptiveModalConstraints {
  static const double maxHeight = 720;
  static const double availableHeightFactor = 0.9;
  static const double minSheetExtent = 0;

  static double maximumHeightOf(BuildContext context) => math.min(
    maxHeight,
    MediaQuery.sizeOf(context).height * availableHeightFactor,
  );

  static double maximumSheetExtentOf(BuildContext context) {
    final availableHeight = MediaQuery.sizeOf(context).height;
    if (availableHeight <= 0) return availableHeightFactor;
    return (maximumHeightOf(context) / availableHeight).clamp(
      minSheetExtent,
      availableHeightFactor,
    );
  }

  static BoxConstraints resolve(
    BuildContext context, {
    required AdaptiveModalPresentation presentation,
    required BoxConstraints? requested,
  }) => _resolve(context, presentation: presentation, requested: requested);

  static BoxConstraints _resolve(
    BuildContext context, {
    required AdaptiveModalPresentation presentation,
    required BoxConstraints? requested,
    double? defaultMaxHeight,
  }) {
    final size = MediaQuery.sizeOf(context);
    final defaultMaxWidth = math.min(560.0, size.width * 0.9);
    final resolvedDefaultMaxHeight =
        defaultMaxHeight ?? maximumHeightOf(context);
    return switch ((presentation, requested)) {
      (AdaptiveModalPresentation.sheet, null) => BoxConstraints.tightFor(
        height: resolvedDefaultMaxHeight,
      ),
      (AdaptiveModalPresentation.sheet, final requested?) => requested.copyWith(
        minHeight: math.min(requested.minHeight, resolvedDefaultMaxHeight),
        maxHeight: requested.hasBoundedHeight
            ? math.min(requested.maxHeight, resolvedDefaultMaxHeight)
            : resolvedDefaultMaxHeight,
      ),
      (AdaptiveModalPresentation.dialog, null) => BoxConstraints.tightFor(
        width: defaultMaxWidth,
        height: resolvedDefaultMaxHeight,
      ),
      (AdaptiveModalPresentation.dialog, final requested?) =>
        requested.copyWith(
          minWidth: math.min(requested.minWidth, defaultMaxWidth),
          maxWidth: requested.hasBoundedWidth
              ? math.min(requested.maxWidth, size.width * 0.9)
              : defaultMaxWidth,
          minHeight: math.min(requested.minHeight, resolvedDefaultMaxHeight),
          maxHeight: requested.hasBoundedHeight
              ? math.min(requested.maxHeight, resolvedDefaultMaxHeight)
              : resolvedDefaultMaxHeight,
        ),
    };
  }
}
