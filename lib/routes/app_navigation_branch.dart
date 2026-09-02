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

import 'app_router.dart';

/// A top-level destination owned by the app navigation shell.
///
/// [navigationIndex] is an explicit router contract. It must not depend on the
/// declaration order used by Dart's built-in [Enum.index].
enum AppNavigationBranch {
  habits(navigationIndex: 0),
  today(navigationIndex: 1);

  const AppNavigationBranch({required this.navigationIndex});

  /// Index used by go_router's stateful navigation shell.
  final int navigationIndex;

  /// Returns the branch explicitly assigned to [navigationIndex].
  static AppNavigationBranch fromNavigationIndex(int navigationIndex) =>
      values.firstWhere(
        (branch) => branch.navigationIndex == navigationIndex,
        orElse: () => throw ArgumentError.value(
          navigationIndex,
          'navigationIndex',
          'No app navigation branch uses this index',
        ),
      );
}

/// App-route identity owned by an [AppNavigationBranch].
///
/// This app-specific mapping stays with the branch routing model instead of
/// entering the shared extensions layer or the adaptive navigation package.
extension AppNavigationBranchRoute on AppNavigationBranch {
  /// Root route for this branch.
  AppRoute get rootRoute => switch (this) {
    AppNavigationBranch.habits => AppRoute.habits,
    AppNavigationBranch.today => AppRoute.today,
  };

  /// Name of [rootRoute].
  String get rootRouteName => rootRoute.name;
}
