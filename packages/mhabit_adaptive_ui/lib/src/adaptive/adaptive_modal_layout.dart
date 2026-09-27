import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'adaptive_sheet.dart';

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
    required this.size,
    this.defaultMaxHeight,
    this.footer,
    this.onContentSizeChanged,
  });

  final ScrollController scrollController;
  final Widget? header;
  final Widget? pinnedBody;
  final Widget body;
  final List<Widget> bottomActions;
  final EdgeInsetsGeometry padding;
  final AdaptiveModalPresentation presentation;
  final AdaptiveModalSize size;
  final double? defaultMaxHeight;
  final Widget? footer;
  final ValueChanged<Size>? onContentSizeChanged;

  @override
  State<AdaptiveModalLayout> createState() => _AdaptiveModalLayoutState();
}

class _AdaptiveModalLayoutState extends State<AdaptiveModalLayout> {
  BoxConstraints get _requested => widget.size.constraints;
  final _regions = <String, Size>{};
  // Stable identities preserve state when regions move into the scroll view.
  final _regionKeys = <String, GlobalKey>{};
  bool _reportScheduled = false;
  Size? _contentSize;

  @override
  void didUpdateWidget(AdaptiveModalLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.onContentSizeChanged == null &&
            widget.onContentSizeChanged != null) ||
        oldWidget.presentation != widget.presentation ||
        oldWidget.size.constraints != _requested) {
      _scheduleSizeReport();
    }
  }

  void _scheduleSizeReport() {
    if (_reportScheduled) return;
    _reportScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportScheduled = false;
      if (!mounted ||
          widget.presentation != AdaptiveModalPresentation.dialog ||
          !_regions.containsKey('body')) {
        return;
      }
      final contentSize = Size(
        _regions['body']!.width,
        _regions.values.fold(0.0, (sum, size) => sum + size.height),
      );
      if (!contentSize.isFinite) return;
      final previous = _contentSize;
      _contentSize = contentSize;
      if (previous == null ||
          _requested.constrain(previous) != _requested.constrain(contentSize)) {
        setState(() {});
      }
      widget.onContentSizeChanged?.call(_requested.constrain(contentSize));
    });
  }

  Widget _measure(String region, Widget? child) => _ModalRegionSize(
    key: _regionKeys.putIfAbsent(region, GlobalKey.new),
    intrinsicWidth:
        region == 'body' &&
        !_requested.hasTightWidth &&
        widget.presentation == AdaptiveModalPresentation.dialog,
    onSize: (size) {
      if (_regions[region] == size) return;
      _regions[region] = size;
      _scheduleSizeReport();
    },
    child: child ?? const SizedBox.shrink(),
  );

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
      constraints: widget.presentation == AdaptiveModalPresentation.sheet
          ? const BoxConstraints()
          : _contentSize == null
          ? _requested
          : BoxConstraints.tight(_requested.constrain(_contentSize!)),
      defaultMaxHeight: widget.defaultMaxHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactHeight =
              AdaptiveModalConstraints.usesCompactHeightLayout(
                context,
                constraints,
              );
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
    required this.onSize,
    required this.intrinsicWidth,
    required super.child,
  });
  final ValueChanged<Size> onSize;
  final bool intrinsicWidth;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderModalRegionSize(onSize, intrinsicWidth);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderModalRegionSize renderObject,
  ) {
    renderObject.onSize = onSize;
    renderObject.intrinsicWidth = intrinsicWidth;
    renderObject.markNeedsLayout();
  }
}

class _RenderModalRegionSize extends RenderProxyBox {
  _RenderModalRegionSize(this.onSize, this.intrinsicWidth);
  ValueChanged<Size> onSize;
  bool intrinsicWidth;

  @override
  void performLayout() {
    super.performLayout();
    onSize(
      Size(
        intrinsicWidth
            ? child!.getMaxIntrinsicWidth(double.infinity)
            : size.width,
        size.height,
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
  final BoxConstraints constraints;
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
  // Local content height after modal constraints, keyboard insets, and safe
  // areas. This fallback is independent of the window presentation breakpoint.
  static const double _compactContentHeight = 320;

  static bool usesCompactHeightLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) =>
      constraints.maxHeight < _compactContentHeight ||
      MediaQuery.textScalerOf(context).scale(1) > 2;

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
    required BoxConstraints requested,
  }) => _resolve(context, presentation: presentation, requested: requested);

  static BoxConstraints _resolve(
    BuildContext context, {
    required AdaptiveModalPresentation presentation,
    required BoxConstraints requested,
    double? defaultMaxHeight,
  }) {
    final available = BoxConstraints(
      maxWidth: MediaQuery.sizeOf(context).width * 0.9,
      maxHeight: defaultMaxHeight ?? maximumHeightOf(context),
    );
    return switch (presentation) {
      AdaptiveModalPresentation.dialog => requested.enforce(available),
      AdaptiveModalPresentation.sheet => BoxConstraints.tightFor(
        height: available.maxHeight,
      ),
    };
  }
}

