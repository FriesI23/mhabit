// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

import '../../common/consts.dart';
import '../../common/utils.dart';
import 'enhanced_safe_area.dart';

/// Shows an adaptive content sheet or dialog based on screen size.
///
/// The scaffold handles the platform decision, [title] (fixed top), scroll
/// wrapping, actions, and a close button.  [contentBuilder] builds the inner
/// content identically in both modes — it should not include its own scroll
/// view.
///
/// [pinnedContentBuilder] renders between [title] and the scrollable
/// [contentBuilder] area without scrolling.  Use it for search bars,
/// filter chips, or other controls that should stay visible while the
/// content scrolls.
///
/// On Android, iOS, and Fuchsia, dialog mode is used only when
/// [computeLayoutType] resolves a large layout with both the width and height
/// thresholds enabled. Otherwise this uses [showModalBottomSheet] with a
/// [DraggableScrollableSheet]. On other platforms, this always uses
/// [showDialog] with an [AlertDialog].
///
/// [actions] are placed in a bottom area (sheet) or appended before the
/// default close button in [AlertDialog.actions] (dialog).
/// [showCloseButton] controls the default
/// close button.  [sheetActionsAlign] and [sheetTitleAlignment] control
/// layout in the sheet scaffold.
///
/// [builder] wraps the sheet/dialog and receives `(context, buildBody)` where
/// [buildBody] is a [WidgetBuilder] that constructs the full body (title +
/// content + actions) using the context it receives.  The builder controls
/// *when* [buildBody] is called — typically inside a [Provider] scope so that
/// [contentBuilder] and [actionsBuilder] have access to the Provider tree.
///
/// Mode‑specific parameters use `sheet*` / `dialog*` prefixes.
Future<T?> showAdaptiveContentSheet<T>({
  required BuildContext context,
  required WidgetBuilder contentBuilder,
  Widget Function(BuildContext context, WidgetBuilder buildBody)? builder,
  WidgetBuilder? pinnedContentBuilder,
  Widget? title,
  List<Widget>? actions,
  List<Widget> Function(BuildContext context, bool isDialog)? actionsBuilder,
  bool showCloseButton = true,
  bool? sheetShowCloseButton,
  // Sheet scaffold
  double sheetInitialChildSize = 0.6,
  double sheetMinChildSize = 0.25,
  double sheetMaxChildSize = 0.95,
  bool sheetShowDragHandle = true,
  ScrollPhysics? sheetScrollPhysics,
  EdgeInsetsGeometry? sheetPadding,
  AlignmentGeometry sheetActionsAlign = AlignmentDirectional.centerEnd,
  AlignmentGeometry sheetTitleAlignment = Alignment.centerLeft,
  // Dialog scaffold
  double? dialogWidth = 500,
  double dialogMaxContentHeight = 400,
  bool dialogShowScrollbar = true,
  // Force mode — assert that only one is true
  bool forceSheet = false,
  bool forceDialog = false,
}) {
  assert(
    0 <= sheetMinChildSize &&
        sheetMinChildSize <= sheetInitialChildSize &&
        sheetInitialChildSize <= sheetMaxChildSize &&
        sheetMaxChildSize <= 1,
    'sheet child sizes must satisfy 0 <= min <= initial <= max <= 1',
  );
  assert(
    !(forceSheet && forceDialog),
    'forceSheet and forceDialog cannot both be true',
  );

  final viewSize = MediaQuery.sizeOf(context);
  final appLayoutType = computeLayoutType(
    width: viewSize.width,
    height: viewSize.height,
    largeScreenWidth: kHabitLargeScreenAdaptWidth,
    largeScreenHeight: kHabitLargeScreenAdaptHeight,
    ignoreHeight: false,
    defaultType: UiLayoutType.s,
  );

  final useDialog = forceDialog
      ? true
      : forceSheet
      ? false
      : switch (defaultTargetPlatform) {
          TargetPlatform.android ||
          TargetPlatform.iOS ||
          TargetPlatform.fuchsia => appLayoutType == UiLayoutType.l,
          _ => true,
        };

  final resolvedBuilder = builder;

  Widget buildBody(BuildContext ctx) {
    final bodyActions = actionsBuilder?.call(ctx, useDialog) ?? actions;
    return switch (useDialog) {
      true => _AdaptiveAlertDialog(
        title: title,
        width: dialogWidth,
        maxContentHeight: dialogMaxContentHeight,
        showScrollbar: dialogShowScrollbar,
        showCloseButton: showCloseButton,
        actions: bodyActions,
        pinnedContentBuilder: pinnedContentBuilder,
        child: contentBuilder(ctx),
      ),
      false => _AdaptiveSheet(
        title: title,
        initialChildSize: sheetInitialChildSize,
        minChildSize: sheetMinChildSize,
        maxChildSize: sheetMaxChildSize,
        scrollPhysics: sheetScrollPhysics,
        padding: sheetPadding,
        sheetShowCloseButton: sheetShowCloseButton ?? showCloseButton,
        actions: bodyActions,
        actionsAlign: sheetActionsAlign,
        titleAlignment: sheetTitleAlignment,
        pinnedContentBuilder: pinnedContentBuilder,
        child: contentBuilder(ctx),
      ),
    };
  }

  return switch (useDialog) {
    true => showDialog<T>(
      context: context,
      builder: (ctx) => resolvedBuilder != null
          ? resolvedBuilder(ctx, buildBody)
          : buildBody(ctx),
    ),
    false => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: sheetShowDragHandle,
      builder: (ctx) => resolvedBuilder != null
          ? resolvedBuilder(ctx, buildBody)
          : buildBody(ctx),
    ),
  };
}

