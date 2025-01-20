// Copyright 2025 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import '../../common/consts.dart';

enum UiLayoutType {
  /// Small
  s(0),

  /// Large
  l(10);

  final int value;

  const UiLayoutType(this.value);
}

class AppUiLayoutBuilder extends StatelessWidget {
  final Widget? child;
  final bool ignoreWidth;
  final bool ignoreHeight;
  final UiLayoutType defaultUiType;
  final Widget Function(
    BuildContext context,
    UiLayoutType layoutType,
    Widget? child,
  ) builder;

  const AppUiLayoutBuilder({
    super.key,
    this.ignoreHeight = true,
    this.ignoreWidth = false,
    this.defaultUiType = UiLayoutType.s,
    this.child,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final isWidthLarger =
              constraints.maxWidth >= kHabitLargeScreenAdaptWidth;
          final isHeightLarger =
              constraints.maxHeight >= kHabitLargeScreenAdaptHeight;

          if (ignoreWidth && ignoreHeight) {
            return builder(context, defaultUiType, child);
          } else if (ignoreWidth) {
            return builder(
              context,
              isHeightLarger ? UiLayoutType.l : UiLayoutType.s,
              child,
            );
          } else if (ignoreHeight) {
            return builder(
              context,
              isWidthLarger ? UiLayoutType.l : UiLayoutType.s,
              child,
            );
          } else {
            return builder(
              context,
              isWidthLarger && isHeightLarger ? UiLayoutType.l : UiLayoutType.s,
              child,
            );
          }
        },
      );
}
