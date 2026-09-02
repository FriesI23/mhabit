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

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

/// App-specific top-level navigation destinations.
///
/// Keeps business meaning at call sites while owning the platform icon matrix.
abstract final class AppNavigationDestinations {
  static AdaptiveNavigationDestination habits({required String label}) =>
      AdaptiveNavigationDestination(
        label: label,
        icons: const NavigationDestinationIcons(
          material: Icon(Icons.home_outlined),
          materialSelected: Icon(Icons.home),
          apple: Icon(CupertinoIcons.house),
          appleSelected: Icon(CupertinoIcons.house_fill),
        ),
      );

  static AdaptiveNavigationDestination today({required String label}) =>
      AdaptiveNavigationDestination(
        label: label,
        icons: const NavigationDestinationIcons(
          material: Icon(MdiIcons.calendarTodayOutline),
          materialSelected: Icon(MdiIcons.calendarToday),
          apple: Icon(CupertinoIcons.today),
          appleSelected: Icon(CupertinoIcons.today_fill),
        ),
      );
}
