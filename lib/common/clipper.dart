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
import 'dart:math';

import 'package:flutter/material.dart';

class RingAngleClipper extends CustomClipper<Path> {
  final double innerRadius;
  final double outerRadius;
  final double startAngleInRadians;
  final double endAngleInRadians;

  RingAngleClipper({
    required this.innerRadius,
    required this.outerRadius,
    required this.startAngleInRadians,
    required this.endAngleInRadians,
  });

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final angleDiff = endAngleInRadians - startAngleInRadians;

    final path = Path()
      ..addPath(
        Path.combine(
          PathOperation.difference,
          Path()..addOval(Rect.fromCircle(center: center, radius: innerRadius)),
          Path()..addOval(Rect.fromCircle(center: center, radius: outerRadius)),
        ),
        Offset.zero,
      )
      ..moveTo(
        center.dx + outerRadius * cos(startAngleInRadians),
        center.dy + outerRadius * sin(startAngleInRadians),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngleInRadians,
        angleDiff,
        false,
      )
      ..lineTo(
        center.dx + innerRadius * cos(endAngleInRadians),
        center.dy + innerRadius * sin(endAngleInRadians),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        endAngleInRadians,
        -angleDiff,
        false,
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
