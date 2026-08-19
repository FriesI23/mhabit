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

/// Builds adaptive layouts from the window's width and height classes,
/// resolved through the [Breakpoints] chain.
///
/// The default constructor measures the incoming [LayoutBuilder] constraints;
/// [WindowSizeClassLayoutBuilder.useScreenSize] measures the ambient
/// [MediaQuery] size instead. Both dimensions reach [builder] as a
/// [WindowSize].
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
    final breakpoints = Breakpoints.of(context);
    return _useSize
        ? builder(
            context,
            WindowSize.fromBreakpoints(breakpoints, MediaQuery.sizeOf(context)),
            child,
          )
        : LayoutBuilder(
            builder: (context, constraints) => builder(
              context,
              WindowSize.fromBreakpoints(
                breakpoints,
                Size(constraints.maxWidth, constraints.maxHeight),
              ),
              child,
            ),
          );
  }
}
