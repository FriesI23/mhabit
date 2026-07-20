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

import '../../common/enums.dart';
import '../../logging/helper.dart';
import '../../storage/profile/handlers.dart';
import '../../storage/profile_provider.dart';

enum GroupExpandTimerSpeed implements EnumWithDBCode<GroupExpandTimerSpeed> {
  /// Default platform-specific duration.
  defaultSpeed(code: 0),

  /// 200 ms.
  fast(code: 1),

  /// 800 ms.
  slow(code: 2);

  /// Persistent code — stored to [SharedPreferences] instead of [index]
  /// so that enum reordering/new members don't silently break stored values.
  final int code;

  const GroupExpandTimerSpeed({required this.code});

  @override
  int get dbCode => code;

  static GroupExpandTimerSpeed? getFromDBCode(
    int dbCode, {
    GroupExpandTimerSpeed? withDefault,
  }) => GroupExpandTimerSpeed.values.byDBCode(dbCode, withDefault: withDefault);
}

const kGroupExpandTimerSpeedOptions = GroupExpandTimerSpeed.values;

int _speedToMs(GroupExpandTimerSpeed speed, TargetPlatform platform) =>
    switch (speed) {
      GroupExpandTimerSpeed.fast => 200,
      GroupExpandTimerSpeed.slow => 800,
      GroupExpandTimerSpeed.defaultSpeed => switch (platform) {
        TargetPlatform.android || TargetPlatform.iOS => 400,
        _ => 600,
      },
    };

class GroupExpandTimerConfigViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin {
  GroupExpandTimerDelayProfileHandler? _handler;

  GroupExpandTimerConfigViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _handler = newProfile.getHandler<GroupExpandTimerDelayProfileHandler>();
  }

  GroupExpandTimerSpeed get speed {
    final stored = _handler?.get();
    if (stored == null) return GroupExpandTimerSpeed.defaultSpeed;
    return GroupExpandTimerSpeed.getFromDBCode(stored) ??
        GroupExpandTimerSpeed.defaultSpeed;
  }

  int get expandDelayMs => _speedToMs(speed, defaultTargetPlatform);

  Future<void> setSpeed(GroupExpandTimerSpeed speed) async {
    appLog.value.info(
      "$runtimeType.setSpeed",
      beforeVal: this.speed,
      afterVal: speed,
    );
    await _handler?.set(speed.code);
    notifyListeners();
  }
}
