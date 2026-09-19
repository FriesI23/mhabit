import 'package:flutter/widgets.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_adaptive_expansion_tile.dart';
import '../material/material_adaptive_expansion_tile.dart';

/// A disclosure row with optional independent trailing action.
///
/// Only an internally created controller is disposed. A supplied controller's
/// current state takes precedence over initiallyExpanded.
class AdaptiveExpansionTile extends StatefulWidget {
  const AdaptiveExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    this.controller,
    this.initiallyExpanded = false,
    this.enabled = true,
  }) : style = null;
  const AdaptiveExpansionTile.material({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    this.controller,
    this.initiallyExpanded = false,
    this.enabled = true,
  }) : style = AdaptiveStyle.material;
  const AdaptiveExpansionTile.apple({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    this.controller,
    this.initiallyExpanded = false,
    this.enabled = true,
  }) : style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final ExpansibleController? controller;
  final bool initiallyExpanded;
  final bool enabled;

  @override
  State<AdaptiveExpansionTile> createState() => _AdaptiveExpansionTileState();
}

class _AdaptiveExpansionTileState extends State<AdaptiveExpansionTile> {
  late ExpansibleController _controller;
  final Object _storageIdentity = Object();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ExpansibleController();
    if (widget.controller == null && widget.initiallyExpanded) {
      _controller.expand();
    }
  }

  @override
  void didUpdateWidget(AdaptiveExpansionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final expanded = _controller.isExpanded;
      if (oldWidget.controller == null) _controller.dispose();
      _controller = widget.controller ?? ExpansibleController();
      if (widget.controller == null && expanded) _controller.expand();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storageKey = PageStorageKey<Object>(widget.key ?? _storageIdentity);
    return switch (widget.style ?? AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => MaterialAdaptiveExpansionTile(
        key: storageKey,
        title: widget.title,
        subtitle: widget.subtitle,
        trailing: widget.trailing,
        controller: _controller,
        enabled: widget.enabled,
        children: widget.children,
      ),
      AdaptiveStyle.apple => CupertinoAdaptiveExpansionTile(
        key: storageKey,
        title: widget.title,
        subtitle: widget.subtitle,
        trailing: widget.trailing,
        controller: _controller,
        enabled: widget.enabled,
        children: widget.children,
      ),
    };
  }
}
