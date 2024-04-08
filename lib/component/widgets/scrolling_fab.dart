// Copyright 2023 Fries_I23
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

import '../../logging/helper.dart';

enum ScrollingFABType {
  small,
  large,
}

const kDefaultScrollingFABElevation = 6.0;

const kDefaultSrollingFABIconPadding = EdgeInsets.only(right: 4);

const kDefaultScrollingFABShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)));

BoxConstraints? getDefaultScrollingFABSizeConstraints(ScrollingFABType type) {
  switch (type) {
    case ScrollingFABType.small:
      return const BoxConstraints.tightFor(height: 56.0);
    case ScrollingFABType.large:
      return const BoxConstraints.tightFor(height: 64.0);
  }
}

EdgeInsetsGeometry getDefaultScrollingFABPadding(ScrollingFABType type) {
  switch (type) {
    case ScrollingFABType.small:
      return const EdgeInsetsDirectional.only(start: 16.0, end: 16.0);
    case ScrollingFABType.large:
      return const EdgeInsetsDirectional.only(start: 20.0, end: 20.0);
  }
}

class ScrollingFAB extends StatelessWidget {
  final bool isExtended;
  final Widget _extendedLabel;
  final double? size;
  final EdgeInsetsGeometry? extendedPadding;
  final double? labelSpaceBetween;
  final double? elevation;
  final Widget? child;
  final VoidCallback onPressed;
  final ScrollingFABType _type;

  const ScrollingFAB({
    super.key,
    this.isExtended = false,
    Widget? icon,
    required Widget label,
    this.size,
    this.extendedPadding,
    this.labelSpaceBetween,
    this.elevation,
    required this.onPressed,
    required ScrollingFABType type,
  })  : child = icon,
        _extendedLabel = label,
        _type = type;

  const ScrollingFAB.small({
    super.key,
    this.isExtended = false,
    Widget? icon,
    required Widget label,
    this.size,
    this.extendedPadding,
    this.labelSpaceBetween,
    this.elevation,
    required this.onPressed,
  })  : child = icon,
        _extendedLabel = label,
        _type = ScrollingFABType.small;

  const ScrollingFAB.large({
    super.key,
    this.isExtended = false,
    Widget? icon,
    required Widget label,
    this.size,
    this.extendedPadding,
    this.labelSpaceBetween,
    this.elevation,
    required this.onPressed,
  })  : child = icon,
        _extendedLabel = label,
        _type = ScrollingFABType.large;

  BoxConstraints? getExtendedSizeConstraints(BuildContext context) {
    return size != null
        ? BoxConstraints.tightFor(height: size)
        : getDefaultScrollingFABSizeConstraints(_type);
  }

  EdgeInsetsGeometry getIconPadding(BuildContext context) {
    return labelSpaceBetween != null
        ? EdgeInsets.only(right: labelSpaceBetween!)
        : kDefaultSrollingFABIconPadding;
  }

  EdgeInsetsGeometry getExpandedPadding(BuildContext context) {
    return extendedPadding ?? getDefaultScrollingFABPadding(_type);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final FloatingActionButtonThemeData fabTheme = theme.floatingActionButtonTheme
        .copyWith(extendedSizeConstraints: getExtendedSizeConstraints(context));

    appLog.build.debug(context, ex: [isExtended, _extendedLabel, child]);

    return Theme(
      data: theme.copyWith(floatingActionButtonTheme: fabTheme),
      child: FloatingActionButton.extended(
        extendedPadding: getExpandedPadding(context),
        elevation: elevation ?? kDefaultScrollingFABElevation,
        shape: kDefaultScrollingFABShape,
        onPressed: onPressed,
        label: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              child: child,
            ),
          ),
          child: isExtended
              ? child
              : Row(
                  children: [
                    Padding(padding: getIconPadding(context), child: child),
                    _extendedLabel
                  ],
                ),
        ),
      ),
    );
  }
}
