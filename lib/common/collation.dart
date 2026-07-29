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

import 'collation_api.g.dart';

// Re-export Pigeon-generated types so callers only need this import.
export 'collation_api.g.dart' show CollationItem, CollationRequest;

/// Dart-side API that delegates string collation to the platform's
/// native Collation API via Pigeon-generated MethodChannel.
///
/// Prefer [CollationApi.instance] for production use; construct
/// directly via `CollationApi(api: ...)` when you need to inject a
/// custom [CollationHostApi] (e.g. in tests).
///
/// Errors (MissingPluginException, PlatformException, etc.) are
/// propagated to the caller, which should handle graceful fallback.
class CollationApi {
  static final instance = CollationApi._();

  final CollationHostApi _api;

  CollationApi._({CollationHostApi? api}) : _api = api ?? CollationHostApi();

  /// Sorts [request.items] by the collation order of their values and
  /// returns the ids in that order.
  Future<List<String>> sortStrings(CollationRequest request) =>
      _api.sortStrings(request);
}
