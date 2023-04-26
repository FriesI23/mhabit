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

class ChipList extends StatelessWidget {
  static const double _defaultChipContentHeight = 56.0;
  static const EdgeInsets _defualtChipContentPadding =
      EdgeInsets.only(left: 24, right: 12);

  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Axis direction;
  final List<Widget?> children;

  const ChipList({
    super.key,
    this.height,
    this.width,
    this.padding,
    this.direction = Axis.horizontal,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? _defaultChipContentHeight,
      width: width,
      child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: direction,
          padding: padding ?? _defualtChipContentPadding,
          itemBuilder: (context, index) => children[index],
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemCount: children.length),
    );
  }
}
