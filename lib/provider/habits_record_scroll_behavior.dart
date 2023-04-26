// Copyright 2023 Fries_I23
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

import 'package:flutter/material.dart';

import '../common/enums.dart';
import '../component/widget.dart';
import '../model/global.dart';

class HabitsRecordScrollBehaviorViewModel extends ChangeNotifier
    implements GlobalProxyProviderInterface {
  Global _g;

  HabitsRecordScrollBehaviorViewModel({required Global global}) : _g = global;

  @override
  Global get g => _g;

  @override
  void updateGlobal(Global newGloal) => _g = newGloal;

  HabitsRecordScrollBehavior get scrollBehavior =>
      _g.habitsRecordScrollBehavior;

  Future<void> setScrollBehavior(HabitsRecordScrollBehavior newBehavior) async {
    if (_g.habitsRecordScrollBehavior != newBehavior) {
      await _g.profile.setHabitsRecordScrollBehavior(newBehavior);
      notifyListeners();
    }
  }

  ScrollPhysics? getPhysics(double itemSize) {
    switch (scrollBehavior) {
      case HabitsRecordScrollBehavior.page:
        return const PageScrollPhysics();
      case HabitsRecordScrollBehavior.scrollable:
        return MagnetScrollPhysics(itemSize: itemSize);
      default:
        return null;
    }
  }
}
