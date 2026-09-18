import 'package:flutter/widgets.dart';

import 'adaptive_modal_layout.dart';
import 'adaptive_sheet.dart' show AdaptiveModalSize;

/// Platform chrome supplies layout inputs without knowing the content format.
class AdaptiveModalLayoutScope extends InheritedWidget {
  const AdaptiveModalLayoutScope({
    super.key,
    required this.scrollController,
    this.header,
    required this.pinnedBody,
    required this.contentTopInset,
    required this.bottomActions,
    required this.padding,
    required this.presentation,
    required this.size,
    this.defaultMaxHeight,
    this.footer,
    this.onContentSizeChanged,
    required super.child,
  });

  final ScrollController scrollController;
  final Widget? header;
  final Widget? pinnedBody;
  final double contentTopInset;
  final List<Widget> bottomActions;
  final EdgeInsetsGeometry padding;
  final AdaptiveModalPresentation presentation;
  final AdaptiveModalSize size;
  final double? defaultMaxHeight;
  final Widget? footer;
  final ValueChanged<Size>? onContentSizeChanged;

  static AdaptiveModalLayoutScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdaptiveModalLayoutScope>()!;

  @override
  bool updateShouldNotify(AdaptiveModalLayoutScope oldWidget) =>
      scrollController != oldWidget.scrollController ||
      header != oldWidget.header ||
      pinnedBody != oldWidget.pinnedBody ||
      contentTopInset != oldWidget.contentTopInset ||
      bottomActions != oldWidget.bottomActions ||
      padding != oldWidget.padding ||
      presentation != oldWidget.presentation ||
      size != oldWidget.size ||
      defaultMaxHeight != oldWidget.defaultMaxHeight ||
      footer != oldWidget.footer ||
      onContentSizeChanged != oldWidget.onContentSizeChanged;
}

/// Box content exclusively uses intrinsic content measurement and box scrolling.
class AdaptiveModalBoxContent extends StatelessWidget {
  const AdaptiveModalBoxContent({super.key, required this.body});
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final layout = AdaptiveModalLayoutScope.of(context);
    return AdaptiveModalLayout(
      header: layout.header,
      pinnedBody: layout.pinnedBody,
      body: Padding(
        padding: EdgeInsets.only(top: layout.contentTopInset),
        child: body,
      ),
      bottomActions: layout.bottomActions,
      padding: layout.padding,
      scrollController: layout.scrollController,
      presentation: layout.presentation,
      size: layout.size,
      defaultMaxHeight: layout.defaultMaxHeight,
      footer: layout.footer,
      onContentSizeChanged: layout.onContentSizeChanged,
    );
  }
}

/// Sliver content exclusively uses a bounded viewport and native sliver layout.
class AdaptiveModalSliverContent extends StatelessWidget {
  const AdaptiveModalSliverContent({super.key, required this.slivers});
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    final layout = AdaptiveModalLayoutScope.of(context);
    return AdaptiveSliverModalLayout(
      header: layout.header,
      pinnedBody: layout.pinnedBody,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: layout.contentTopInset),
          sliver: SliverMainAxisGroup(slivers: slivers),
        ),
      ],
      bottomActions: layout.bottomActions,
      padding: layout.padding,
      scrollController: layout.scrollController,
      presentation: layout.presentation,
      size: layout.size,
      defaultMaxHeight: layout.defaultMaxHeight,
      footer: layout.footer,
      onContentSizeChanged: layout.onContentSizeChanged,
    );
  }
}
