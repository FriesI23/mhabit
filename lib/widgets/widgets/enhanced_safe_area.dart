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

class EnhancedSafeArea extends StatelessWidget {
  final bool left;
  final bool top;
  final bool right;
  final bool bottom;
  final EdgeInsets minimum;
  final bool maintainBottomViewPadding;
  final bool withSliver;
  final Widget child;

  const EnhancedSafeArea({
    super.key,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.minimum,
    required this.maintainBottomViewPadding,
    this.withSliver = false,
    required this.child,
  });

  const EnhancedSafeArea.all({
    super.key,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    EdgeInsets? minimum,
    bool? maintainBottomViewPadding,
    this.withSliver = false,
    required this.child,
  })  : minimum = minimum ?? EdgeInsets.zero,
        maintainBottomViewPadding = maintainBottomViewPadding ?? false;

  const EnhancedSafeArea.only({
    super.key,
    bool? left,
    bool? top,
    bool? right,
    bool? bottom,
    EdgeInsets? minimum,
    bool? maintainBottomViewPadding,
    this.withSliver = false,
    required this.child,
  })  : left = left ?? false,
        right = right ?? false,
        top = top ?? false,
        bottom = bottom ?? false,
        minimum = minimum ?? EdgeInsets.zero,
        maintainBottomViewPadding = maintainBottomViewPadding ?? false;

  const EnhancedSafeArea.symmetric({
    super.key,
    bool? vertical,
    bool? horizontal,
    EdgeInsets? minimum,
    bool? maintainBottomViewPadding,
    this.withSliver = false,
    required this.child,
  })  : left = horizontal ?? false,
        right = horizontal ?? false,
        top = vertical ?? false,
        bottom = vertical ?? false,
        minimum = minimum ?? EdgeInsets.zero,
        maintainBottomViewPadding = maintainBottomViewPadding ?? false;

  const EnhancedSafeArea.edgeToEdgeSafe({
    super.key,
    EdgeInsets? minimum,
    bool? maintainBottomViewPadding,
    this.withSliver = false,
    required this.child,
  })  : left = true,
        right = true,
        top = false,
        bottom = false,
        minimum = minimum ?? EdgeInsets.zero,
        maintainBottomViewPadding = maintainBottomViewPadding ?? false;

  @override
  Widget build(BuildContext context) {
    return withSliver
        ? SliverSafeArea(
            left: left,
            top: top,
            right: right,
            bottom: bottom,
            minimum: minimum,
            sliver: child,
          )
        : SafeArea(
            left: left,
            top: top,
            right: right,
            bottom: bottom,
            minimum: minimum,
            maintainBottomViewPadding: maintainBottomViewPadding,
            child: child,
          );
  }
}
