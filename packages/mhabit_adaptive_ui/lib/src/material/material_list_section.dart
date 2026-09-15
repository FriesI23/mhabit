import 'package:flutter/material.dart';

import '../adaptive/adaptive_list_theme.dart';
import '../adaptive/list_section_row_scope.dart';
import '../adaptive_style.dart';

/// M3 Expressive segmented grouping built from Flutter Material primitives.
class MaterialAdaptiveListSection extends StatelessWidget {
  const MaterialAdaptiveListSection({
    super.key,
    this.header,
    required this.children,
    this.surfaceColor,
  });

  final Widget? header;
  final List<Widget> children;
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final local = AdaptiveListTheme.of(context);
    final global = theme.extension<AdaptiveListThemeData>();
    final defaults = _MaterialListSectionDefaults(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
              child: Semantics(
                header: true,
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  child: header!,
                ),
              ),
            ),
          for (var index = 0; index < children.length; index++)
            Padding(
              key: children[index].key == null
                  ? null
                  : ValueKey<Key>(children[index].key!),
              padding: EdgeInsets.only(top: index == 0 ? 0 : 2),
              child: _Segment(
                first: index == 0,
                last: index == children.length - 1,
                surfaceColor:
                    surfaceColor ??
                    local.materialSurfaceColor ??
                    global?.materialSurfaceColor ??
                    defaults.materialSurfaceColor,
                child: children[index],
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatefulWidget {
  const _Segment({
    required this.first,
    required this.last,
    required this.surfaceColor,
    required this.child,
  });

  final bool first;
  final bool last;
  final Color surfaceColor;
  final Widget child;

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  final _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The segment's position owns its silhouette in every interaction state.
    // Material and ListTile's InkWell share this shape.
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(widget.first ? 16 : 4),
        bottom: Radius.circular(widget.last ? 16 : 4),
      ),
    );
    return Material(
      color: widget.surfaceColor,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      animationDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      child: ListSectionRowScope(
        style: AdaptiveStyle.material,
        shape: shape,
        statesController: _states,
        child: ListTileTheme(
          data: ListTileTheme.of(context).copyWith(
            shape: shape,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            minVerticalPadding: 10,
            minLeadingWidth: 20,
            horizontalTitleGap: 12,
            iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          child: IconTheme.merge(
            data: const IconThemeData(size: 20),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _MaterialListSectionDefaults extends AdaptiveListThemeData {
  const _MaterialListSectionDefaults(this.context);

  final BuildContext context;

  @override
  Color get materialSurfaceColor =>
      Theme.of(context).colorScheme.surfaceContainerHigh;
}
