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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../extensions/adaptive_style_extensions.dart';

class HabitStatusChangerAppbar extends StatelessWidget {
  final Widget? title;
  final Widget? bottomWidget;
  final VoidCallback? onCloseButtonPressed;

  const HabitStatusChangerAppbar({
    super.key,
    this.title,
    this.bottomWidget,
    this.onCloseButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final toolbarHeight = AdaptiveStyle.of(context).appToolbarHeight;
    return AdaptiveSliverAppBar(
      height: toolbarHeight,
      styles: const AppBarStyles(
        material: AppBarMaterialStyle(
          floating: true,
          snap: false,
          pinned: true,
        ),
      ),
      leading: AdaptiveBackButton(
        type: AdaptiveBackButtonType.close,
        onPressed: onCloseButtonPressed,
      ),
      title: title ?? const SizedBox.shrink(),
      bottom: bottomWidget != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: bottomWidget!,
            )
          : null,
    );
  }
}
