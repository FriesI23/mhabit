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

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

/// App-level semantic judgments over [WindowSize].
///
/// Axis-level "at least" judgments use `WindowSizeClass.>=` directly; this
/// extension only aggregates compound form-factor semantics that appear at
/// several call sites.
extension WindowSizeSemantics on WindowSize {
  /// Tablet-class form factor: width and height both reach at least the
  /// medium class.
  ///
  /// A phone in landscape is excluded: its width is medium but its height
  /// stays compact. The phone form factor is the exact complement, so call
  /// sites read it as `!isTabletFormFactor`.
  bool get isTabletFormFactor => contains(
    const WindowSize(
      width: WindowSizeClass.medium,
      height: WindowSizeClass.medium,
    ),
  );
}
