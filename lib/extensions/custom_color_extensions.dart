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

import 'dart:ui' show Color;

import '../common/consts.dart';
import '../models/habit_form.dart';
import '../theme/color.dart';

extension HabitColorExtension on CustomColors {
  Color? getColor(HabitColorType colorType) {
    switch (colorType) {
      case HabitColorType.cc1:
        return this.cc1;
      case HabitColorType.cc2:
        return this.cc2;
      case HabitColorType.cc3:
        return this.cc3;
      case HabitColorType.cc4:
        return this.cc4;
      case HabitColorType.cc5:
        return this.cc5;
      case HabitColorType.cc6:
        return this.cc6;
      case HabitColorType.cc7:
        return this.cc7;
      case HabitColorType.cc8:
        return this.cc8;
      case HabitColorType.cc9:
        return this.cc9;
      case HabitColorType.cc10:
        return this.cc10;
    }
  }

  Color? getOnColor(HabitColorType colorType) {
    switch (colorType) {
      case HabitColorType.cc1:
        return onCc1;
      case HabitColorType.cc2:
        return onCc2;
      case HabitColorType.cc3:
        return onCc3;
      case HabitColorType.cc4:
        return onCc4;
      case HabitColorType.cc5:
        return onCc5;
      case HabitColorType.cc6:
        return onCc6;
      case HabitColorType.cc7:
        return onCc7;
      case HabitColorType.cc8:
        return onCc8;
      case HabitColorType.cc9:
        return onCc9;
      case HabitColorType.cc10:
        return onCc10;
    }
  }

  Color? getColorContainer(HabitColorType colorType) {
    switch (colorType) {
      case HabitColorType.cc1:
        return cc1Container;
      case HabitColorType.cc2:
        return cc2Container;
      case HabitColorType.cc3:
        return cc3Container;
      case HabitColorType.cc4:
        return cc4Container;
      case HabitColorType.cc5:
        return cc5Container;
      case HabitColorType.cc6:
        return cc6Container;
      case HabitColorType.cc7:
        return cc7Container;
      case HabitColorType.cc8:
        return cc8Container;
      case HabitColorType.cc9:
        return cc9Container;
      case HabitColorType.cc10:
        return cc10Container;
    }
  }

  Color? getColorOnContainer(HabitColorType colorType) {
    switch (colorType) {
      case HabitColorType.cc1:
        return onCc1Container;
      case HabitColorType.cc2:
        return onCc2Container;
      case HabitColorType.cc3:
        return onCc3Container;
      case HabitColorType.cc4:
        return onCc4Container;
      case HabitColorType.cc5:
        return onCc5Container;
      case HabitColorType.cc6:
        return onCc6Container;
      case HabitColorType.cc7:
        return onCc7Container;
      case HabitColorType.cc8:
        return onCc8Container;
      case HabitColorType.cc9:
        return onCc9Container;
      case HabitColorType.cc10:
        return onCc10Container;
    }
  }

  HabitColorType getHabitColorTypeByCC(Color cc) {
    if (cc == this.cc1) {
      return HabitColorType.cc1;
    } else if (cc == this.cc2) {
      return HabitColorType.cc2;
    } else if (cc == this.cc3) {
      return HabitColorType.cc3;
    } else if (cc == this.cc4) {
      return HabitColorType.cc4;
    } else if (cc == this.cc5) {
      return HabitColorType.cc5;
    } else if (cc == this.cc6) {
      return HabitColorType.cc6;
    } else if (cc == this.cc7) {
      return HabitColorType.cc7;
    } else if (cc == this.cc8) {
      return HabitColorType.cc8;
    } else if (cc == this.cc9) {
      return HabitColorType.cc9;
    } else if (cc == this.cc10) {
      return HabitColorType.cc10;
    } else {
      return defaultHabitColorType;
    }
  }
}
