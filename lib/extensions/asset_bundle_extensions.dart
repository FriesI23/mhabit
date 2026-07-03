// Copyright 2026 Fries_I23
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

import 'package:flutter/services.dart';

/// Convenience extension for loading changelog assets.
extension ChangelogAssetBundle on AssetBundle {
  /// Loads the changelog from the given asset [path].
  ///
  /// Defaults to `'CHANGELOG.md'` when [path] is omitted.
  Future<String> loadChangelog([String path = 'CHANGELOG.md']) {
    return loadString(path);
  }
}
