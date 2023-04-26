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

import '../../l10n/localizations.dart';

class HabitDisplayAppBarViewMode extends StatelessWidget {
  final double? scrolledUnderElevation;
  final Widget? title;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  const HabitDisplayAppBarViewMode({
    super.key,
    this.scrolledUnderElevation,
    this.title,
    this.bottom,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: true,
      centerTitle: true,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: Theme.of(context).colorScheme.shadow,
      title: title,
      leading: IconButton(
        onPressed: onInfoButtonPressed,
        icon: const Icon(Icons.article_outlined),
      ),
      actions: [
        IconButton(
          onPressed: onMenuButtonPressed,
          icon: const Icon(Icons.settings_outlined),
          tooltip: l10n?.habitDisplay_settingButton_tooltip,
        )
      ],
      bottom: bottom,
    );
  }
}
