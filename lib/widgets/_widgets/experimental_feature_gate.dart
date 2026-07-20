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

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/app_ui/app_experimental_feature.dart';

typedef ExperimentalFeatureSelector =
    bool Function(BuildContext context, AppExperimentalFeatureViewModel vm);

/// A [Selector]-based gate that conditionally renders widgets based on
/// an experimental feature flag.
///
/// Scopes rebuilds to just this widget instead of the entire parent build
/// method when used at the page level.
///
/// Use the default constructor when the builder needs the [enabled] flag
/// directly:
/// ```dart
/// ExperimentalFeatureGate(
///   selector: (context, vm) => vm.habitGrouping,
///   builder: (context, enabled) => enabled ? myWidget(context) : altWidget(context),
/// )
/// ```
///
/// Use [ExperimentalFeatureGate.basic] for the common case of separate
/// enabled/disabled widgets:
/// ```dart
/// ExperimentalFeatureGate.basic(
///   selector: (context, vm) => vm.habitGrouping,
///   enabledBuilder: (context) => myWidget(context),
/// )
/// ```
class ExperimentalFeatureGate extends StatelessWidget {
  final ExperimentalFeatureSelector selector;
  final Widget Function(BuildContext context, bool enabled) builder;

  /// Full constructor where [builder] receives both [context] and [enabled].
  const ExperimentalFeatureGate({
    super.key,
    required this.selector,
    required this.builder,
  });

  /// Convenience constructor with separate [enabledBuilder] and optional
  /// [disabledBuilder] (defaults to [SizedBox.shrink]).
  ExperimentalFeatureGate.basic({
    Key? key,
    required ExperimentalFeatureSelector selector,
    required WidgetBuilder enabledBuilder,
    WidgetBuilder? disabledBuilder,
  }) : this(
         key: key,
         selector: selector,
         builder: (context, enabled) => enabled
             ? enabledBuilder(context)
             : (disabledBuilder?.call(context) ?? const SizedBox.shrink()),
       );

  @override
  Widget build(BuildContext context) {
    return Selector<AppExperimentalFeatureViewModel, bool>(
      selector: selector,
      builder: (context, enabled, child) => builder(context, enabled),
    );
  }
}
