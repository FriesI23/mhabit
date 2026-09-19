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

import 'package:flutter/foundation.dart';

extension TargetPlatformSemantics on TargetPlatform {
  /// Whether this platform uses a mobile operating system.
  ///
  /// This classifies the operating system only. It does not describe the
  /// current window size, form factor, or available pointer devices.
  bool get isMobileOperatingSystem => switch (this) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}
