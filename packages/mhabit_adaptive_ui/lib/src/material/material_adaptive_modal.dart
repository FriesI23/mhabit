import 'package:flutter/material.dart';

import '../adaptive/adaptive_app_bar.dart';
import '../adaptive/adaptive_modal_layout.dart';
import '../window_control/modal_app_bar_region.dart';

extension _MaterialAdaptiveModalThemeData on ThemeData {
  Color get adaptiveModalBackgroundColor =>
      dialogTheme.backgroundColor ?? colorScheme.surfaceContainerHigh;
}

/// Displays a Material modal whose surface can change with the window size.
///
/// The route remains installed while [presentationResolver] selects its
/// current presentation. This preserves the state built by [builder] when a
/// resize changes the surface between a bottom sheet and a dialog.
///
/// ```text
/// compact or short      medium and larger
/// ┌──────────────┐      ┌──────────────┐
/// │              │      │  ┌────────┐  │
/// │   sheet  ↑   │      │  │ dialog │  │
/// └──────────────┘      │  └────────┘  │
///                       └──────────────┘
/// ```
///
/// The returned future completes with the value passed to [Navigator.pop]
/// when the modal is closed. Set [useRootNavigator] to false to push onto the
/// nearest navigator instead of the root navigator.
Future<T?> showMaterialAdaptiveModalRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required AdaptiveModalPresentation Function(BuildContext context)
  presentationResolver,
  required bool useRootNavigator,
  required RouteSettings? routeSettings,
  required String barrierLabel,
}) => showGeneralDialog<T>(
  context: context,
  useRootNavigator: useRootNavigator,
  barrierDismissible: false,
  barrierLabel: barrierLabel,
  barrierColor: Colors.black54,
  routeSettings: routeSettings,
  transitionDuration: const Duration(milliseconds: 300),
  transitionBuilder: (context, animation, _, child) =>
      switch (presentationResolver(context)) {
        AdaptiveModalPresentation.dialog => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
          child: child,
        ),
        AdaptiveModalPresentation.sheet => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              ),
          child: child,
        ),
      },
  pageBuilder: (context, _, _) => builder(context),
);

/// Displays a fixed Material dialog above the current contents of the app.
///
/// This delegates route creation and transition ownership to [showDialog] and
/// only supplies the adaptive modal surface around [builder].
///
/// ```text
/// ┌────────────────┐
/// │   ┌────────┐   │
/// │   │ dialog │   │
/// │   └────────┘   │
/// └────────────────┘
/// ```
///
/// The returned future completes with the value passed to [Navigator.pop]
/// when the dialog is closed. [barrierDismissible] controls whether tapping
/// the modal barrier requests dismissal.
///
/// See also:
///
///  * [showMaterialAdaptiveModalRoute], which keeps one route while switching
///    between sheet and dialog presentations as the window size changes.
Future<T?> showMaterialAdaptiveDialogRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required bool useRootNavigator,
  required bool barrierDismissible,
  required RouteSettings? routeSettings,
}) => showDialog<T>(
  context: context,
  useRootNavigator: useRootNavigator,
  barrierDismissible: barrierDismissible,
  routeSettings: routeSettings,
  builder: (context) =>
      MaterialAdaptiveModalDialogSurface(child: builder(context)),
);

/// Displays a fixed Material modal bottom sheet.
///
/// This delegates route creation, drag handling, and animation-controller
/// ownership to [showModalBottomSheet]. The controller passed to [builder]
/// coordinates the sheet with its primary scrollable content.
///
/// ```text
/// ┌────────────────┐
/// │                │
/// │ ┌────────────┐ │
/// │ │  sheet  ↑  │ │
/// └─┴────────────┴─┘
/// ```
///
/// The returned future completes with the value passed to [Navigator.pop]
/// when the sheet is closed. [enableDrag] and [showDragHandle] configure the
/// corresponding Material bottom-sheet behavior.
///
/// See also:
///
///  * [showMaterialAdaptiveModalRoute], which keeps one route while switching
///    between sheet and dialog presentations as the window size changes.
Future<T?> showMaterialAdaptiveSheetRoute<T>({
  required BuildContext context,
  required Widget Function(ScrollController controller) builder,
  required bool useRootNavigator,
  required bool barrierDismissible,
  required bool enableDrag,
  required bool showDragHandle,
  required RouteSettings? routeSettings,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: useRootNavigator,
  isDismissible: barrierDismissible,
  enableDrag: enableDrag,
  isScrollControlled: true,
  useSafeArea: false,
  showDragHandle: showDragHandle,
  backgroundColor: Theme.of(context).adaptiveModalBackgroundColor,
  routeSettings: routeSettings,
  builder: (context) => _MaterialAdaptiveSheetRouteContent(builder: builder),
);

class _MaterialAdaptiveSheetRouteContent extends StatefulWidget {
  const _MaterialAdaptiveSheetRouteContent({required this.builder});

  final Widget Function(ScrollController controller) builder;

  @override
  State<_MaterialAdaptiveSheetRouteContent> createState() =>
      _MaterialAdaptiveSheetRouteContentState();
}

class _MaterialAdaptiveSheetRouteContentState
    extends State<_MaterialAdaptiveSheetRouteContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ModalWindowControlMotion(
    notifier: ModalRoute.of(context)?.animation ?? kAlwaysDismissedAnimation,
    child: SizedBox(
      height: AdaptiveModalConstraints.maximumHeightOf(context),
      child: widget.builder(_scrollController),
    ),
  );
}

