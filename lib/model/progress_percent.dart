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

import 'dart:math' as math;

abstract interface class ProgressPercent {
  int get flex;
  num get percentage;

  bool get isComplete;

  factory ProgressPercent.merge(Iterable<ProgressPercent> children) =>
      MergedProgressPercent(children: children.toList());
}

abstract interface class ProgressPercentChanger implements ProgressPercent {
  void increase(num value);
  void set(num value);
  void toComplete();
  void reset();

  factory ProgressPercentChanger([num? initprt]) =>
      BasicProgressPercentChanger(initprt: initprt);

  factory ProgressPercentChanger.flex(int flex, [num? initprt]) =>
      BasicProgressPercentChanger(flex: flex, initprt: initprt);
}

class BasicProgressPercentChanger implements ProgressPercentChanger {
  static const num defaultPercentage = 0.0;

  @override
  final int flex;

  final num? initprt;

  num _percentage = defaultPercentage;

  BasicProgressPercentChanger({this.initprt, this.flex = 1})
      : assert(flex > 0) {
    final initprt = this.initprt;
    if (initprt != null && initprt >= 0) _percentage = initprt;
  }

  @override
  num get percentage => _percentage;

  @override
  bool get isComplete => percentage >= 1.0;

  @override
  void increase(num value) => set(_percentage + math.max(0, value));

  @override
  void set(num value) => _percentage = value.clamp(0, 1.0);

  @override
  void toComplete() => set(1.0);

  @override
  void reset() => _percentage = initprt ?? defaultPercentage;
}

class MergedProgressPercent implements ProgressPercent {
  @override
  final int flex;

  final List<ProgressPercent> children;

  MergedProgressPercent({required this.children, this.flex = 1})
      : assert(flex > 0);

  @override
  num get percentage {
    if (children.isEmpty) return 1.0;

    final totalFlex = children.fold(0, (sum, child) => sum + child.flex);
    if (totalFlex <= 0) return 0;

    return children.fold(
        0, (sum, child) => sum + child.percentage * (child.flex / totalFlex));
  }

  @override
  bool get isComplete => children.lastOrNull?.isComplete ?? true;
}
