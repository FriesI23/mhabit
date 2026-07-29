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

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/common/collation_api.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/io/github/friesi23/mhabit/collation/CollationApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.github.friesi23.mhabit.collation',
      errorClassName: 'CollationFlutterError',
    ),
    dartOptions: DartOptions(),
  ),
)
/// An id/value pair for collation sorting.
class CollationItem {
  CollationItem({required this.id, required this.value});

  /// Opaque identifier returned in the sorted result.
  String id;

  /// String whose collation order determines the sort position.
  String value;
}

/// Request to sort [items] by the collation order of their [value]s.
/// When [locale] is omitted, the platform uses its system-default
/// collator. Returns the [CollationItem.id]s in collation order.
class CollationRequest {
  CollationRequest({required this.items, this.locale});

  List<CollationItem> items;
  String? locale;
}

/// Platform-native string collation.
@HostApi()
abstract class CollationHostApi {
  /// Returns [request.items]' ids reordered so that their corresponding
  /// values are in collation order.
  List<String> sortStrings(CollationRequest request);
}
