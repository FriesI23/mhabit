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

import '../../storage/profile/handlers.dart';
import '../../storage/profile_provider.dart';

class CustomColorHistoryViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin {
  static const maxLength = 20;

  CustomColorHistoryProfileHandler? _history;

  CustomColorHistoryViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _history = newProfile.getHandler<CustomColorHistoryProfileHandler>();
  }

  List<int> get history => _history?.get() ?? const [];

  /// Moves [argb] to the front of the history (inserting it if it wasn't
  /// already present), then truncates to [maxLength]. Called for every
  /// custom-color selection — fresh wheel/hex/RGB input as well as
  /// re-selecting an existing history swatch — so "most recently used"
  /// stays accurate regardless of where the selection came from.
  Future<void> recordUsage(int argb) async {
    final updated = List<int>.of(history)
      ..remove(argb)
      ..insert(0, argb);
    final truncated = updated.length > maxLength
        ? updated.sublist(0, maxLength)
        : updated;
    await _history?.set(truncated);
    notifyListeners();
  }
}
