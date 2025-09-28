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

import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../widgets/widgets/enhanced_safe_area.dart';

class SafedSliverList extends StatelessWidget {
  final List<Widget> children;

  const SafedSliverList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return EnhancedSafeArea.edgeToEdgeSafe(
      withSliver: true,
      child: SliverList(
        delegate: SliverChildListDelegate(children),
      ),
    );
  }
}

class SafedMultiSliver extends StatelessWidget {
  final bool pushPinnedChildren;
  final List<Widget> children;

  const SafedMultiSliver({
    super.key,
    this.pushPinnedChildren = false,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedSafeArea.edgeToEdgeSafe(
      withSliver: true,
      child: MultiSliver(
        pushPinnedChildren: false,
        children: children,
      ),
    );
  }
}
