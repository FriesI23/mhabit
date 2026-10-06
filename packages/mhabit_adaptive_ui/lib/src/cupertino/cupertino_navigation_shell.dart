import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart'
    hide AdaptiveNavigationDestination, NavigationDestinationIcons;

import '../adaptive/adaptive_navigation_destination.dart';
import '../breakpoints/window_size_class.dart';
import '../shell/navigation_scroll_wish_policy.dart';
import '../shell/navigation_shell_form.dart';
import '../shell/navigation_shell_frame.dart';
import '../shell/sidebar_adapter.dart';
import '../window_control/window_control_layout.dart';
import 'apple_sidebar_style.dart';
import 'cupertino_adaptive_navigation_bar.dart';
import 'cupertino_floating_surface.dart';
import 'cupertino_navigation_primary_action.dart';
import 'cupertino_neutral_button.dart';

/// Composes the Cupertino renderers around style-neutral shell mechanics.
///
/// Forms use the height-constrained layout class resolved by [WindowSize].
/// Compact height uses the Tab Bar regardless of width or platform.
///
/// ```text
/// compact          constrained side  expanded side
/// +----------+     +------------+    +------+-------+
/// | top bar  |     |  top bar   |    | side |content|
/// | content  |     |  content   |    | bar  |       |
/// +----------+     +------------+    |      |       |
/// | Tab Bar  |                       +------+-------+
/// +----------+
/// ```
///
/// Medium widths default to the collapsed top-bar presentation; large widths
/// default to the beside Sidebar. In compact form, route and contextual state
/// control visibility while scroll direction selects the expanded or
/// minimized Tab Bar presentation.
class CupertinoNavigationShell extends StatefulWidget {
  /// Creates Cupertino navigation chrome around [child].
  const CupertinoNavigationShell({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.auxiliaryDestinations,
    required this.selectedAuxiliaryIndex,
    required this.onAuxiliaryDestinationSelected,
    required this.compactRouteVisible,
    required this.contextualChromeSuppressed,
    required this.primaryAction,
    required this.sideNavigationExtent,
    required this.dragHandleBuilder,
    required this.appleBarStyle,
    required this.sidebarStyle,
    required this.collapsedSidebarEnabled,
    required this.sidebarBackgroundColor,
    required this.sidebarItemStyle,
    required this.collapsedSidebarItemStyle,
    this.expandNavigationLabel,
    this.collapseNavigationLabel,
  });

  /// Content displayed beside or underneath the navigation chrome.
  final Widget child;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Top-level destinations rendered by Cupertino navigation chrome.
  final List<AdaptiveNavigationDestination> destinations;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavigationDestination> auxiliaryDestinations;
  final int? selectedAuxiliaryIndex;
  final ValueChanged<int>? onAuxiliaryDestinationSelected;

  /// Whether route structure allows compact navigation to be shown.
  final bool compactRouteVisible;

  /// Whether contextual commands suppress compact navigation chrome.
  final bool contextualChromeSuppressed;

  /// App-selected primary action for the active branch.
  final CupertinoNavigationPrimaryAction? primaryAction;

  /// Full-width policy used by the Sidebar panel.
  final SideNavigationExtent sideNavigationExtent;

  /// Optional visual displayed inside the Sidebar resize target.
  final SideNavigationDragHandleBuilder? dragHandleBuilder;

  /// Geometry and spacing for the compact Apple navigation bar.
  final AppleNavigationBarStyle appleBarStyle;

  /// Visual treatment for the medium-and-larger Sidebar.
  final AppleSidebarStyle sidebarStyle;

  /// Whether a hidden Sidebar exposes destinations in the top toolbar.
  final bool collapsedSidebarEnabled;

  /// Optional fill override used only by the edge Sidebar presentation.
  final Color? sidebarBackgroundColor;

  /// Optional destination colors used only by the edge Sidebar.
  final CupertinoSidebarItemStyle? sidebarItemStyle;

  /// Optional destination colors used only by the collapsed edge Sidebar.
  final CupertinoSidebarItemStyle? collapsedSidebarItemStyle;

  /// Localized action label used when the Sidebar can be shown.
  ///
  /// Defaults to the closest available Flutter localization.
  final String? expandNavigationLabel;

  /// Localized action label used when the Sidebar can be hidden.
  ///
  /// Defaults to the closest available Flutter localization.
  final String? collapseNavigationLabel;

  @override
  State<CupertinoNavigationShell> createState() =>
      _CupertinoNavigationShellState();
}

