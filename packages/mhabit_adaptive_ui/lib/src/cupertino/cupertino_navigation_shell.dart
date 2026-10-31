import 'dart:math' as math;

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
import '../shell/sidebar_collapse_memory.dart';
import '../shell/sidebar_expansion_controller.dart';
import '../window_control/interaction_region.dart';
import '../window_control/occlusion_layout.dart';
import '../window_control/occlusion_toolbar.dart';
import '../window_control/toolbar_geometry.dart';
import '../window_control/window_control_layout.dart';
import 'apple_sidebar_style.dart';
import 'cupertino_adaptive_navigation_bar.dart';
import 'cupertino_floating_surface.dart';
import 'cupertino_navigation_primary_action.dart';
import 'cupertino_neutral_button.dart';

/// Resolves a candidate top-toolbar region for a declared full-view Sidebar.
abstract interface class SidebarTopToolbarRegionResolver {
  const factory SidebarTopToolbarRegionResolver({
    required AdaptiveOcclusionScope? occlusionScope,
    required Rect? viewportBounds,
    required Size viewSize,
    required BoxConstraints constraints,
    required MediaQueryData media,
    required CupertinoSidebarToolbarGeometry toolbarGeometry,
    required bool collapsedBarEnabled,
  }) = _SidebarTopToolbarRegionResolver;