/// Shares the modal's sole scroll controller without wrapping a viewport in
/// an intrinsic-size probe or another scroll view.
class AdaptiveSliverModalLayout extends StatefulWidget {
  const AdaptiveSliverModalLayout({
    super.key,
    required this.scrollController,
    required this.header,
    required this.pinnedBody,
    required this.slivers,
    required this.bottomActions,
    required this.padding,
    required this.presentation,
    required this.size,
    required this.defaultMaxHeight,
    required this.footer,
    this.onContentSizeChanged,
  });

  final ScrollController scrollController;
  final Widget? header;
  final Widget? pinnedBody;
  final List<Widget> slivers;
  final List<Widget> bottomActions;
  final EdgeInsetsGeometry padding;
  final AdaptiveModalPresentation presentation;
  final AdaptiveModalSize size;
  final double? defaultMaxHeight;
  final Widget? footer;

  final ValueChanged<Size>? onContentSizeChanged;

  @override
  State<AdaptiveSliverModalLayout> createState() =>
      _AdaptiveSliverModalLayoutState();
}

class _AdaptiveSliverModalLayoutState extends State<AdaptiveSliverModalLayout> {
  Size? _layoutSize;
  Size? _reportedSize;
  bool _reportScheduled = false;

  void _recordSize(Size size) {
    _layoutSize = size;
    _scheduleReport();
  }

  void _scheduleReport() {
    if (_reportScheduled ||
        widget.onContentSizeChanged == null ||
        widget.presentation != AdaptiveModalPresentation.dialog) {
      return;
    }
    _reportScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportScheduled = false;
      if (!mounted ||
          _layoutSize == null ||
          widget.onContentSizeChanged == null) {
        return;
      }
      final controller = widget.scrollController;
      final overflow =
          controller.hasClients && controller.position.hasContentDimensions
          ? controller.position.maxScrollExtent
          : 0.0;
      // Include clipped content so a modal-local Navigator can grow again after
      // previously shrinking. Viewport intrinsic measurement is never requested.
      final size = widget.size.constraints.constrain(
        Size(_layoutSize!.width, _layoutSize!.height + overflow),
      );
      if (!size.isFinite || size == _reportedSize) return;
      _reportedSize = size;
      widget.onContentSizeChanged!(size);
    });
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    if (notification.depth == 0) _scheduleReport();
    return false;
  }

  @override
  Widget build(BuildContext context) => _AdaptiveModalFrame(
    presentation: widget.presentation,
    constraints: widget.size.constraints,
    defaultMaxHeight: widget.defaultMaxHeight,
    child: Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: LayoutBuilder(
        builder: (context, constraints) =>
            NotificationListener<ScrollMetricsNotification>(
              onNotification: _onMetrics,
              child: _ModalRegionSize(
                onSize: _recordSize,
                intrinsicWidth: false,
                child: _AdaptiveSliverModalRegions(
                  constraints: constraints,
                  shrinkWrap:
                      widget.presentation == AdaptiveModalPresentation.dialog &&
                      !widget.size.constraints.hasTightHeight,
                  header: widget.header,
                  pinnedBody: widget.pinnedBody,
                  slivers: widget.slivers,
                  bottomActions: widget.bottomActions,
                  padding: widget.padding,
                  footer: widget.footer,
                  scrollController: widget.scrollController,
                ),
              ),
            ),
      ),
    ),
  );
}

class _AdaptiveSliverModalRegions extends StatelessWidget {
  const _AdaptiveSliverModalRegions({
    required this.constraints,
    required this.shrinkWrap,
    required this.header,
    required this.pinnedBody,
    required this.slivers,
    required this.bottomActions,
    required this.padding,
    required this.footer,
    required this.scrollController,
  });
  final BoxConstraints constraints;
  final bool shrinkWrap;
  final Widget? header;
  final Widget? pinnedBody;
  final List<Widget> slivers;
  final List<Widget> bottomActions;
  final EdgeInsetsGeometry padding;
  final Widget? footer;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final compact = AdaptiveModalConstraints.usesCompactHeightLayout(
      context,
      constraints,
    );
    final scrollFooter = compact && View.of(context).viewInsets.bottom > 0;
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
    return Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: [
        ?header,
        if (!compact && pinned != null) pinned,
        Flexible(
          fit: shrinkWrap ? FlexFit.loose : FlexFit.tight,
          key: const ValueKey('adaptive-modal-scroll-region'),
          child: CustomScrollView(
            key: const ValueKey('adaptive-modal-scroll-body'),
            shrinkWrap: shrinkWrap,
            controller: scrollController,
            slivers: [
              if (compact && pinned != null) SliverToBoxAdapter(child: pinned),
              SliverPadding(
                padding: padding,
                sliver: SliverMainAxisGroup(slivers: slivers),
              ),
              if (compact && bottom != null) SliverToBoxAdapter(child: bottom),
              if (scrollFooter && footer != null)
                SliverToBoxAdapter(child: footer),
            ],
          ),
        ),
        if (!compact && bottom != null) bottom,
        if (!scrollFooter && footer != null)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: SingleChildScrollView(child: footer),
          ),
      ],
    );
  }
}
