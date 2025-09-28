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

import '../common/_widget.dart';

class HabitDisplayLoadingIndicator extends StatelessWidget {
  final double opacity;

  const HabitDisplayLoadingIndicator({super.key, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: opacity,
      sliver: const SliverToBoxAdapter(
        child: AppSyncLoadingIndicator(),
      ),
    );
  }
}
