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

/// Builds adaptive layouts from height-constrained window classes,
/// resolved through the [Breakpoints] chain.
///
/// The default constructor measures local width and viewport height;
/// [WindowSizeClassLayoutBuilder.useScreenSize] measures the ambient
/// [MediaQuery] size on both axes. Unbounded scrollable content height does
/// not bypass the viewport's compact layout requirement.
class WindowSizeClassLayoutBuilder extends StatelessWidget {
  final Widget? child;
  final Widget Function(
    BuildContext context,
    WindowSize windowSize,
    Widget? child,
  )
  builder;

  final bool _useSize;

  const WindowSizeClassLayoutBuilder({
    super.key,
    this.child,
    required this.builder,
  }) : _useSize = false;

  const WindowSizeClassLayoutBuilder.useScreenSize({
    super.key,
    this.child,
    required this.builder,
  }) : _useSize = true;

  @override
  Widget build(BuildContext context) {
    return _useSize
        ? builder(context, WindowSize.of(context), child)
        : LayoutBuilder(
            builder: (context, constraints) => builder(
              context,
              WindowSize.fromLayoutConstraints(context, constraints),
              child,
            ),
          );
  }
}
