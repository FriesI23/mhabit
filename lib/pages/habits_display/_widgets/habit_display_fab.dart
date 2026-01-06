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

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../widgets/widgets.dart';

class HabitDisplayFAB<T> extends StatelessWidget {
  final double? closedElevation;
  final CloseContainerBuilder closeBuilder;
  final OpenContainerBuilder<T> openBuilder;
  final ClosedCallback<T?>? onClosed;

  const HabitDisplayFAB({
    super.key,
    this.closedElevation,
    required this.closeBuilder,
    required this.openBuilder,
    this.onClosed,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return OpenContainer<T>(
      transitionDuration: const Duration(milliseconds: 250),
      transitionType: ContainerTransitionType.fadeThrough,
      middleColor: themeData.colorScheme.primaryContainer.withValues(
        alpha: 0.5,
      ),
      closedShape: kDefaultScrollingFABShape,
      closedColor: themeData.colorScheme.surface,
      closedElevation: closedElevation ?? kDefaultScrollingFABElevation,
      closedBuilder: closeBuilder,
      openElevation: 0.0,
      openShape: kDefaultScrollingFABShape,
      openColor: themeData.colorScheme.primaryContainer,
      openBuilder: openBuilder,
      onClosed: onClosed,
      tappable: false,
    );
  }
}
