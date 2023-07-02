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

class FixedPagePlaceHolder extends StatelessWidget {
  final double perentage;
  final double? minHeight;
  final bool fixedButtonNaviHeight;
  final Widget? child;

  const FixedPagePlaceHolder({
    super.key,
    this.perentage = 0.1,
    this.minHeight,
    this.fixedButtonNaviHeight = true,
    this.child,
  }) : assert(perentage > 0 && perentage <= 1.0);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final widgetHeight = max(screenHeight * perentage, minHeight ?? 0.0) +
        (fixedButtonNaviHeight
            ? mediaQuery.padding.bottom
            : 0.0); // Adjust this factor as needed

    return SizedBox(height: widgetHeight, child: child);
  }
}