class _AdaptiveSheet extends StatelessWidget {
  final Widget? title;
  final Widget child;
  final WidgetBuilder? pinnedContentBuilder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final ScrollPhysics? scrollPhysics;
  final EdgeInsetsGeometry? padding;
  final bool sheetShowCloseButton;
  final List<Widget>? actions;
  final AlignmentGeometry actionsAlign;
  final AlignmentGeometry titleAlignment;

  const _AdaptiveSheet({
    required this.title,
    required this.child,
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
    this.scrollPhysics,
    this.padding,
    this.sheetShowCloseButton = true,
    this.actions,
    this.actionsAlign = Alignment.center,
    this.titleAlignment = Alignment.centerLeft,
    this.pinnedContentBuilder,
  });

  bool get _hasActions =>
      sheetShowCloseButton || (actions?.isNotEmpty ?? false);

  bool get _hasPinnedContent => pinnedContentBuilder != null;

  @override
  Widget build(BuildContext context) {
    final sheetPadding = padding ?? const EdgeInsets.symmetric(horizontal: 20);
    final sheetPhysics = scrollPhysics ?? const AlwaysScrollableScrollPhysics();
    final resolvedSheetPadding = sheetPadding.resolve(
      Directionality.of(context),
    );
    final actionsPadding = EdgeInsets.only(
      left: resolvedSheetPadding.left,
      right: resolvedSheetPadding.right,
      top: 8,
      bottom: 8,
    );

    Widget buildTitle() {
      if (title == null) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: titleAlignment, child: title!),
          const SizedBox(height: 12),
        ],
      );
    }

    Widget buildCloseButton() {
      return TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(MaterialLocalizations.of(context).closeButtonLabel),
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (_, scrollController) {
        if (!_hasActions && !_hasPinnedContent) {
          return Padding(
            padding: sheetPadding,
            child: SingleChildScrollView(
              controller: scrollController,
              physics: sheetPhysics,
              child: EnhancedSafeArea.only(
                bottom: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [buildTitle(), child],
                ),
              ),
            ),
          );
        }

        final pinnedWidget = _hasPinnedContent
            ? Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: pinnedContentBuilder!(context),
              )
            : null;

        return EnhancedSafeArea.only(
          bottom: true,
          child: Padding(
            padding: sheetPadding,
            child: Column(
              children: [
                buildTitle(),
                ?pinnedWidget,
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: sheetPhysics,
                    child: child,
                  ),
                ),
                if (_hasActions)
                  Padding(
                    padding: actionsPadding,
                    child: Align(
                      alignment: actionsAlign,
                      child: OverflowBar(
                        alignment: MainAxisAlignment.end,
                        spacing: 8,
                        overflowAlignment: OverflowBarAlignment.end,
                        children: [
                          if (actions != null) ...actions!,
                          if (sheetShowCloseButton) buildCloseButton(),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdaptiveAlertDialog extends StatefulWidget {
  final Widget? title;
  final Widget child;
  final WidgetBuilder? pinnedContentBuilder;
  final double? width;
  final double maxContentHeight;
  final bool showScrollbar;
  final bool showCloseButton;
  final List<Widget>? actions;

  const _AdaptiveAlertDialog({
    required this.title,
    required this.child,
    this.width,
    required this.maxContentHeight,
    required this.showScrollbar,
    this.showCloseButton = true,
    this.actions,
    this.pinnedContentBuilder,
  });

  @override
  State<_AdaptiveAlertDialog> createState() => _AdaptiveAlertDialogState();
}

class _AdaptiveAlertDialogState extends State<_AdaptiveAlertDialog> {
  late final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrolledChild = SingleChildScrollView(
      controller: _scrollController,
      child: widget.child,
    );

    Widget buildContentArea() {
      final pinned = widget.pinnedContentBuilder?.call(context);
      final scrollable = widget.showScrollbar
          ? Scrollbar(controller: _scrollController, child: scrolledChild)
          : scrolledChild;

      if (pinned == null) return scrollable;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          pinned,
          Flexible(child: scrollable),
        ],
      );
    }

    final contentArea = buildContentArea();

    return AlertDialog(
      title: widget.title,
      content: widget.width != null
          ? SizedBox(
              width: widget.width,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: widget.maxContentHeight),
                child: contentArea,
              ),
            )
          : ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxContentHeight),
              child: contentArea,
            ),
      actions: [
        if (widget.actions != null) ...widget.actions!,
        if (widget.showCloseButton)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          ),
      ],
    );
  }
}
