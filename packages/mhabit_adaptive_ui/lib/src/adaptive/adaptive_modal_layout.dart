import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// The route presentation used to display adaptive modal content.
enum AdaptiveModalPresentation { sheet, dialog }

/// Regular modal layout with fixed semantic regions around one scroll view.
class AdaptiveModalLayout extends StatefulWidget {
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
    this.onContentHeightChanged,
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
  final ValueChanged<double>? onContentHeightChanged;

  @override
  State<AdaptiveModalLayout> createState() => _AdaptiveModalLayoutState();
}

class _AdaptiveModalLayoutState extends State<AdaptiveModalLayout> {
  final _heights = <String, double>{};
  // Compact layouts move these regions into the scroll view. Keep their state
  // when automatic sizing crosses that threshold or the keyboard opens.
  final _regionKeys = <String, GlobalKey>{};
  bool _reportScheduled = false;

  @override
  void didUpdateWidget(AdaptiveModalLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A sheet can become a dialog without changing any region's dimensions.
    if ((oldWidget.onContentHeightChanged == null &&
            widget.onContentHeightChanged != null) ||
        oldWidget.constraints != widget.constraints) {
      _scheduleHeightReport();
    }
  }

  void _scheduleHeightReport() {
    if (widget.onContentHeightChanged == null || _reportScheduled) return;
    _reportScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportScheduled = false;
      if (!mounted || widget.presentation != AdaptiveModalPresentation.dialog) {
        return;
      }
      final height = _heights.values.fold(0.0, (sum, value) => sum + value);
      final requested = widget.constraints;
      widget.onContentHeightChanged?.call(
        height.clamp(
          requested?.minHeight ?? 0,
          requested?.maxHeight ?? double.infinity,
        ),
      );
    });
  }

  Widget _measure(String region, Widget? child) => _ModalRegionSize(
    key: _regionKeys.putIfAbsent(region, GlobalKey.new),
    onHeight: (height) {
      if (_heights[region] == height) return;
      _heights[region] = height;
      _scheduleHeightReport();
    },
    child: child ?? const SizedBox.shrink(),
  );

  // Local content height after modal constraints, keyboard insets, and safe
  // areas. This fallback is independent of the window presentation breakpoint.
  static const double _compactContentHeight = 320;

  static bool _usesCompactHeightLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) =>
      constraints.maxHeight < _compactContentHeight ||
      MediaQuery.textScalerOf(context).scale(1) > 2;

  @override
  Widget build(BuildContext context) {
    final header = _measure('header', widget.header);
    final pinned = _measure(
      'pinned',
      widget.pinnedBody == null
          ? null
          : Padding(
              key: const ValueKey('adaptive-modal-pinned-body'),
              padding: widget.padding,
              child: widget.pinnedBody,
            ),
    );
    final body = _measure(
      'body',
      Padding(padding: widget.padding, child: widget.body),
    );
    final bottom = _measure(
      'bottom',
      widget.bottomActions.isEmpty
          ? null
          : _AdaptiveModalBottomActions(
              actions: widget.bottomActions,
              padding: widget.padding,
            ),
    );
    final footer = _measure('footer', widget.footer);
    return _AdaptiveModalFrame(
      presentation: widget.presentation,
      constraints: widget.constraints,
      defaultMaxHeight: widget.defaultMaxHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactHeight = _usesCompactHeightLayout(context, constraints);
          // Material Dialog removes the consumed inset from MediaQuery. Check
          // the view for keyboard visibility and local constraints for space.
          final scrollFooter =
              compactHeight && View.of(context).viewInsets.bottom > 0;
          return Column(
            mainAxisSize:
                widget.presentation == AdaptiveModalPresentation.dialog
                ? MainAxisSize.min
                : MainAxisSize.max,
            children: [
              header,
              if (!compactHeight) pinned,
              Flexible(
                key: const ValueKey('adaptive-modal-scroll-region'),
                fit: constraints.hasTightHeight ? FlexFit.tight : FlexFit.loose,
                child: SingleChildScrollView(
                  key: const ValueKey('adaptive-modal-scroll-body'),
                  controller: widget.scrollController,
                  child: compactHeight
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            pinned,
                            body,
                            bottom,
                            if (scrollFooter) footer,
                          ],
                        )
                      : body,
                ),
              ),
              if (!compactHeight) bottom,
              if (!scrollFooter)
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                  child: SingleChildScrollView(child: footer),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ModalRegionSize extends SingleChildRenderObjectWidget {
  const _ModalRegionSize({
    super.key,
    required this.onHeight,
    required super.child,
  });

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderModalRegionSize(onHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderModalRegionSize renderObject,
  ) {
    renderObject.onHeight = onHeight;
    renderObject.markNeedsLayout();
  }
}

class _RenderModalRegionSize extends RenderProxyBox {
  _RenderModalRegionSize(this.onHeight);

  ValueChanged<double> onHeight;

  @override
  void performLayout() {
    super.performLayout();
    onHeight(size.height);
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
      height: presentation == AdaptiveModalPresentation.sheet
          ? double.infinity
          : null,
      width: double.infinity,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          // Dialog route surfaces own keyboard avoidance.
          bottom: presentation == AdaptiveModalPresentation.sheet
              ? MediaQuery.viewInsetsOf(context).bottom
              : 0,
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
