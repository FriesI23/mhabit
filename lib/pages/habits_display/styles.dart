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

import 'package:flutter/animation.dart' show Curves;
import 'package:great_list_view/great_list_view.dart'
    show DefaultAnimatedListAnimator;

const kCommonEvalation = 2.0;

const kEditModeChangeAnimateDuration = Duration(milliseconds: 200);
const kEditModeAppbarAnimateDuration = Duration(milliseconds: 200);

const kFABModeChangeDuration = Duration(milliseconds: 300);

const kHabitListFutureLoadDuration = Duration(milliseconds: 300);

const kHabitContentListAnimator = DefaultAnimatedListAnimator(
  dismissIncomingDuration: Duration(milliseconds: 300),
  resizeDuration: Duration(milliseconds: 300),
  reorderDuration: Duration(milliseconds: 250),
  movingDuration: Duration(milliseconds: 300),
  dismissIncomingCurve: Curves.easeInOut,
  resizeCurve: Curves.easeInOut,
  reorderCurve: Curves.fastOutSlowIn,
  movingCurve: Curves.easeInOut,
);
