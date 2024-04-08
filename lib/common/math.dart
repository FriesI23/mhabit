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

import 'dart:math' as math;

import 'package:tuple/tuple.dart';

const _defualtInterv = Tuple2(0, 100);

const g = 9.80665; // m/s2

num intervalTrans(
  num x, {
  required Tuple2<num, num> itervFrom,
  required Tuple2<num, num> itervTo,
}) =>
    (itervTo.item2 - itervTo.item1) *
        (x - itervFrom.item1) /
        (itervFrom.item2 - itervFrom.item1) +
    itervTo.item1;

num habitGrowCurve(
    {int days = 30, num x = 1, Tuple2<num, num> interv = _defualtInterv}) {
  const num x0 = 0;
  const num k = 0.4;
  const num minX = -10;
  const num maxX = 10;

  final newX = intervalTrans(
    x,
    itervFrom: Tuple2(0, days),
    itervTo: const Tuple2(minX, maxX),
  );

  final y = 1 / (1 + math.exp(-k * (newX - x0)));
  return intervalTrans(
    y,
    itervFrom: interv,
    itervTo: _defualtInterv,
  );
}

num habitCrowCurveInverse(
    {int days = 30, num y = 0, Tuple2<num, num> interv = _defualtInterv}) {
  const num x0 = 0;
  const num k = 0.4;
  const num minX = -10;
  const num maxX = 10;

  final newY = intervalTrans(
    y,
    itervFrom: _defualtInterv,
    itervTo: interv,
  );

  final x = x0 - math.log(1 / newY - 1) / k;
  return intervalTrans(
    x,
    itervFrom: const Tuple2(minX, maxX),
    itervTo: Tuple2(0, days),
  );
}

bool isInteger(num value) => value is int || value == value.roundToDouble();
