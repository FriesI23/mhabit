// Copyright 2026 Fries_I23
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Interface for ViewModels whose pop-ability depends on internal state.
///
/// Implement this on a [ChangeNotifier]-based ViewModel so [PopScopeGate]
/// can read [canPop] reactively via [context.select].
///
/// When [canPop] is `true`, the system back gesture triggers a normal
/// pop — this satisfies Android's predictive back gesture requirements.
/// When `false`, the pop is intercepted and [PopScopeGate.onCannotPop]
/// is called instead.
abstract interface class PopScopeHandler {
  /// Whether the enclosing route can currently be popped by the system.
  bool get canPop;
}

/// A [PopScope] wrapper driven by a [PopScopeHandler] ViewModel from the
/// [Provider] tree.
///
/// Uses [context.select] to read [PopScopeHandler.canPop] reactively
/// (rebuilding only [PopScope], not [child]).  When a pop is blocked
/// because [PopScopeHandler.canPop] is `false`, the [onCannotPop]
/// callback is invoked with the current [BuildContext] and the resolved
/// ViewModel instance.
///
/// When [PopScopeHandler.canPop] is `true`, the system back gesture
/// triggers a normal pop — this satisfies Android's predictive back
/// gesture requirements.  When `false`, the pop is intercepted and
/// [onCannotPop] is called instead.
class PopScopeGate<T extends PopScopeHandler> extends StatelessWidget {
  /// The subtree wrapped by the [PopScope].
  ///
  /// This widget is held as a field so Flutter can skip rebuilding it
  /// when only [canPop] changes.
  final Widget child;

  /// Called when a system back gesture was attempted while
  /// [PopScopeHandler.canPop] is `false`.
  ///
  /// Receives both the current [BuildContext] and the resolved ViewModel
  /// instance of type [T].  Typical usage: exit a selection sub-mode,
  /// show a confirmation dialog, navigate, etc.  The system will retry
  /// the pop on the next back gesture once [PopScopeHandler.canPop]
  /// becomes `true`.
  final FutureOr<void> Function(BuildContext context, T vm)? onCannotPop;

  const PopScopeGate({super.key, required this.child, this.onCannotPop});

  @override
  Widget build(BuildContext context) {
    final canPop = context.select<T, bool>((vm) => vm.canPop);
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final vm = context.read<T>();
        onCannotPop?.call(context, vm);
      },
      child: child,
    );
  }
}
