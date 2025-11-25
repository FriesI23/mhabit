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
import '../../common/utils.dart';

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

  final bool _useSize;

  const AppUiLayoutBuilder({
    super.key,
    this.ignoreHeight = true,
    this.ignoreWidth = false,
    this.defaultUiType = UiLayoutType.s,
    this.child,
    required this.builder,
  }) : _useSize = false;

  const AppUiLayoutBuilder.useScreenSize({
    super.key,
    this.ignoreHeight = true,
    this.ignoreWidth = false,
    this.defaultUiType = UiLayoutType.s,
    this.child,
    required this.builder,
  }) : _useSize = true;

  Widget _buildSizeOf(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final layoutType = computeLayoutType(
      width: size.width,
      height: size.height,
      largeScreenWidth: kHabitLargeScreenAdaptWidth,
      largeScreenHeight: kHabitLargeScreenAdaptHeight,
      ignoreWidth: ignoreWidth,
      ignoreHeight: ignoreHeight,
      defaultType: defaultUiType,
    );
    return builder(context, layoutType, child);
  }

  @override
  Widget build(BuildContext context) => _useSize
      ? _buildSizeOf(context)
      : LayoutBuilder(
          builder: (context, constraints) {
            final layoutType = computeLayoutType(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              largeScreenWidth: kHabitLargeScreenAdaptWidth,
              largeScreenHeight: kHabitLargeScreenAdaptHeight,
              ignoreWidth: ignoreWidth,
              ignoreHeight: ignoreHeight,
              defaultType: defaultUiType,
            );
            return builder(context, layoutType, child);
          },
        );
}