  CupertinoSidebarToolbarRegion? resolve();
}

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
/// default to the beside Sidebar. An explicit collapse overrides that default
/// until the user expands. In compact form, route and contextual state
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
    this.sidebarToolbarGeometry,
    required this.collapsedSidebarEnabled,
    required this.sidebarBackgroundColor,
    required this.sidebarItemStyle,
    required this.collapsedSidebarItemStyle,
    this.expandNavigationLabel,
    this.collapseNavigationLabel,
    this.collapseMemory,
  });

  /// Shared runtime collapse preference; null keeps local renderer memory.
  final SidebarCollapseMemory? collapseMemory;

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

  /// Caller-selected geometry; otherwise inherits the current presentation.
  final CupertinoSidebarToolbarGeometry? sidebarToolbarGeometry;

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
  final SidebarExpansionController _controller = SidebarExpansionController();
  final CupertinoSidebarCollapsedBarController _collapsedBarController =
      CupertinoSidebarCollapsedBarController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSidebar();
  }

  @override
  void didUpdateWidget(covariant CupertinoNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collapseMemory != widget.collapseMemory) _updateSidebar();
  }

  void _updateSidebar() => _controller.updateForm(
    _resolveForm(WindowSize.of(context)),
    collapseMemory: widget.collapseMemory,
  );

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
    _controller.dispose();
    _collapsedBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widget = this.widget;
    final toolbarGeometry =
        widget.sidebarToolbarGeometry ??
        CupertinoSidebarPresentationScope.toolbarGeometryOf(context);
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final view = View.of(context);
            final toolbarRegion = SidebarTopToolbarRegionResolver(
              occlusionScope: AdaptiveOcclusionScope.maybeOf(context),
              viewportBounds: OcclusionViewport.maybeOf(context)?.bounds,
              viewSize: view.physicalSize / view.devicePixelRatio,
              constraints: constraints,
              media: MediaQuery.of(context),
              toolbarGeometry: toolbarGeometry,
              collapsedBarEnabled: widget.collapsedSidebarEnabled,
            ).resolve();
            final adapter = SidebarNavigationAdapter(
              destinations: widget.destinations,
              auxiliaryDestinations: widget.auxiliaryDestinations,
              selectedIndex: widget.selectedIndex,
              selectedAuxiliaryIndex: widget.selectedAuxiliaryIndex,
              onDestinationSelected: onSelected,
              onAuxiliaryDestinationSelected:
                  widget.onAuxiliaryDestinationSelected,
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
            // The fixed bar is a shell overlay, outside the page AppBar's targets.
            final collapsedBar = AdaptiveWindowInteractionRegion(
              child: CupertinoSidebarCollapsedBar(
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
              ),
            );
            final branch = CupertinoSidebarPresentationScope(
              controller: _controller,
              collapsedBarEnabled: widget.collapsedSidebarEnabled,
              collapsedBarController: _collapsedBarController,
              toolbarGeometry: toolbarGeometry,
              child: _CupertinoNavigationBranch(child: child),
            );
            final sidebar = switch (widget.sidebarStyle) {
              AppleSidebarStyle.inset => CupertinoSidebar(
                controller: _controller,
                content: sidebarContent,
                collapsedBar: widget.collapsedSidebarEnabled
                    ? collapsedBar
                    : null,
                collapsedBarController: _collapsedBarController,
                collapsedBarPlacement:
                    CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
                toolbarGeometry: toolbarGeometry,
                toolbarRegion: toolbarRegion,
                extent: widget.sideNavigationExtent,
                dragHandleBuilder: widget.dragHandleBuilder,
                expandLabel: widget.expandNavigationLabel,
                collapseLabel: widget.collapseNavigationLabel,
                toggleButtonBuilder: (context, defaultBuilder) =>
                    AdaptiveWindowInteractionRegion(
                      child: NeutralCupertinoButtonBuilder(
                        builder: defaultBuilder,
                      ),
                    ),
                scaffoldBackgroundColor: scaffoldBackground,
                child: branch,
              ),
              AppleSidebarStyle.edge => CupertinoSidebar.edge(
                controller: _controller,
                content: sidebarContent,
                collapsedBar: widget.collapsedSidebarEnabled
                    ? collapsedBar
                    : null,
                collapsedBarController: _collapsedBarController,
                collapsedBarPlacement:
                    CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
                toolbarGeometry: toolbarGeometry,
                toolbarRegion: toolbarRegion,
                extent: widget.sideNavigationExtent,
                dragHandleBuilder: widget.dragHandleBuilder,
                expandLabel: widget.expandNavigationLabel,
                collapseLabel: widget.collapseNavigationLabel,
                toggleButtonBuilder: (context, defaultBuilder) =>
                    AdaptiveWindowInteractionRegion(
                      child: NeutralCupertinoButtonBuilder(
                        builder: defaultBuilder,
                      ),
                    ),
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
      floatingActionButtonLocationBuilder:
          CupertinoNavigationPrimaryActionButton.floatingLocationOf,
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

class _CupertinoNavigationBranch extends StatelessWidget {
  const _CupertinoNavigationBranch({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final declaration = OcclusionViewport.maybeOf(context);
    if (declaration == null) return child;
    // The Sidebar lays out its branch after consuming the logical-start span.
    // Its current constraints describe that remaining region during animation.
    return LayoutBuilder(
      builder: (context, constraints) => OcclusionViewport(
        bounds: declaration.trailingPaneBounds(
          constraints,
          Directionality.of(context),
        ),
        child: child,
      ),
    );
  }
}

final class _SidebarTopToolbarRegionResolver
    implements SidebarTopToolbarRegionResolver {
  const _SidebarTopToolbarRegionResolver({
    required this.occlusionScope,
    required this.viewportBounds,
    required this.viewSize,
    required this.constraints,
    required this.media,
    required this.toolbarGeometry,
    required this.collapsedBarEnabled,
  });

  final AdaptiveOcclusionScope? occlusionScope;
  final Rect? viewportBounds;
  final Size viewSize;
  final BoxConstraints constraints;
  final MediaQueryData media;
  final CupertinoSidebarToolbarGeometry toolbarGeometry;
  final bool collapsedBarEnabled;

  @override
  CupertinoSidebarToolbarRegion? resolve() {
    if (!_hasUsableEnvironment) return null;
    final layout = _resolveTopLayout();
    if (layout == null) return null;
    final padding = _resolveHorizontalPadding(layout);
    if (padding == null) return null;
    return _resolveRegion(layout, padding);
  }

  bool get _hasUsableEnvironment {
    final scope = occlusionScope;
    final viewport = viewportBounds;
    if (scope == null ||
        !scope.canReclaimTopToolbar(topViewInset: media.viewInsets.top) ||
        viewport == null) {
      return false;
    }
    // Accepted host-local regions are later projected through the native view.
    // Only a full-view host establishes that origin without extra measurement.
    return viewport == scope.geometry!.viewBounds &&
        constraints.hasBoundedWidth &&
        constraints.hasBoundedHeight &&
        OcclusionInsetsResolver.matchesViewSize(viewport, constraints.biggest);
  }

  TopToolbarLayout? _resolveTopLayout() {
    final scope = occlusionScope!;
    final geometry = scope.geometry!;
    final viewport = viewportBounds!;
    return TopToolbarLayoutResolver(
      viewBounds: geometry.viewBounds,
      viewSize: viewSize,
      occlusions: geometry.activeOcclusionRegions,
      pane: viewport,
      row: Rect.fromLTWH(
        viewport.left,
        viewport.top + math.max(media.padding.top, toolbarGeometry.topInset),
        viewport.width,
        toolbarGeometry.contentHeight,
      ),
      systemTopInset: scope.systemSafeArea.top,
      currentTopInset: media.padding.top,
      currentViewTopInset: media.viewPadding.top,
      minimumTopInset: toolbarGeometry.topInset,
      alignmentHeight: scope.topToolbarAlignmentHeight,
    ).resolve();
  }

  EdgeInsets? _resolveHorizontalPadding(TopToolbarLayout layout) {
    final scope = occlusionScope!;
    final geometry = scope.geometry!;
    final minimumInsets = ToolbarSafeAreaCalculator(
      viewBounds: geometry.viewBounds,
      toolbarBounds: layout.bounds,
      systemSafeArea: scope.systemSafeArea,
      controlColumn: geometry.verticalBarLayoutFrame,
    ).calculate();
    return scope.horizontalInsets(
      layout.bounds,
      media.padding,
      minimumInsets: minimumInsets,
    );
  }

  CupertinoSidebarToolbarRegion? _resolveRegion(
    TopToolbarLayout layout,
    EdgeInsets padding,
  ) {
    final viewport = viewportBounds!;
    final bounds = Rect.fromLTRB(
      layout.bounds.left + padding.left,
      layout.bounds.top,
      layout.bounds.right - padding.right,
      layout.bounds.bottom,
    ).shift(-viewport.topLeft);
    final sideReserve =
        2.0 * kMinInteractiveDimensionCupertino +
        math.max(
          cupertinoWindowControlEdgePadding.start,
          cupertinoWindowControlEdgePadding.end,
        ) +
        CupertinoSidebarToolbarRegions.defaultMiddleSpacing;
    final center = viewport.width / 2;
    final maximumWidth =
        2.0 *
        math.min(
          center - bounds.left - sideReserve,
          bounds.right - center - sideReserve,
        );
    if (collapsedBarEnabled && (!maximumWidth.isFinite || maximumWidth <= 0)) {
      return null;
    }
    return CupertinoSidebarToolbarRegion(
      bounds: bounds,
      minimumExtent: layout.minimumExtent,
      maxCollapsedBarWidth: collapsedBarEnabled ? maximumWidth : null,
    );
  }
}
