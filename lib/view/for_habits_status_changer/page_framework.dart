// Copyright 2024 Fries_I23
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

import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

const _kSplittedLayoutWidth = 600.0;

class PageFramework extends StatelessWidget {
  final Widget appbar;
  final Widget content;
  final Widget? habitTitle;
  final Widget habitsContent;
  final Widget? debugContent;
  final ScrollController? mainController;
  final ScrollController? rightController;

  const PageFramework({
    super.key,
    required this.appbar,
    required this.content,
    this.habitTitle,
    required this.habitsContent,
    this.debugContent,
    this.mainController,
    this.rightController,
  });

  bool useSplittedLayout(BoxConstraints constraints) =>
      constraints.maxWidth > _kSplittedLayoutWidth;

  double calMainFrameworkWidth(BoxConstraints constraints) =>
      math.min(400, constraints.maxWidth / 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(builder: (context, constraints) {
        final splittedLayout = useSplittedLayout(constraints);
        return Row(
          children: [
            Container(
              constraints: BoxConstraints.tightFor(
                  width: splittedLayout
                      ? calMainFrameworkWidth(constraints)
                      : constraints.maxWidth),
              child: _PageMainFramework(
                appbar: appbar,
                content: content,
                habitTitle: habitTitle,
                habitsContent: splittedLayout ? null : habitsContent,
                debugContent: debugContent,
                controller: mainController,
              ),
            ),
            if (splittedLayout)
              Expanded(
                child: _PageDescFramework(
                  habitTitle: habitTitle,
                  habitsContent: habitsContent,
                  controller: rightController,
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _PageMainFramework extends StatelessWidget {
  final Widget appbar;
  final Widget content;
  final Widget? habitTitle;
  final Widget? habitsContent;
  final Widget? debugContent;
  final ScrollController? controller;

  const _PageMainFramework({
    required this.appbar,
    required this.content,
    this.habitTitle,
    this.habitsContent,
    this.debugContent,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        appbar,
        content,
        if (habitsContent != null)
          ...[
            habitTitle,
            const SliverPinnedHeader(child: Divider(height: 1)),
            habitsContent!
          ].whereNotNull(),
        if (debugContent != null) debugContent!,
      ],
    );
  }
}

class _PageDescFramework extends StatelessWidget {
  final Widget? habitTitle;
  final Widget habitsContent;
  final ScrollController? controller;

  const _PageDescFramework({
    this.habitTitle,
    required this.habitsContent,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        controller: controller,
        slivers: [
          if (habitTitle != null) habitTitle!,
          habitsContent,
        ],
      ),
    );
  }
}
