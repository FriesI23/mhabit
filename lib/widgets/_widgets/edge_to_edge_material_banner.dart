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

import 'package:flutter/material.dart';

import 'enhanced_safe_area.dart';

/// A [MaterialBanner] with an edge-to-edge surface and slot-aware horizontal
/// safe areas for its foreground.
///
/// The leading, content, and action slots share responsibility for the two
/// horizontal insets so an inset is never applied between adjacent slots.
/// When [forceActionsBelow] is false, [actionArea] is laid out on the trailing
/// side. Use an [OverflowBar] as [actionArea] together with
/// [forceActionsBelow] for multiple actions.
///
/// This widget is intended for inline banners. [ScaffoldMessenger] requires a
/// [MaterialBanner] and owns a different animated safe-area contract.
class EdgeToEdgeMaterialBanner extends StatelessWidget {
  final Widget content;
  final Widget actionArea;
  final Widget? leading;
  final TextStyle? contentTextStyle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? surfaceTintColor;
  final Color? shadowColor;
  final Color? dividerColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? leadingPadding;
  final bool forceActionsBelow;
  final OverflowBarAlignment overflowAlignment;
  final double minActionBarHeight;

  const EdgeToEdgeMaterialBanner({
    super.key,
    required this.content,
    required this.actionArea,
    this.leading,
    this.contentTextStyle,
    this.elevation,
    this.backgroundColor,
    this.surfaceTintColor,
    this.shadowColor,
    this.dividerColor,
    this.padding,
    this.leadingPadding,
    this.forceActionsBelow = false,
    this.overflowAlignment = OverflowBarAlignment.end,
    this.minActionBarHeight = 52.0,
  }) : assert(elevation == null || elevation >= 0);

  @override
  Widget build(BuildContext context) {
    final isLtr = Directionality.of(context) == TextDirection.ltr;

    Widget withHorizontalSafeArea(
      Widget child, {
      required bool start,
      required bool end,
    }) {
      return EnhancedSafeArea.only(
        left: isLtr ? start : end,
        right: isLtr ? end : start,
        child: child,
      );
    }

    return MaterialBanner(
      contentTextStyle: contentTextStyle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      surfaceTintColor: surfaceTintColor,
      shadowColor: shadowColor,
      dividerColor: dividerColor,
      padding: padding,
      leadingPadding: leadingPadding,
      forceActionsBelow: forceActionsBelow,
      overflowAlignment: overflowAlignment,
      minActionBarHeight: minActionBarHeight,
      leading: leading == null
          ? null
          : withHorizontalSafeArea(leading!, start: true, end: false),
      content: withHorizontalSafeArea(
        content,
        start: leading == null,
        end: forceActionsBelow,
      ),
      actions: [
        withHorizontalSafeArea(actionArea, start: forceActionsBelow, end: true),
      ],
    );
  }
}
