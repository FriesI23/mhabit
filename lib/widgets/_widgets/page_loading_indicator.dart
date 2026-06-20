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

import '../../extensions/custom_color_extensions.dart';
import '../../models/habit_color.dart';
import '../../theme/color.dart';

const kPageLoadingCircleIndicatorSize = 64.0;

class PageLoadingIndicator extends StatelessWidget {
  final Size size;
  final HabitColor? color;

  const PageLoadingIndicator({
    super.key,
    this.size = const Size.square(kPageLoadingCircleIndicatorSize),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final CustomColors? colorData = themeData.extension<CustomColors>();
    return Center(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: CircularProgressIndicator(
          color: color != null
              ? colorData?.getColor(color!, brightness: themeData.brightness)
              : null,
        ),
      ),
    );
  }
}
