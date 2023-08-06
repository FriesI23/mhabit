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

import '../../component/widget.dart';

class HabitDisplayAppBarEditMode extends StatelessWidget {
  final double? scrolledUnderElevation;
  final Widget? title;
  final PreferredSizeWidget? bottom;
  final Widget Function(BuildContext context)? actionBuilder;
  final VoidCallback? onLeadingButtonPressed;

  const HabitDisplayAppBarEditMode({
    super.key,
    this.scrolledUnderElevation,
    this.title,
    this.bottom,
    this.actionBuilder,
    this.onLeadingButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      forceElevated: true,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: Theme.of(context).colorScheme.shadow,
      title: title,
      centerTitle: false,
      leading: PageBackButton(
        reason: PageBackReason.close,
        onPressed: onLeadingButtonPressed,
      ),
      actions: [if (actionBuilder != null) actionBuilder!(context)],
      bottom: bottom,
    );
  }
}