/// M3 dialog surface shared by fixed and automatically responsive routes.
class MaterialAdaptiveModalDialogSurface extends StatelessWidget {
  const MaterialAdaptiveModalDialogSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Theme.of(context).adaptiveModalBackgroundColor,
    clipBehavior: Clip.antiAlias,
    shape:
        DialogTheme.of(context).shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
    child: child,
  );
}

/// Material route surface used by automatically responsive modals.
class MaterialAdaptiveModalRouteSurface extends StatefulWidget {
  const MaterialAdaptiveModalRouteSurface({
    super.key,
    required this.presentation,
    required this.enableDrag,
    required this.showDragHandle,
    required this.onCloseRequested,
    required this.contentBuilder,
  });

  final AdaptiveModalPresentation presentation;
  final bool enableDrag;
  final bool showDragHandle;
  final VoidCallback onCloseRequested;
  final Widget Function(ScrollController? controller) contentBuilder;

  @override
  State<MaterialAdaptiveModalRouteSurface> createState() =>
      _MaterialAdaptiveModalRouteSurfaceState();
}

class _MaterialAdaptiveModalRouteSurfaceState
    extends State<MaterialAdaptiveModalRouteSurface> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxExtent = AdaptiveModalConstraints.maximumSheetExtentOf(context);
    final surface = switch ((widget.presentation, widget.enableDrag)) {
      (AdaptiveModalPresentation.dialog, _) => Center(
        child: MaterialAdaptiveModalDialogSurface(
          child: widget.contentBuilder(null),
        ),
      ),
      (AdaptiveModalPresentation.sheet, false) => Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: maxExtent,
          child: _buildSheet(null),
        ),
      ),
      (AdaptiveModalPresentation.sheet, true) => Align(
        alignment: Alignment.bottomCenter,
        child: NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            if (notification.extent <= notification.minExtent) {
              widget.onCloseRequested();
            }
            return false;
          },
          child: DraggableScrollableSheet(
            controller: _sheetController,
            expand: false,
            initialChildSize: maxExtent,
            minChildSize: AdaptiveModalConstraints.minSheetExtent,
            maxChildSize: maxExtent,
            snap: true,
            builder: (_, controller) => _buildSheet(controller),
          ),
        ),
      ),
    };
    return ModalWindowControlMotion(notifier: _sheetController, child: surface);
  }

  Widget _buildSheet(ScrollController? controller) {
    final theme = Theme.of(context);
    final dragHandleSize =
        theme.bottomSheetTheme.dragHandleSize ?? const Size(32, 4);
    final dragHandleColor =
        theme.bottomSheetTheme.dragHandleColor ??
        theme.colorScheme.onSurfaceVariant;
    return Material(
      color: Theme.of(context).adaptiveModalBackgroundColor,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Column(
        children: [
          if (widget.showDragHandle)
            SizedBox(
              height: 24,
              child: Center(
                child: SizedBox(
                  width: dragHandleSize.width,
                  height: dragHandleSize.height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: dragHandleColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(dragHandleSize.height / 2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(child: widget.contentBuilder(controller)),
        ],
      ),
    );
  }
}

/// Material implementation of adaptive modal content.
class MaterialAdaptiveModal extends StatelessWidget {
  const MaterialAdaptiveModal({
    super.key,
    required this.title,
    required this.leadingAction,
    required this.actions,
    required this.pinnedBody,
    required this.body,
    required this.bottomActions,
    required this.automaticallyImplyCloseButton,
    required this.onCloseRequested,
    required this.constraints,
    required this.presentation,
    required this.scrollController,
  });

  final Widget? title;
  final Widget? leadingAction;
  final List<Widget> actions;
  final Widget? pinnedBody;
  final Widget body;
  final List<Widget> bottomActions;
  final bool automaticallyImplyCloseButton;
  final VoidCallback onCloseRequested;
  final BoxConstraints? constraints;
  final AdaptiveModalPresentation presentation;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).adaptiveModalBackgroundColor;
    final header = AppBarTheme(
      data: AppBarTheme.of(context).copyWith(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      child: ModalWindowControlAppBarRegion(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: AdaptiveAppBar.material(
            key: const ValueKey('adaptive-modal-app-bar'),
            leading: leadingAction,
            title: title == null
                ? const SizedBox.shrink()
                : KeyedSubtree(
                    key: const ValueKey('adaptive-modal-title'),
                    child: title!,
                  ),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
    );
    final impliedClose = automaticallyImplyCloseButton
        ? TextButton(
            key: const ValueKey('adaptive-modal-implied-close'),
            onPressed: onCloseRequested,
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          )
        : null;
    final hasFooter = actions.isNotEmpty || impliedClose != null;
    final actionPadding = switch (presentation) {
      AdaptiveModalPresentation.sheet => const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        8,
      ),
      AdaptiveModalPresentation.dialog => const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24,
      ),
    };
    final footer = !hasFooter
        ? null
        : Padding(
            key: const ValueKey('adaptive-modal-actions'),
            padding: actionPadding,
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              overflowAlignment: OverflowBarAlignment.end,
              spacing: 8,
              overflowSpacing: 8,
              children: [...actions, ?impliedClose],
            ),
          );

    return Material(
      color: backgroundColor,
      child: AdaptiveModalLayout(
        header: header,
        footer: footer,
        pinnedBody: pinnedBody,
        body: body,
        bottomActions: bottomActions,
        scrollController: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        presentation: presentation,
        constraints: constraints,
      ),
    );
  }
}
