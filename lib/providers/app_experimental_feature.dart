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

import 'package:flutter/foundation.dart';

import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';

class AppExperimentalFeatureViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin {
  final Map<Type, AppExperimentalFeature?> _handlers = {};

  AppExperimentalFeatureViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _handlers
      ..clear()
      ..[HabitSearchExperimentalFeature] =
          profile.getHandler<HabitSearchExperimentalFeature>();
  }

  Iterable<AppExperimentalFeature> get allFeatures => _handlers.values.nonNulls;

  bool _getBool<T>() =>
      _handlers.containsKey(T) ? _handlers[T]?.get() ?? false : true;

  Future<void> _setBool<T>(bool value, {required bool listen}) async {
    final switcher = _handlers[T];
    if (switcher?.get() != value) {
      await switcher?.set(value);
      if (listen) notifyListeners();
    }
  }

  bool get habitSearch => _getBool<HabitSearchExperimentalFeature>();

  Future<void> setHabitSearch(bool vlaue, {bool listen = true}) =>
      _setBool<HabitSearchExperimentalFeature>(vlaue, listen: listen);
}
