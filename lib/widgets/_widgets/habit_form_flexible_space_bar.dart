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

class HabitFormFlexibleSpaceBar extends StatelessWidget {
  final Widget? collapsedTitle;
  final Widget? expandedTitle;
  final Color? foregroundColor;
  final bool primary;

  const HabitFormFlexibleSpaceBar({
    super.key,
    required this.collapsedTitle,
    required this.expandedTitle,
    this.foregroundColor,
    this.primary = true,
  });

  EdgeInsetsGeometry? get collapsedTitlePadding =>
      const EdgeInsetsDirectional.fromSTEB(48 + 8, 0, 16 + 48, 0);
  EdgeInsetsGeometry? get expandedTitlePadding =>
      const EdgeInsets.fromLTRB(16, 0, 16, 28);

  @override
  Widget build(BuildContext context) {
    final FlexibleSpaceBarSettings settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
    final double topPadding = primary
        ? MediaQuery.viewPaddingOf(context).top
        : 0;
    final double collapsedHeight = settings.minExtent - topPadding;
    final double scrollUnderHeight = settings.maxExtent - settings.minExtent;

    final bool isCollapsed = settings.isScrolledUnder ?? false;
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Container(
            height: collapsedHeight,
            padding: collapsedTitlePadding,
            child: AnimatedOpacity(
              opacity: isCollapsed ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              curve: const Cubic(0.2, 0.0, 0.0, 1.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: collapsedTitle,
              ),
            ),
          ),
        ),
        Flexible(
          child: ClipRect(
            child: OverflowBox(
              minHeight: scrollUnderHeight,
              maxHeight: scrollUnderHeight,
              alignment: Alignment.bottomLeft,
              child: Container(
                alignment: AlignmentDirectional.bottomStart,
                padding: expandedTitlePadding,
                child: expandedTitle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