class _CupertinoNavigationShellState extends State<CupertinoNavigationShell> {
  final AdaptiveNavigationController _controller =
      AdaptiveNavigationController();
  final CupertinoSidebarCollapsedBarController _collapsedBarController =
      CupertinoSidebarCollapsedBarController();
  bool _sidebarExpanded = true;
  NavigationShellForm? _automaticForm;
  bool? _compactRetainedExpanded;
  bool _syncingAutomaticForm = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleSidebarChanged);
  }

  void _handleSidebarChanged() {
    final expanded = _controller.expanded;
    if (expanded == _sidebarExpanded) return;
    if (_syncingAutomaticForm) {
      _sidebarExpanded = expanded;
      return;
    }
    if (!mounted) return;
    setState(() => _sidebarExpanded = expanded);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final form = _resolveForm(WindowSize.of(context));
    if (form == _automaticForm) return;
    final previousForm = _automaticForm;
    _automaticForm = form;
    if (form == NavigationShellForm.compact) {
      if (previousForm != null && previousForm != NavigationShellForm.compact) {
        _compactRetainedExpanded = _controller.expanded;
      }
      return;
    }

    final expanded =
        previousForm == NavigationShellForm.compact &&
            _compactRetainedExpanded != null
        ? _compactRetainedExpanded!
        : form == NavigationShellForm.expandedSide;
    _compactRetainedExpanded = null;
    _syncingAutomaticForm = true;
    _controller.expanded = expanded;
    _sidebarExpanded = expanded;
    _syncingAutomaticForm = false;
  }

  NavigationShellForm _resolveForm(WindowSize windowSize) =>
      switch (windowSize.width) {
        WindowSizeClass.compact => NavigationShellForm.compact,
        WindowSizeClass.medium => NavigationShellForm.constrainedSide,
        WindowSizeClass.expanded ||
        WindowSizeClass.large ||
        WindowSizeClass.extraLarge => NavigationShellForm.expandedSide,
      };

  WindowControlLayoutOwner _resolveWindowControlOwner(
    NavigationShellForm form,
  ) => switch (form) {
    NavigationShellForm.compact => WindowControlLayoutOwner.appBar,
    NavigationShellForm.constrainedSide ||
    NavigationShellForm.expandedSide => WindowControlLayoutOwner.sideNavigation,
  };

  @override
  void dispose() {
    _controller.removeListener(_handleSidebarChanged);
    _controller.dispose();
    _collapsedBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widget = this.widget;
    final toolbarGeometry = CupertinoSidebarPresentationScope.toolbarGeometryOf(
      context,
    );
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    // Match the actual Material Scaffold surface during ThemeData animation.
    // CupertinoThemeData switches brightness discretely at the midpoint,
    // which otherwise makes an idle automatic navigation bar flash between
    // its light and dark scaffold colors while the page keeps interpolating.
    final scaffoldBackground = Theme.of(context).colorScheme.surface;
    return NavigationShellFrame(
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: widget.onDestinationSelected,
      compactRouteVisible: widget.compactRouteVisible,
      contextualChromeSuppressed: widget.contextualChromeSuppressed,
      barHeight: CupertinoAdaptiveNavigationBar.contentHeight,
      navHeight: CupertinoAdaptiveNavigationBar.heightOf(
        context,
        floatingBottomMargin: widget.appleBarStyle.floatingBottomMargin,
      ),
      keepVisibleOnScroll: true,
      scrollWishPolicy: const NavigationScrollWishPolicy.flingThreshold(
        distanceFactor: 1.5,
        velocityFactor: 1.5,
      ),
      switchDuration: disableAnimations
          ? Duration.zero
          : navigationShellAnimationDuration,
      formResolver: _resolveForm,
      bodyBuilder: (context, form, onSelected, child) {
        if (form == NavigationShellForm.compact) return child;

        final adapter = SidebarNavigationAdapter(
          destinations: widget.destinations,
          auxiliaryDestinations: widget.auxiliaryDestinations,
          selectedIndex: widget.selectedIndex,
          selectedAuxiliaryIndex: widget.selectedAuxiliaryIndex,
          onDestinationSelected: onSelected,
          onAuxiliaryDestinationSelected: widget.onAuxiliaryDestinationSelected,
        );
        final sidebarContent = CupertinoSidebarContentSafeArea(
          child: CupertinoSidebarNavigation(
            destinations: adapter.destinations,
            selection: adapter.selection,
            onSelectionChanged: adapter.select,
            auxiliaryDestinations: adapter.auxiliaryDestinations,
            itemStyle: switch (widget.sidebarStyle) {
              AppleSidebarStyle.inset => null,
              AppleSidebarStyle.edge => widget.sidebarItemStyle,
            },
          ),
        );
        final collapsedBar = CupertinoSidebarCollapsedBar(
          key: const ValueKey('cupertino-sidebar-collapsed-bar'),
          destinations: adapter.destinations,
          selectedIndex: widget.selectedAuxiliaryIndex == null
              ? widget.selectedIndex
              : null,
          onDestinationSelected: (index) =>
              adapter.select(SidebarPrimarySelection(index)),
          height: toolbarGeometry.collapsedBarHeight,
          itemStyle: switch (widget.sidebarStyle) {
            AppleSidebarStyle.inset => null,
            AppleSidebarStyle.edge => widget.collapsedSidebarItemStyle,
          },
        );
        final branch = CupertinoSidebarPresentationScope(
          expanded: _sidebarExpanded,
          collapsedBarController: _collapsedBarController,
          toolbarGeometry: toolbarGeometry,
          child: child,
        );
        final sidebar = switch (widget.sidebarStyle) {
          AppleSidebarStyle.inset => CupertinoSidebar(
            controller: _controller,
            content: sidebarContent,
            collapsedBar: widget.collapsedSidebarEnabled ? collapsedBar : null,
            collapsedBarController: _collapsedBarController,
            collapsedBarPlacement:
                CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
            toolbarGeometry: toolbarGeometry,
            extent: widget.sideNavigationExtent,
            dragHandleBuilder: widget.dragHandleBuilder,
            expandLabel: widget.expandNavigationLabel,
            collapseLabel: widget.collapseNavigationLabel,
            toggleButtonBuilder: (context, defaultBuilder) =>
                NeutralCupertinoButtonBuilder(builder: defaultBuilder),
            scaffoldBackgroundColor: scaffoldBackground,
            child: branch,
          ),
          AppleSidebarStyle.edge => CupertinoSidebar.edge(
            controller: _controller,
            content: sidebarContent,
            collapsedBar: widget.collapsedSidebarEnabled ? collapsedBar : null,
            collapsedBarController: _collapsedBarController,
            collapsedBarPlacement:
                CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
            toolbarGeometry: toolbarGeometry,
            extent: widget.sideNavigationExtent,
            dragHandleBuilder: widget.dragHandleBuilder,
            expandLabel: widget.expandNavigationLabel,
            collapseLabel: widget.collapseNavigationLabel,
            toggleButtonBuilder: (context, defaultBuilder) =>
                NeutralCupertinoButtonBuilder(builder: defaultBuilder),
            backgroundColor: widget.sidebarBackgroundColor,
            scaffoldBackgroundColor: scaffoldBackground,
            child: branch,
          ),
        };
        return NavigationObstructionScope(
          obstruction: context.sidebarNavigationObstruction,
          child: sidebar,
        );
      },
      windowControlOwnerResolver: _resolveWindowControlOwner,
      compactNavigationBuilder: _buildCompactNavigation,
      floatingActionButtonBuilder: (context, state) =>
          CupertinoNavigationPrimaryActionHost(
            action: widget.primaryAction,
            scrollWish: state.scrollWish,
            visibility: state.visible,
            compact: state.form == NavigationShellForm.compact,
            routeVisible: widget.compactRouteVisible,
          ),
      floatingActionButtonLocation:
          CupertinoNavigationPrimaryActionButton.floatingLocationOf(context),
      child: CupertinoPageScaffoldBackgroundColor(
        color: scaffoldBackground,
        child: widget.child,
      ),
    );
  }

  Widget _buildCompactNavigation(
    BuildContext context,
    NavigationShellChromeState state,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: state.scrollWish,
      builder: (context, scrollWish, child) =>
          CompactNavigationChromeTransition(
            visibility: state.visible,
            collapseLayout: true,
            topClipOverflow: CupertinoFloatingGlassSurface.shadowClipOverflow,
            child: CupertinoAdaptiveNavigationBar(
              selectedIndex: widget.selectedIndex,
              presentation: scrollWish
                  ? AdaptiveNavigationBarPresentation.expanded
                  : AdaptiveNavigationBarPresentation.minimized,
              onExpandRequested: () => state.reportScrollWish(true),
              reservePrimaryActionSpace: widget.primaryAction != null,
              expandedNavigationWidth:
                  widget.appleBarStyle.expandedNavigationWidth,
              floatingBottomMargin: widget.appleBarStyle.floatingBottomMargin,
              destinations: widget.destinations,
              onDestinationSelected: state.onDestinationSelected,
            ),
          ),
    );
  }
}
